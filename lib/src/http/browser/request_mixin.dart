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

library w_transport.src.http.browser.request_mixin;

import 'dart:async';
import 'dart:html';

import 'package:stack_trace/stack_trace.dart';

import 'package:w_transport/src/http/base_request.dart';
import 'package:w_transport/src/http/browser/form_data_body.dart';
import 'package:w_transport/src/http/browser/utils.dart' as browser_utils;
import 'package:w_transport/src/http/common/request.dart';
import 'package:w_transport/src/http/finalized_request.dart';
import 'package:w_transport/src/http/http_body.dart';
import 'package:w_transport/src/http/request_exception.dart';
import 'package:w_transport/src/http/response.dart';
import 'package:w_transport/src/http/utils.dart' as http_utils;

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
    await _request.open(method, uri.toString());
  }

  @override
  Future<BaseResponse> sendRequestAndFetchResponse(
      FinalizedRequest finalizedRequest,
      {bool streamResponse: false}) async {
    Completer<BaseResponse> c = new Completer();

    // Add request headers.
    if (finalizedRequest.headers != null) {
      finalizedRequest.headers.forEach(_request.setRequestHeader);
    }

    if (withCredentials) {
      _request.withCredentials = true;
    }

    // Pipe onProgress events to the progress controllers.
    _request.onProgress
        .transform(browser_utils.transformProgressEvents)
        .pipe(downloadProgressController);
    _request.upload.onProgress
        .transform(browser_utils.transformProgressEvents)
        .pipe(uploadProgressController);

    // Listen for request completion/errors.
    _request.onLoad.listen((event) {
      if (!c.isCompleted) {
        c.complete(_createResponse(streamResponse: streamResponse));
      }
    });
    void onError(error) {
      if (!c.isCompleted) {
        BaseResponse response = _createResponse(streamResponse: streamResponse);
        error = new RequestException(method, uri, this, response, error);
        c.completeError(error, new Chain.current());
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

    if (finalizedRequest.body is HttpBody) {
      _request.send((finalizedRequest.body as HttpBody).asBytes().buffer);
    } else if (finalizedRequest.body is StreamedHttpBody) {
      _request
          .send(await (finalizedRequest.body as StreamedHttpBody).toBytes());
    } else if (finalizedRequest.body is FormDataBody) {
      _request.send((finalizedRequest.body as FormDataBody).formData);
    }
    return await c.future;
  }

  BaseResponse _createResponse({bool streamResponse: false}) {
    if (streamResponse == null) {
      streamResponse = false;
    }

    BaseResponse response;
    if (streamResponse) {
      // TODO: Use xhr.response instead of xhr.responseText. Use FileReader to read it.
      var text = _request.responseText != null ? _request.responseText : '';
      var responseEncoding =
          http_utils.parseEncodingFromHeaders(_request.responseHeaders);
      var byteStream = new Stream.fromIterable(responseEncoding.encode(text));
      response = new StreamedResponse.fromByteStream(_request.status,
          _request.statusText, _request.responseHeaders, byteStream);
    } else {
      response = new Response.fromString(_request.status, _request.statusText,
          _request.responseHeaders, _request.responseText);
    }
    return response;
  }
}
