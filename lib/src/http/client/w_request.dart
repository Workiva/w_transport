library w_transport.src.http.client.w_request;

import 'dart:async';
import 'dart:html';
import 'dart:typed_data';

import 'package:w_transport/src/http/client/util.dart' as util;
import 'package:w_transport/src/http/client/w_response.dart';
import 'package:w_transport/src/http/common/w_request.dart';
import 'package:w_transport/src/http/w_http_exception.dart';
import 'package:w_transport/src/http/w_request.dart';
import 'package:w_transport/src/http/w_response.dart';

class ClientWRequest extends CommonWRequest implements WRequest {
  HttpRequest _request;

  void abortRequest() {
    if (_request != null) {
      _request.abort();
    }
  }

  Future openRequest() async {
    _request = new HttpRequest();
    await _request.open(method, uri.toString());
  }

  Future<WResponse> fetchResponse() async {
    Completer<WResponse> c = new Completer();

    // Add request headers.
    if (headers != null) {
      headers.forEach(_request.setRequestHeader);
    }

    if (withCredentials) {
      _request.withCredentials = true;
    }

    // Pipe onProgress events to the progress controllers.
    _request.onProgress
        .transform(util.wProgressTransformer)
        .pipe(downloadProgressController);
    _request.upload.onProgress
        .transform(util.wProgressTransformer)
        .pipe(uploadProgressController);

    // Listen for request completion/errors.
    _request.onLoad.listen((event) {
      if (!c.isCompleted) {
        WResponse response = new ClientWResponse(_request, encoding);
        if ((_request.status >= 200 && _request.status < 300) ||
            _request.status == 0 ||
            _request.status == 304) {
          c.complete(response);
        } else {
          c.completeError(new WHttpException(method, uri, this, response));
        }
      }
    });
    void onError(error) {
      if (!c.isCompleted) {
        WResponse response;
        try {
          response = new ClientWResponse(_request, encoding);
        } catch (e) {}
        error = new WHttpException(method, uri, this, response, error);
        c.completeError(error);
      }
    }
    _request.onError.listen(onError);
    _request.onAbort.listen(onError);

    // Allow the caller to configure the request.
    dynamic configurationResult;
    if (configureFn != null) {
      configurationResult = configureFn(_request);
    }

    // Wait for the configuration if applicable before sending the request.
    if (configurationResult != null && configurationResult is Future) {
      await configurationResult;
    }
    _request.send(data);
    return await c.future;
  }

  void validateDataType() {
    if (data is! ByteBuffer &&
        data is! Document &&
        data is! FormData &&
        data is! String &&
        data != null) {
      throw new ArgumentError(
          'WRequest body must be a String, FormData, ByteBuffer, or Document.');
    }
  }
}
