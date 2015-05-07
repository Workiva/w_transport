/**
 * Copyright 2015 Workiva Inc.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

library w_transport.src.http.w_http_client;

import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import './w_http.dart';
import './w_http_common.dart' as common;

void configureWHttpForBrowser() {
  common.configureWHttp(abort, getNewHttpClient, parseResponseHeaders,
      parseResponseStatus, parseResponseStatusText, parseResponseData,
      parseResponseText, parseResponseStream, openRequest, send,
      validateDataType);
}

StreamTransformer<ProgressEvent, WProgress> wProgressTransformer =
    new StreamTransformer<ProgressEvent, WProgress>(
        (Stream<ProgressEvent> input, bool cancelOnError) {
  StreamController<WProgress> controller;
  StreamSubscription<ProgressEvent> subscription;
  controller = new StreamController<WProgress>(onListen: () {
    subscription = input.listen((ProgressEvent event) {
      controller.add(event.lengthComputable
          ? new WProgress(event.loaded, event.total)
          : new WProgress());
    },
        onError: controller.addError,
        onDone: controller.close,
        cancelOnError: cancelOnError);
  }, onPause: () {
    subscription.pause();
  }, onResume: () {
    subscription.resume();
  }, onCancel: () {
    subscription.cancel();
  });
  return controller.stream.listen(null);
});

void abort(HttpRequest request) {
  request.abort();
}

getNewHttpClient() => null;

Map<String, String> parseResponseHeaders(HttpRequest request) {
  return request.responseHeaders;
}

int parseResponseStatus(HttpRequest request) => request.status;

String parseResponseStatusText(HttpRequest request) => request.statusText;

Future<Object> parseResponseData(HttpRequest request, _, __) async =>
    request.response;

Future<String> parseResponseText(
        HttpRequest request, Encoding encoding, _, __) async =>
    request.responseText;

Stream parseResponseStream(HttpRequest request, _, __) =>
    new Stream.fromIterable([request.response]);

Future<HttpRequest> openRequest(String method, Uri uri, [client]) async {
  // Create and open a new HttpRequest (XMLHttpRequest).
  return new HttpRequest()..open(method, uri.toString());
}

Future<WResponse> send(String method, WRequest wRequest, HttpRequest request,
    StreamController<WProgress> downloadProgressController,
    StreamController<WProgress> uploadProgressController,
    [common.RequestConfigurer configure]) async {
  // Use a Completer to drive this async response.
  Completer<WResponse> completer = new Completer<WResponse>();

  // Add request headers.
  if (wRequest.headers != null) {
    wRequest.headers.forEach(request.setRequestHeader);
  }

  // Set the withCredentials flag if desired.
  if (wRequest.withCredentials) {
    request.withCredentials = true;
  }

  // Pipe onProgress events to the progress controllers.
  request.onProgress
      .transform(wProgressTransformer)
      .pipe(downloadProgressController);
  request.upload.onProgress
      .transform(wProgressTransformer)
      .pipe(uploadProgressController);

  // Listen for request completion/errors.
  request.onLoad.listen((ProgressEvent e) {
    WResponse response = new WResponse(request, wRequest.encoding);
    if ((request.status >= 200 && request.status < 300) ||
        request.status == 0 ||
        request.status == 304) {
      completer.complete(response);
    } else {
      String errorMessage =
          'Failed: $method ${wRequest.uri} ${response.status} (${response.statusText})';
      completer.completeError(
          new WHttpException(errorMessage, wRequest.uri, wRequest, response));
    }
  });
  request.onError.listen(completer.completeError);

  // Allow the caller to configure the request.
  dynamic configurationResult;
  if (configure != null) {
    configurationResult = configure(request);
  }

  // Wait for the configuration if applicable before sending the request.
  if (configurationResult != null && configurationResult is Future) {
    await configurationResult;
  }
  request.send(wRequest.data);

  return await completer.future;
}

void validateDataType(Object data) {
  if (data is! ByteBuffer &&
      data is! Document &&
      data is! String &&
      data is! FormData) {
    throw new ArgumentError(
        'WRequest body must be a String, FormData, ByteBuffer, or Document.');
  }
}
