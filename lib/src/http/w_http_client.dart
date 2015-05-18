/*
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

/// Client-side implementations of HTTP logic.
/// Uses [HttpRequest] (XMLHttpRequest) internally.
library w_transport.src.http.w_http_client;

import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import './w_http.dart';
import './w_http_common.dart' as common;

/// Configure w_transport/w_http library for use in the browser.
void configureWHttpForBrowser() {
  common.configureWHttp(abort, getNewHttpClient, parseResponseHeaders,
      parseResponseStatus, parseResponseStatusText, parseResponseData,
      parseResponseText, parseResponseStream, openRequest, send,
      validateDataType);
}

/// Transforms an [ProgressEvent] stream from an [HttpRequest] into
/// a [WProgress] stream.
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

/// Aborts the [HttpRequest].
void abort(HttpRequest request) {
  request.abort();
}

/// Client-side HTTP requests have no notion of persistent or
/// cached network connections, and thus have no client class
/// like the server-side does.
getNewHttpClient() => null;

/// Get the response headers from the [HttpRequest].
Map<String, String> parseResponseHeaders(HttpRequest request) {
  return request.responseHeaders;
}

/// Get the response status from the [HttpRequest].
int parseResponseStatus(HttpRequest request) => request.status;

/// Get the response status text from the [HttpRequest].
String parseResponseStatusText(HttpRequest request) => request.statusText;

/// Get the response data from the [HttpRequest].
Future<Object> parseResponseData(Stream stream) async => stream.first;

/// Get the the response text from the [HttpRequest].
Future<String> parseResponseText(Stream stream) async {
  Object data = await stream.first;
  return data != null ? data.toString() : null;
}

/// Create a response stream from an [Iterable] with one element,
/// the response data from [HttpRequest].
Stream parseResponseStream(HttpRequest request, _, __) =>
    new Stream.fromIterable([request.response]);

/// Opens a client-side HTTP request using [HttpRequest].
Future<HttpRequest> openRequest(String method, Uri uri, [client]) async {
  // Create and open a new HttpRequest (XMLHttpRequest).
  return new HttpRequest()..open(method, uri.toString());
}

/// Sends a client-side HTTP request using [HttpRequest].
/// Upload and download progress streams are made available
/// for monitoring. Cross-origin credentialed requests are
/// possible so long as the [withCredentials] flag is set on
/// the [WRequest] instance.
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
    WResponse response = wResponseFactory(request, wRequest.encoding);
    if ((request.status >= 200 && request.status < 300) ||
        request.status == 0 ||
        request.status == 304) {
      completer.complete(response);
    } else {
      completer.completeError(new WHttpException(method, wRequest, response));
    }
  });
  request.onError.listen((error) {
    completer.completeError(new WHttpException(method, wRequest, null, error));
  });

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

/// Validate the request data type. For client-side requests,
/// `ByteBuffer`, `Document`, `FormData`, and `String` are valid types.
///
/// Throws an [ArgumentError] if [data] is invalid.
void validateDataType(Object data) {
  if (data is! ByteBuffer &&
      data is! Document &&
      data is! FormData &&
      data is! String) {
    throw new ArgumentError(
        'WRequest body must be a String, FormData, ByteBuffer, or Document.');
  }
}
