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

library w_transport.src.http.mock.request_mixin;

import 'dart:async';

import 'package:w_transport/src/http/common/request.dart';
import 'package:w_transport/src/http/finalized_request.dart';
import 'package:w_transport/src/http/mock/base_request.dart';
import 'package:w_transport/src/http/mock/response.dart';
import 'package:w_transport/src/http/request_exception.dart';
import 'package:w_transport/src/http/request_progress.dart';
import 'package:w_transport/src/http/response.dart';
import 'package:w_transport/src/http/utils.dart' as http_utils;
import 'package:w_transport/src/mocks/http.dart' show MockHttpInternal;

abstract class MockRequestMixin implements MockBaseRequest, CommonRequest {
  Completer _canceled = new Completer();
  bool _mockHandlersRegistered = false;
  Completer<BaseResponse> _response = new Completer();
  Completer<FinalizedRequest> _sent = new Completer();
  bool _shouldFailToOpen = false;
  bool _streamResponse;

  Future get onCanceled {
    _registerHandlers();
    return _canceled.future;
  }

  Future<FinalizedRequest> get onSent {
    _registerHandlers();
    return _sent.future;
  }

  @override
  void abortRequest() {
    _registerHandlers();
    _canceled.complete();
  }

  @override
  Future openRequest([_]) async {
    _registerHandlers();

    // Allow the controller of this mock request to trigger an unexpected
    // exception to test the handling of said exception.
    if (_shouldFailToOpen) throw new Exception('Mock request failed to open.');
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

  void complete({BaseResponse response}) {
    if (response == null) {
      response = new MockResponse.ok();
    }
    // Defer the "fetching" of the response until the request has been sent.
    onSent.then((_) async {
      // Coerce the response to the correct format (streamed or not).
      if (_streamResponse && response is Response) {
        response = new StreamedResponse.fromByteStream(
            response.status,
            response.statusText,
            response.headers,
            new Stream.fromIterable([(response as Response).body.asBytes()]));
      }
      if (!_streamResponse && response is StreamedResponse) {
        response = new Response.fromBytes(
            response.status,
            response.statusText,
            response.headers,
            await (response as StreamedResponse).body.toBytes());
      }

      if (response is StreamedResponse) {
        var progressListener = new http_utils.ByteStreamProgressListener(
            (response as StreamedResponse).body.byteStream,
            total: response.contentLength);
        // TODO
        var sub = progressListener.progressStream
            .listen(downloadProgressController.add);
        response = new StreamedResponse.fromByteStream(response.status,
            response.statusText, response.headers, progressListener.byteStream);
      } else {
        int total = (response as Response).body.asBytes().length;
        downloadProgressController.add(new RequestProgress(total, total));
      }

      _response.complete(response);
    });
  }

  void completeError({Object error, BaseResponse response}) {
    // Defer the "fetching" of the response until the request has been sent.
    onSent.then((_) {
      _response.completeError(
          new RequestException(method, uri, this, response, error));
    });
  }

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
