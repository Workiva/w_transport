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

library w_transport.src.http.w_http_server;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import './w_http.dart';
import './w_http_common.dart' as common;

void configureWHttpForServer() {
  common.configureWHttp(abort, getNewHttpClient, parseResponseHeaders,
      parseResponseStatus, parseResponseStatusText, parseResponseData,
      parseResponseText, parseResponseStream, openRequest, send,
      validateDataType);
}

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
}

void abort(HttpClientRequest request) {
  request.close();
}

getNewHttpClient() => new HttpClient();

Map<String, String> parseResponseHeaders(HttpClientResponse response) {
  Map<String, String> headers = {};
  response.headers.forEach((String name, List<String> values) {
    headers[name] = values.join(',');
  });
  return headers;
}

int parseResponseStatus(HttpClientResponse response) => response.statusCode;

String parseResponseStatusText(HttpClientResponse response) =>
    response.reasonPhrase;

Future<Object> parseResponseData(HttpClientResponse response, int total,
    StreamController<WProgress> downloadProgressController) => response
    .transform(wProgressListener(total, downloadProgressController))
    .reduce((List previous, List element) => new List.from(previous)
  ..addAll(element));

Future<String> parseResponseText(HttpClientResponse response, Encoding encoding,
        int total, StreamController<WProgress> downloadProgressController) =>
    response
        .transform(wProgressListener(total, downloadProgressController))
        .transform(encoding.decoder)
        .join('');

Stream parseResponseStream(HttpClientResponse response, int total,
        StreamController<WProgress> downloadProgressController) =>
    response.transform(wProgressListener(total, downloadProgressController));

Future<HttpClientRequest> openRequest(String method, Uri uri, [client]) async {
  // Attempt to open an HTTP connection
  return await client.openUrl(method, uri);
}

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
  WResponse wResponse = new WResponse(response, wRequest.encoding,
      response.contentLength, downloadProgressController);
  if ((wResponse.status >= 200 && wResponse.status < 300) ||
      wResponse.status == 0 ||
      wResponse.status == 304) {
    return wResponse;
  } else {
    String errorMessage =
        'Failed: $method ${wRequest.uri} ${wResponse.status} (${wResponse.statusText})';
    throw new WHttpException(errorMessage, wRequest.uri, wRequest, wResponse);
  }
}

void validateDataType(Object data) {
  if (data is! String && data is! Stream) {
    throw new ArgumentError('WRequest body must be a String or a Stream.');
  }
}
