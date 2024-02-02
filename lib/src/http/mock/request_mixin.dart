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

// ignore: deprecated_member_use_from_same_package
abstract class MockRequestMixin implements MockBaseRequest, CommonRequest {
  Completer<Null> _canceled = Completer<Null>();
  bool _mockHandlersRegistered = false;
  Completer<BaseResponse> _response = Completer<BaseResponse>();
  Completer<FinalizedRequest> _sent = Completer<FinalizedRequest>();
  bool _shouldFailToOpen = false;
  late bool _streamResponse;

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
    if (_shouldFailToOpen) throw Exception('Mock request failed to open.');
  }

  @override
  CommonRequest switchToRealRequest({bool? streamResponse}) {
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

    // Content-length can be explicitly set on StreamedRequests.
    if (this is StreamedRequest && contentLength != null) {
      realRequest.contentLength = contentLength;
    }

    // If the content-type was explicitly set, copy that value over.
    if (wasContentTypeSetManually) {
      realRequest.contentType = contentType;
    }

    // Encoding cannot be set on MultipartRequests.
    if (this is! MultipartRequest) {
      realRequest.encoding = encoding;
    }

    return realRequest as CommonRequest;
  }

  @override
  Future<BaseResponse> sendRequestAndFetchResponse(
      FinalizedRequest finalizedRequest,
      {bool streamResponse = false}) async {
    _streamResponse = streamResponse == true;
    _sent.complete(finalizedRequest);

    // Since the entire request body has already been sent, the upload
    // progress stream can be "completed" by adding a single progress event.
    RequestProgress progress;
    if (contentLength == null || contentLength == 0) {
      progress = RequestProgress(0, 0);
    } else {
      progress = RequestProgress(contentLength!, contentLength!);
    }
    uploadProgressController.add(progress);

    // Wait until this request is completed. This is either done manually by
    // the test (if it has access to this request), or indirectly through the
    // MockHttp logic.
    return _response.future;
  }

  @override
  void complete({BaseResponse? response}) {
    final checkedResponse = response ?? MockResponse.ok();

    // Defer the "fetching" of the response until the request has been sent.
    onSent.then((_) async {
      // Coerce the response to the correct format (streamed or not).
      if (_streamResponse && response is Response) {
        final standardResponse = checkedResponse as Response;
        response = StreamedResponse.fromByteStream(
            standardResponse.status,
            standardResponse.statusText,
            standardResponse.headers,
            Stream.fromIterable([standardResponse.body.asBytes()]));
      }
      if (!_streamResponse && response is StreamedResponse) {
        final streamedResponse = checkedResponse as StreamedResponse;
        response = Response.fromBytes(
            streamedResponse.status,
            streamedResponse.statusText,
            streamedResponse.headers,
            await streamedResponse.body.toBytes());
      }

      if (response is StreamedResponse) {
        final streamedResponse = checkedResponse as StreamedResponse;
        final progressListener = http_utils.ByteStreamProgressListener(
            streamedResponse.body.byteStream,
            total: streamedResponse.contentLength);
        progressListener.progressStream.listen(downloadProgressController.add);
        response = StreamedResponse.fromByteStream(
            streamedResponse.status,
            streamedResponse.statusText,
            streamedResponse.headers,
            progressListener.byteStream);
      } else {
        final standardResponse = checkedResponse as Response;
        final total = standardResponse.body.asBytes().length;
        downloadProgressController.add(RequestProgress(total, total));
      }

      _response.complete(checkedResponse);
    });
  }

  @override
  void completeError({Object? error, BaseResponse? response}) {
    // Defer the "fetching" of the response until the request has been sent.
    onSent.then((_) {
      _response
          .completeError(RequestException(method, uri, this, response, error));
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
