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
import 'dart:html';
import 'dart:typed_data';

import 'package:fluri/fluri.dart';

import './w_http.dart';

/// Client-side implementation of an HTTP transport.
/// Uses dart:html.HttpRequest (XMLHttpRequest).
class WRequest extends WTransportRequest with FluriMixin {
  HttpRequest _request;

  /// Data to send with the HTTP request.
  dynamic _data;
  dynamic get data => _data;
  void set data(Object data) {
    if (data is! ByteBuffer &&
        data is! Document &&
        data is! String &&
        data is! FormData) {
      throw new ArgumentError(
          'WRequest body must be a String, FormData, ByteBuffer, or Document.');
    }
    _data = data;
  }

  /// Headers to send with the HTTP request.
  Map<String, String> headers = {};

  /// Whether or not to send the request with credentials.
  bool withCredentials = false;

  /// dart:html.ProgressEvent stream for this HTTP request's upload.
  StreamController<ProgressEvent> _uploadProgressController =
      new StreamController<ProgressEvent>();
  Stream<ProgressEvent> get uploadProgress => _uploadProgressController.stream;

  /// dart:html.ProgressEvent stream for this HTTP request's download.
  StreamController<ProgressEvent> _downloadProgressController =
      new StreamController<ProgressEvent>();
  Stream<ProgressEvent> get downloadProgress =>
      _downloadProgressController.stream;

  /// Register a callback that will be called after opening, but prior to sending,
  /// the request. The supplied [configure] callback will be called with the
  /// dart:html.HttpRequest instance. If the [configure] callback returns a
  /// Future, the request will not be sent until the returned Future completes.
  Function _configure;
  void configure(configure(HttpRequest request)) {
    _configure = configure;
  }

  /// Cancel the request. If the request has already finished, this will do nothing.
  void abort() {
    if (_request == null) {
      throw new StateError(
          'Can\'t cancel a request that has not yet been opened.');
    }
    _request.abort();
  }

  /// Send a DELETE request.
  Future<WResponse> delete([Uri uri]) {
    return _send('DELETE', uri);
  }

  /// Send a GET request.
  Future<WResponse> get([Uri uri]) {
    return _send('GET', uri);
  }

  /// Send a HEAD request.
  Future<WResponse> head([Uri uri]) {
    return _send('HEAD', uri);
  }

  /// Send an OPTIONS request.
  Future<WResponse> options([Uri uri]) {
    return _send('OPTIONS', uri);
  }

  /// Send a PATCH request.
  Future<WResponse> patch([Uri uri, Object data]) {
    return _send('PATCH', uri, data);
  }

  /// Send a POST request.
  Future<WResponse> post([Uri uri, Object data]) {
    return _send('POST', uri, data);
  }

  /// Send a PUT request.
  Future<WResponse> put([Uri uri, Object data]) {
    return _send('PUT', uri, data);
  }

  /// Send an HTTP request using dart:html.HttpRequest.
  Future<WResponse> _send(String method, [Uri uri, Object data]) async {
    if (uri != null) {
      this.uri = uri;
    }
    if (data != null) {
      this.data = data;
    }

    if (this.uri == null ||
        this.uri.toString() == null ||
        this.uri.toString() == '') {
      throw new StateError('WRequest: Cannot send a request without a URL.');
    }

    // Use a Completer to drive this async response.
    Completer<WResponse> completer = new Completer<WResponse>();

    // Create and open a new HttpRequest (XMLHttpRequest).
    _request = new HttpRequest();
    _request.open(method, this.uri.toString());

    // Add request headers.
    if (headers != null) {
      headers.forEach(_request.setRequestHeader);
    }

    // Set the withCredentials flag if desired.
    if (withCredentials) {
      _request.withCredentials = true;
    }

    // Pipe onProgress events to the progress controllers.
    _request.onProgress.pipe(_downloadProgressController);
    _request.upload.onProgress.pipe(_uploadProgressController);

    // Listen for request completion/errors.
    _request.onLoad.listen((ProgressEvent e) {
      WResponse response = new _WResponse.fromHttpRequest(_request);
      if ((_request.status >= 200 && _request.status < 300) ||
          _request.status == 0 ||
          _request.status == 304) {
        completer.complete(response);
      } else {
        String errorMessage =
            'Failed: $method ${this.uri} ${response.status} (${response.statusText})';
        completer.completeError(
            new WHttpException(errorMessage, this.uri, response));
      }
    });
    _request.onError.listen(completer.completeError);

    // Allow the caller to configure the request.
    dynamic configurationResult;
    if (_configure != null) {
      configurationResult = _configure(_request);
    }

    // Wait for the configuration if applicable before sending the request.
    if (configurationResult != null && configurationResult is Future) {
      await configurationResult;
    }
    _request.send(_data);

    return await completer.future;
  }
}

/// Response to a client-side HTTP request.
abstract class WResponse implements WTransportResponse {
  /// The data received as a response from the request.
  ///
  /// Could be one of the following:
  /// * String
  /// * ByteBuffer
  /// * Document
  /// * Blob
  ///
  /// `null` indicates a response failure.
  dynamic get data;

  /// The data received as a response from the request in String format.
  String get text;
}

/// Internal implementation of a response to a client-side HTTP request.
/// By making the above abstract class public and this implementation private,
/// the class structure can be public without exposing the constructor, since
/// it will only be used internally.
class _WResponse implements WResponse {
  HttpRequest _request;

  /// Create a response from a completed dart:html.HttpRequest.
  _WResponse.fromHttpRequest(HttpRequest request) {
    _request = request;
  }

  Map<String, String> get headers => _request.responseHeaders;
  int get status => _request.status;
  String get statusText => _request.statusText;
  dynamic get data => _request.response;
  String get text => _request.responseText;
}

/// An exception that is raised when a response to a request returns
/// with an unsuccessful status code.
class WHttpException implements WTransportHttpException, Exception {
  /// Descriptive error message that includes the request method & URL and the response status.
  final String message;

  /// Response to the request (some of the properties may be unavailable).
  final WResponse response;

  /// URL of the attempted/unsuccessful request.
  final Uri uri;

  WHttpException(this.message, [this.uri, this.response]);
}
