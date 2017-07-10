// Copyright 2015 Workiva Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';

import 'package:w_transport/src/http/base_request.dart';
import 'package:w_transport/src/http/common/request.dart';
import 'package:w_transport/src/http/finalized_request.dart';
import 'package:w_transport/src/http/mock/base_request.dart';
import 'package:w_transport/src/http/mock/response.dart';
import 'package:w_transport/src/http/request_exception.dart';
import 'package:w_transport/src/http/request_progress.dart';
import 'package:w_transport/src/http/requests.dart';
import 'package:w_transport/src/http/response.dart';
import 'package:w_transport/src/http/utils.dart' as http_utils;
import 'package:w_transport/src/mocks/mock_transports.dart'
    show MockHttpInternal;

// ignore: deprecated_member_use
abstract class MockRequestMixin implements MockBaseRequest, CommonRequest {
  Completer<Null> _canceled = new Completer<Null>();
  bool _mockHandlersRegistered = false;
  Completer<BaseResponse> _response = new Completer<BaseResponse>();
  Completer<FinalizedRequest> _sent = new Completer<FinalizedRequest>();
  bool _shouldFailToOpen = false;
  bool _streamResponse;

  @override
  bool get isMockAware => true;

  @override
  Future<Null> get onCanceled {
    _registerHandlers();
    return _canceled.future;
  }

  @override
  Future<FinalizedRequest> get onSent {
    _registerHandlers();
    return _sent.future;
  }

  @override
  void abortRequest() {
    _registerHandlers();
    _canceled.complete();
  }

  BaseRequest createRealRequest();

  @override
  Future<Null> openRequest([_]) async {
    _registerHandlers();

    // Allow the controller of this mock request to trigger an unexpected
    // exception to test the handling of said exception.
    if (_shouldFailToOpen) throw new Exception('Mock request failed to open.');
  }

  @override
  Future<BaseResponse> switchToRealRequest({bool streamResponse}) {
    // There is not a mock expectation or handler set up to handle this request,
    // so we fallback to the real TransportPlatform implementation.
    final realRequest = createRealRequest()
      ..autoRetry = autoRetry
      ..headers = headers
      ..requestInterceptor = requestInterceptor
      ..responseInterceptor = responseInterceptor
      ..timeoutThreshold = timeoutThreshold
      ..uri = uri
      ..withCredentials = withCredentials;

    // Encoding cannot be set on MultipartRequests
    if (this is! MultipartRequest) {
      realRequest.encoding = encoding;
    }

    return streamResponse
        ? realRequest.streamSend(method)
        : realRequest.send(method);
  }

  @override
  Future<BaseResponse> sendRequestAndFetchResponse(
      FinalizedRequest finalizedRequest,
      {bool streamResponse: false}) async {
    _streamResponse = streamResponse == true;
    _sent.complete(finalizedRequest);

    // Since the entire request body has already been sent, the upload
    // progress stream can be "completed" by adding a single progress event.
    RequestProgress progress;
    if (contentLength == null || contentLength == 0) {
      progress = new RequestProgress(0, 0);
    } else {
      progress = new RequestProgress(contentLength, contentLength);
    }
    uploadProgressController.add(progress);

    // Wait until this request is completed. This is either done manually by
    // the test (if it has access to this request), or indirectly through the
    // MockHttp logic.
    return _response.future;
  }

  @override
  void complete({BaseResponse response}) {
    response ??= new MockResponse.ok();
    // Defer the "fetching" of the response until the request has been sent.
    onSent.then((_) async {
      // Coerce the response to the correct format (streamed or not).
      if (_streamResponse && response is Response) {
        final Response standardResponse = response;
        response = new StreamedResponse.fromByteStream(
            response.status,
            response.statusText,
            response.headers,
            new Stream.fromIterable([standardResponse.body.asBytes()]));
      }
      if (!_streamResponse && response is StreamedResponse) {
        final StreamedResponse streamedResponse = response;
        response = new Response.fromBytes(response.status, response.statusText,
            response.headers, await streamedResponse.body.toBytes());
      }

      if (response is StreamedResponse) {
        final StreamedResponse streamedResponse = response;
        final progressListener = new http_utils.ByteStreamProgressListener(
            streamedResponse.body.byteStream,
            total: response.contentLength);
        progressListener.progressStream.listen(downloadProgressController.add);
        response = new StreamedResponse.fromByteStream(response.status,
            response.statusText, response.headers, progressListener.byteStream);
      } else {
        final Response standardResponse = response;
        final total = standardResponse.body.asBytes().length;
        downloadProgressController.add(new RequestProgress(total, total));
      }

      _response.complete(response);
    });
  }

  @override
  void completeError({Object error, BaseResponse response}) {
    // Defer the "fetching" of the response until the request has been sent.
    onSent.then((_) {
      _response.completeError(
          new RequestException(method, uri, this, response, error));
    });
  }

  @override
  void causeFailureOnOpen() {
    _shouldFailToOpen = true;
  }

  /// Wires this mock requests events to the HTTP mock logic.
  void _registerHandlers() {
    if (_mockHandlersRegistered) return;
    _mockHandlersRegistered = true;
    onCanceled.then((_) {
      MockHttpInternal.cancelMockRequest(this);
    });
    onSent.then((_) {
      MockHttpInternal.handleMockRequest(this);
    });
  }
}
