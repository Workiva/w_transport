library w_transport.src.http.mock.request_mixin;

import 'dart:async';

import 'package:w_transport/src/http/common/request.dart';
import 'package:w_transport/src/http/finalized_request.dart';
import 'package:w_transport/src/http/mock/base_request.dart';
import 'package:w_transport/src/http/mock/response.dart';
import 'package:w_transport/src/http/request_exception.dart';
import 'package:w_transport/src/http/response.dart';
import 'package:w_transport/src/mocks/http.dart';

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
  Future<BaseResponse> sendRequestAndFetchResponse(FinalizedRequest finalizedRequest, {bool streamResponse: false}) async {
    _streamResponse = streamResponse != null ? _streamResponse : false;
    _sent.complete(finalizedRequest);

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
        response = new StreamedResponse.fromByteStream(response.status, response.statusText, response.headers, new Stream.fromIterable([response.body.asBytes()]));
      }
      if (!_streamResponse && response is StreamedResponse) {
        response = new Response.fromBytes(response.status, response.statusText, response.headers, await response.body.toBytes());
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
      cancelMockRequest(this);
    });
    onSent.then((_) {
      handleMockRequest(this);
    });
  }
}