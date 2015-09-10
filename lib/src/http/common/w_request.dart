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

library w_transport.src.http.common.w_request;

import 'dart:async';
import 'dart:convert';

import 'package:fluri/fluri.dart';

import 'package:w_transport/src/http/w_http_exception.dart';
import 'package:w_transport/src/http/w_progress.dart';
import 'package:w_transport/src/http/w_request.dart';
import 'package:w_transport/src/http/w_response.dart';

abstract class CommonWRequest extends FluriMixin implements WRequest {
  /// Error associated with a cancellation.
  Object cancellationError;

  /// Configuration callback for advanced request configuration.
  /// See [configure].
  Function configureFn;

  /// Gets and sets the content length of the request. If the size of
  /// the request is not known in advance set content length to -1.
  int contentLength;

  /// Data to send on the HTTP request.
  /// On the client side, data type can be one of:
  ///
  ///   - `ByteBuffer`
  ///   - `Document`
  ///   - `FormData`
  ///   - `String`
  ///
  /// On the server side, data type can be one of:
  ///
  ///   - `Stream`
  ///   - `String`
  Object data;

  /// [WProgress] stream controller for this HTTP request's download.
  StreamController<WProgress> downloadProgressController =
      new StreamController<WProgress>();

  /// Encoding to use on the request data.
  Encoding encoding = UTF8;

  /// Headers to send with the HTTP request.
  Map<String, String> headers = {};

  /// Whether or not the request has been canceled by the caller.
  bool isCanceled = false;

  /// [WProgress] stream controller for this HTTP request's upload.
  StreamController<WProgress> uploadProgressController =
      new StreamController<WProgress>();

  /// Whether or not to send the request with credentials.
  bool withCredentials = false;

  /// Completes only when a request is canceled.
  Completer _cancellationCompleter = new Completer();

  /// HTTP method ('GET', 'POST', etc).
  String _method;

  /// [WProgress] stream for this HTTP request's download.
  Stream<WProgress> get downloadProgress => downloadProgressController.stream;

  /// HTTP method ('GET', 'POST', etc).
  String get method => _method;

  /// [WProgress] stream for this HTTP request's upload.
  Stream<WProgress> get uploadProgress => uploadProgressController.stream;

  /// Cancel this request. If the request has already finished, this will do nothing.
  void abort([Object error]) {
    abortRequest();
    isCanceled = true;
    cancellationError = error;
    _cancellationCompleter.complete();
  }

  void abortRequest();

  /// Allows more advanced configuration of this request prior to sending.
  /// The supplied callback [configureRequest] should be called after opening,
  /// but prior to sending, this request. The [request] parameter will either
  /// be an instance of [HttpRequest] or [HttpClientRequest],
  /// depending on the w_transport usage. If [configureRequest] returns a Future,
  /// the request will not be sent until the returned Future completes.
  void configure(configure(request)) {
    configureFn = configure;
  }

  /// Sends a DELETE request to the given [uri].
  /// If [uri] is null, the uri on this [WRequest] will be used.
  Future<WResponse> delete([Uri uri]) {
    return send('DELETE', uri);
  }

  /// Sends a GET request to the given [uri].
  /// If [uri] is null, the uri on this [WRequest] will be used.
  Future<WResponse> get([Uri uri]) {
    return send('GET', uri);
  }

  /// Sends a HEAD request to the given [uri].
  /// If [uri] is null, the uri on this [WRequest] will be used.
  Future<WResponse> head([Uri uri]) {
    return send('HEAD', uri);
  }

  /// Sends an OPTIONS request to the given [uri].
  /// If [uri] is null, the uri on this [WRequest] will be used.
  Future<WResponse> options([Uri uri]) {
    return send('OPTIONS', uri);
  }

  /// Sends a PATCH request to the given [uri].
  /// If [uri] is null, the uri on this [WRequest] will be used.
  /// Attaches [data], if given, or uses the data from this [WRequest].
  Future<WResponse> patch([Uri uri, Object data]) {
    return send('PATCH', uri, data);
  }

  /// Sends a POST request to the given [uri].
  /// If [uri] is null, the uri on this [WRequest] will be used.
  /// Attaches [data], if given, or uses the data from this [WRequest].
  Future<WResponse> post([Uri uri, Object data]) {
    return send('POST', uri, data);
  }

  /// Sends a PUT request to the given [uri].
  /// If [uri] is null, the uri on this [WRequest] will be used.
  /// Attaches [data], if given, or uses the data from this [WRequest].
  Future<WResponse> put([Uri uri, Object data]) {
    return send('PUT', uri, data);
  }

  /// Sends a TRACE request to the given [uri].
  /// If [uri] is null, the uri on this [WRequest] will be used.
  ///
  /// **Note:** For security reasons, TRACE requests are forbidden in the browser.
  Future<WResponse> trace([Uri uri]) {
    return send('TRACE', uri);
  }

  void checkForCancellation({WResponse response}) {
    if (isCanceled) {
      throw new WHttpException(
          _method,
          this.uri,
          this,
          response,
          cancellationError != null
              ? cancellationError
              : new Exception('Request canceled.'));
    }
  }

  void cleanUp() {}

  Future<WResponse> fetchResponse();

  Future openRequest();

  Future<WResponse> send(String method, [Uri uri, Object data]) async {
    _method = method;
    if (uri != null) {
      this.uri = uri;
    }
    if (this.uri == null || this.uri.toString() == '') {
      throw new StateError('WRequest: Cannot send a request without a URL.');
    }
    if (data != null) {
      this.data = data;
    }
    checkForCancellation();
    validateDataType();

    WResponse response;
    try {
      await openRequest();
      checkForCancellation();
      Completer<WResponse> responseCompleter = new Completer();

      // Attempt to fetch the response.
      fetchResponse().then((response) {
        if (!responseCompleter.isCompleted) {
          responseCompleter.complete(response);
        }
      }, onError: (error) {
        if (!responseCompleter.isCompleted) {
          responseCompleter.completeError(error);
        }
      });

      // Listen for cancellation and break out of the response fetching early
      // if cancellation occurs before the request has finished.
      _cancellationCompleter.future.then((_) {
        if (!responseCompleter.isCompleted) {
          responseCompleter.complete();
        }
      });

      response = await responseCompleter.future;
      checkForCancellation(response: response);

      if (response.status != 0 &&
          response.status != 304 &&
          !(response.status >= 200 && response.status < 300)) {
        throw new WHttpException(_method, this.uri, this, response);
      }
    } catch (e) {
      var error = e;
      cleanUp();
      checkForCancellation(response: response);
      if (error is! WHttpException) {
        error = new WHttpException(_method, this.uri, this, response, error);
      }
      throw error;
    }
    cleanUp();
    checkForCancellation(response: response);
    return response;
  }

  void validateDataType();
}
