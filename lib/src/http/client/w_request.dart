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

library w_transport.src.http.client.w_request;

import 'dart:async';
import 'dart:html';
import 'dart:typed_data';

import 'package:w_transport/src/http/client/util.dart'
    show transformProgressEvents;
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
        .transform(transformProgressEvents)
        .pipe(downloadProgressController);
    _request.upload.onProgress
        .transform(transformProgressEvents)
        .pipe(uploadProgressController);

    // Listen for request completion/errors.
    _request.onLoad.listen((event) {
      if (!c.isCompleted) {
        c.complete(new ClientWResponse(_request, encoding));
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
