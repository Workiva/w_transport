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
import 'dart:html';

import 'package:pedantic/pedantic.dart';
import 'package:w_transport/src/http/base_request.dart';
import 'package:w_transport/src/http/browser/form_data_body.dart';
import 'package:w_transport/src/http/browser/utils.dart' as browser_utils;
import 'package:w_transport/src/http/common/request.dart';
import 'package:w_transport/src/http/finalized_request.dart';
import 'package:w_transport/src/http/http_body.dart';
import 'package:w_transport/src/http/request_exception.dart';
import 'package:w_transport/src/http/response.dart';

abstract class BrowserRequestMixin implements BaseRequest, CommonRequest {
  HttpRequest _request;

  @override
  void abortRequest() {
    _request?.abort();
  }

  @override
  Future<Null> openRequest([_]) async {
    _request = HttpRequest();
    _request.open(method, uri.toString());
  }

  @override
  Future<BaseResponse> sendRequestAndFetchResponse(
      FinalizedRequest finalizedRequest,
      {bool streamResponse = false}) async {
    final c = Completer<BaseResponse>();

    // Add request headers.
    if (finalizedRequest.headers != null) {
      // The browser forbids setting these two headers:
      // - connection
      // - content-length
      final headersToAdd = Map<String, String>.from(finalizedRequest.headers);
      headersToAdd.remove('connection');
      headersToAdd.remove('content-length');
      headersToAdd.forEach(_request.setRequestHeader);
    }

    if (withCredentials) {
      _request.withCredentials = true;
    }

    // Pipe onProgress events to the progress controllers.
    unawaited(_request.onProgress
        .transform(browser_utils.transformProgressEvents)
        .pipe(downloadProgressController));

    unawaited(_request.upload.onProgress
        .transform(browser_utils.transformProgressEvents)
        .pipe(uploadProgressController));

    // Listen for request completion/errors.
    _request.onLoad.listen((event) {
      if (!c.isCompleted) {
        c.complete(_createResponse(streamResponse: streamResponse));
      }
    });
    Future<Null> onError(Object error) async {
      if (!c.isCompleted) {
        final response = await _createResponse(streamResponse: streamResponse);
        error = RequestException(method, uri, this, response, error);
        c.completeError(error, StackTrace.current);
      }
    }

    _request.onError.listen(onError);
    _request.onAbort.listen(onError);

    if (streamResponse == true) {
      _request.responseType = 'blob';
    }

    // Allow the caller to configure the request.
    Object configurationResult;
    if (configureFn != null) {
      configurationResult = configureFn(_request);
    }

    // Wait for the configuration if applicable before sending the request.
    if (configurationResult != null && configurationResult is Future) {
      await configurationResult;
    }

    if (finalizedRequest.body is HttpBody) {
      HttpBody body = finalizedRequest.body;
      _request.send(body.asBytes().buffer);
    } else if (finalizedRequest.body is StreamedHttpBody) {
      StreamedHttpBody body = finalizedRequest.body;
      _request.send(await body.toBytes());
    } else if (finalizedRequest.body is FormDataBody) {
      FormDataBody body = finalizedRequest.body;
      _request.send(body.formData);
    }
    return await c.future;
  }

  Future<BaseResponse> _createResponse({bool streamResponse = false}) async {
    streamResponse ??= false;

    BaseResponse response;
    if (streamResponse) {
      final result = Completer<List<int>>();
      final reader = FileReader();
      unawaited(reader.onLoad.first.then((_) {
        result.complete(reader.result);
      }));
      unawaited(reader.onError.first.then(result.completeError));
      reader.readAsArrayBuffer(_request.response ?? Blob([]));
      final bytes = await result.future;
      final byteStream = Stream.fromIterable([bytes]);
      response = StreamedResponse.fromByteStream(_request.status,
          _request.statusText, _request.responseHeaders, byteStream);
    } else {
      response = Response.fromString(_request.status, _request.statusText,
          _request.responseHeaders, _request.responseText);
    }
    return response;
  }
}
