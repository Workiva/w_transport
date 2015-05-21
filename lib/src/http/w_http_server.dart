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

/// Server-side implementations of HTTP logic.
/// Uses [HttpClient], [HttpClientRequest], and [HttpClientResponse] internally.
library w_transport.src.http.w_http_server;

import 'dart:async';
import 'dart:io';

import './w_http.dart';
import './w_http_common.dart' as common;

/// Configure w_transport/w_transport HTTP library for use on the server.
void configureWHttpForServer() {
  common.configureWHttp(abort, getNewHttpClient, parseResponseHeaders,
      parseResponseStatus, parseResponseStatusText, parseResponseData,
      parseResponseText, parseResponseStream, openRequest, send,
      validateDataType);
}

/// Creates a [StreamTransformer] that monitors the progress of
/// a data stream instead of actually transforming it. The returned
/// stream is identical to the input stream, but [progressController]
/// will be populated with a stream of [WProgress] instances as long
/// as the data stream progress is computable.
StreamTransformer wProgressListener(
    int total, StreamController<WProgress> progressController) {
  int loaded = 0;
  return new StreamTransformer((Stream input, bool cancelOnError) {
    StreamController controller;
    StreamSubscription subscription;
    controller = new StreamController(onListen: () {
      subscription = input.listen((data) {
        controller.add(data);
        if (data is List<int>) {
          loaded += (data as List<int>).length;
          progressController.add(new WProgress(loaded, total));
        }
      }, onError: controller.addError, onDone: () {
        controller.close();
        progressController.close();
      }, cancelOnError: cancelOnError);
    }, onPause: () {
      subscription.pause();
    }, onResume: () {
      subscription.resume();
    }, onCancel: () {
      subscription.cancel();
    });
    return controller.stream.listen(null);
  });
}

/// Aborts the [HttpClientRequest] by immediately closing the connection.
void abort(HttpClientRequest request) {
  request.close();
}

/// Creates a new [HttpClient] so that server-side HTTP requests can benefit
/// from cached network connections.
getNewHttpClient() => new HttpClient();

/// Get the response headers from the [HttpClientResponse].
/// Joins multiple values for a header into a comma-separated list.
Map<String, String> parseResponseHeaders(HttpClientResponse response) {
  Map<String, String> headers = {};
  response.headers.forEach((String name, List<String> values) {
    headers[name] = values.join(',');
  });
  return headers;
}

/// Get the response status from the [HttpClientResponse].
int parseResponseStatus(HttpClientResponse response) => response.statusCode;

/// Get the response status text from the [HttpClientResponse].
String parseResponseStatusText(HttpClientResponse response) =>
    response.reasonPhrase;

/// Get the response data from the [HttpClientResponse] stream
/// by reducing it into a single [List].
Future<Object> parseResponseData(Stream stream) => stream
    .reduce((List previous, List element) {
  return new List.from(previous)..addAll(element);
});

/// Get the the response text from the [HttpClientResponse] stream
/// by decoding the bytes and joining it into a single [String].
Future<String> parseResponseText(Stream stream) => stream.join('');

/// Get the response stream from the [HttpClientResponse].
Stream parseResponseStream(HttpClientResponse response, int total,
        StreamController<WProgress> downloadProgressController) =>
    response.transform(wProgressListener(total, downloadProgressController));

/// Opens a server-side HTTP request using an [HttpClient].
Future<HttpClientRequest> openRequest(String method, Uri uri, [client]) async {
  // Attempt to open an HTTP connection
  return await client.openUrl(method, uri);
}

/// Sends a server-side HTTP request using [HttpClient], [HttpClientRequest],
/// and [HttpClientResponse]. Upload and download progress streams are made
/// available for monitoring.
Future<WResponse> send(String method, WRequest wRequest,
    HttpClientRequest request,
    StreamController<WProgress> downloadProgressController,
    StreamController<WProgress> uploadProgressController,
    [common.RequestConfigurer configure]) async {
  // Add request headers
  if (wRequest.headers != null) {
    wRequest.headers.forEach(request.headers.set);
  }

  // Allow the caller to configure the request
  dynamic configurationResult;
  if (configure != null) {
    configurationResult = configure(request);
  }

  // Wait for the configuration if applicable
  if (configurationResult != null && configurationResult is Future) {
    await configurationResult;
  }

  // If supplied, convert request data to a stream and send.
  if (wRequest.data != null) {
    if (wRequest.data is String) {
      wRequest.data =
          new Stream.fromIterable([wRequest.encoding.encode(wRequest.data)]);
    }
    request.contentLength =
        wRequest.contentLength != null ? wRequest.contentLength : -1;
    await request.addStream((wRequest.data as Stream).transform(
        wProgressListener(request.contentLength, uploadProgressController)));
  } else {
    request.contentLength = 0;
  }

  // Close the request now that data (if any) has been sent and wait for the response
  HttpClientResponse response = await request.close();
  WResponse wResponse = wResponseFactory(response, wRequest.encoding,
      response.contentLength, downloadProgressController);
  if ((wResponse.status >= 200 && wResponse.status < 300) ||
      wResponse.status == 0 ||
      wResponse.status == 304) {
    return wResponse;
  } else {
    throw new WHttpException(method, wRequest.uri, wRequest, wResponse);
  }
}

/// Validate the request data type. For server-side requests,
/// [String] and [Stream] are valid types.
///
/// Throws an [ArgumentError] if [data] is invalid.
void validateDataType(Object data) {
  if (data is! String && data is! Stream) {
    throw new ArgumentError('WRequest body must be a String or a Stream.');
  }
}
