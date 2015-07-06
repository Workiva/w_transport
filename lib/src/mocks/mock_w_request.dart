library w_transport.src.mocks.mock_w_request;

import 'dart:async';
import 'dart:convert';

import 'package:fluri/fluri.dart' show FluriMixin;
import 'package:w_transport/mocks.dart' show MockWResponse;
import 'package:w_transport/w_transport.dart'
    show WHttpException, WProgress, WRequest, WResponse;

part 'package:w_transport/src/mocks/source/w_request_source.dart';

class MockWRequest extends WRequestSource implements WRequest {
  Completer<MockWResponse> _completer = new Completer<MockWResponse>();

  Completer _sent = new Completer();

  Future get sent => _sent.future;

  void complete({MockWResponse response}) {
    if (response == null) {
      response = new MockWResponse.ok();
    }
    sent.then((_) {
      _checkForCancellation(response: response);
      _completer.complete(response);
    }).catchError(_completer.completeError);
  }

  void completeError({Object error, MockWResponse response}) {
    sent.then((_) {
      _completer.completeError(
          new WHttpException(_method, uri, this, response, error));
    });
  }

  void _abortRequest(request) {
    _canceled = true;
  }

  Future<WResponse> _getResponse() {
    _sent.complete();
    return _completer.future;
  }

  Future<WResponse> _send(String method, [Uri uri, Object data]) async {
    _uploadProgressController.add(new WProgress(0, 1));
    _downloadProgressController.add(new WProgress(0, 1));

    WResponse response = await super._send(method, uri, data);

    _uploadProgressController.add(new WProgress(1, 1));
    _downloadProgressController.add(new WProgress(1, 1));

    return response;
  }

  void _validateData() {
    // Currently assuming that given data is valid.
    // TODO: Consider actually validating - will require dependency on dart:html/dart:io
  }
}
