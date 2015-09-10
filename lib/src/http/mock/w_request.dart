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

library w_transport.src.http.mock.w_request;

import 'dart:async';

import 'package:w_transport/src/http/common/w_request.dart';
import 'package:w_transport/src/http/mock/w_response.dart';
import 'package:w_transport/src/http/w_http_exception.dart';
import 'package:w_transport/src/http/w_request.dart';

import 'package:w_transport/src/mocks/http.dart'
    show cancelMockRequest, handleMockRequest;

abstract class MockWRequest implements WRequest {
  factory MockWRequest() {
    _MockWRequest req = new _MockWRequest();
    req.onCanceled.then((_) {
      cancelMockRequest(req);
    });
    req.onSent.then((_) {
      handleMockRequest(req);
    });
    return req;
  }

  Future get onCanceled;
  Future get onSent;

  void causeFailureOnOpen();
  void complete({MockWResponse response});
  void completeError({Object error, MockWResponse response});
}

class _MockWRequest extends CommonWRequest implements MockWRequest, WRequest {
  Completer _canceled = new Completer();
  Completer<MockWResponse> _response = new Completer();
  Completer _sent = new Completer();

  bool _shouldFailToOpen = false;

  Future get onCanceled => _canceled.future;
  Future get onSent => _sent.future;

  void abortRequest() {
    _canceled.complete();
  }

  Future<MockWResponse> fetchResponse() {
    _sent.complete();

    // Wait until this request is completed. This is either done manually by
    // the test (if it has access to this request), or indirectly through the
    // MockHttp logic.
    return _response.future;
  }

  Future openRequest() async {
    // Allow the controller of this mock request to trigger an unexpected
    // exception to test the handling of said exception.
    if (_shouldFailToOpen) throw new Exception('Mock request failed to open.');
  }

  void validateDataType() {
    // Since this is a mock, we cannot make assumptions about which data types
    // are valid.
  }

  void complete({MockWResponse response}) {
    if (response == null) {
      response = new MockWResponse.ok();
    }
    // Defer the "fetching" of the response until the request has been sent.
    onSent.then((_) {
      _response.complete(response);
    });
  }

  void completeError({Object error, MockWResponse response}) {
    // Defer the "fetching" of the response until the request has been sent.
    onSent.then((_) {
      _response.completeError(
          new WHttpException(method, uri, this, response, error));
    });
  }

  void causeFailureOnOpen() {
    _shouldFailToOpen = true;
  }
}
