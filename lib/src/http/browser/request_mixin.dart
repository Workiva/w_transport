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
    if (_request != null) {
      _request.abort();
    }
  }

  @override
  Future openRequest([_]) async {
    _request = new HttpRequest();
    _request.open(method, uri.toString());
  }

  @override
  Future<BaseResponse> sendRequestAndFetchResponse(
      FinalizedRequest finalizedRequest,
      {bool streamResponse: false}) async {
    Completer<BaseResponse> c = new Completer();

    // Add request headers.
    if (finalizedRequest.headers != null) {
      // The browser forbids setting these two headers:
      // - connection
      // - content-length
      Map headersToAdd = new Map.from(finalizedRequest.headers);
      headersToAdd.remove('connection');
      headersToAdd.remove('content-length');

      headersToAdd.forEach(_request.setRequestHeader);
    }

    if (withCredentials) {
      _request.withCredentials = true;
    }

    // Pipe onProgress events to the progress controllers.

    // ignore: unawaited_futures
    _request.onProgress
        .transform(browser_utils.transformProgressEvents)
        .pipe(downloadProgressController);

    // ignore: unawaited_futures
    _request.upload.onProgress
        .transform(browser_utils.transformProgressEvents)
        .pipe(uploadProgressController);

    // Listen for request completion/errors.
    _request.onLoad.listen((event) {
      if (!c.isCompleted) {
        c.complete(_createResponse(streamResponse: streamResponse));
      }
    });
    Future onError(Object error) async {
      if (!c.isCompleted) {
        BaseResponse response =
            await _createResponse(streamResponse: streamResponse);
        error = new RequestException(method, uri, this, response, error);
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

  Future<BaseResponse> _createResponse({bool streamResponse: false}) async {
    if (streamResponse == null) {
      streamResponse = false;
    }

    BaseResponse response;
    if (streamResponse) {
      var result = new Completer<List<int>>();
      FileReader reader = new FileReader();
      // ignore: unawaited_futures
      reader.onLoad.first.then((_) {
        result.complete(reader.result);
      });
      // ignore: unawaited_futures
      reader.onError.first.then(result.completeError);
      reader.readAsArrayBuffer(
          _request.response != null ? _request.response : new Blob([]));
      List<int> bytes = await result.future;
      var byteStream = new Stream.fromIterable([bytes]);
      response = new StreamedResponse.fromByteStream(_request.status,
          _request.statusText, _request.responseHeaders, byteStream);
    } else {
      response = new Response.fromString(_request.status, _request.statusText,
          _request.responseHeaders, _request.responseText);
    }
    return response;
  }
}
