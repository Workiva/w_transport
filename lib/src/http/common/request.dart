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

library w_transport.src.http.common.request;

import 'dart:async';
import 'dart:convert';

import 'package:fluri/fluri.dart';
import 'package:http_parser/http_parser.dart';

import 'package:w_transport/src/http/base_request.dart';
import 'package:w_transport/src/http/finalized_request.dart';
import 'package:w_transport/src/http/http_body.dart';
import 'package:w_transport/src/http/request_dispatchers.dart';
import 'package:w_transport/src/http/request_exception.dart';
import 'package:w_transport/src/http/request_progress.dart';
import 'package:w_transport/src/http/response.dart';

abstract class CommonRequest extends Object
    with FluriMixin
    implements BaseRequest, RequestDispatchers {
  CommonRequest();
  CommonRequest.withClient(client) : this.client = client;

  /// The underlying HTTP client instance. In the browser, this will be null
  /// because there is no HTTP client API available. In the VM, this will be an
  /// instance of `dart:io.HttpClient`.
  ///
  /// If this is not null, it should be used to open and send the HTTP request.
  dynamic client;

  /// Configuration callback for advanced request configuration.
  /// See [configure].
  Function configureFn;

  /// [RequestProgress] stream controller for this HTTP request's download.
  StreamController<RequestProgress> downloadProgressController =
      new StreamController<RequestProgress>();

  /// Whether or not the request has been canceled by the caller.
  bool isCanceled = false;

  /// Whether or not the request has been sent.
  bool isSent = false;

  /// HTTP method ('GET', 'POST', etc).
  String method;

  /// Request interceptor. Called right before request is sent.
  RequestInterceptor _requestInterceptor;

  /// Response interceptor. Called after response is received and before it is
  /// delivered to the request sender.
  ResponseInterceptor _responseInterceptor;

  /// Amount of time to wait for the request to finish before canceling it and
  /// considering it "timed out" (results in a [RequestException] being thrown).
  ///
  /// If null, no timeout threshold will be enforced.
  Duration timeoutThreshold;

  /// [RequestProgress] stream controller for this HTTP request's upload.
  StreamController<RequestProgress> uploadProgressController =
      new StreamController<RequestProgress>();

  /// Completes only when a request is canceled.
  Completer _cancellationCompleter = new Completer();

  /// Error associated with a cancellation.
  Object _cancellationError;

  /// Content-type of this request.
  MediaType _contentType;

  /// Completer that should complete when the request has finished (successful
  /// or otherwise).
  Completer<Null> _done = new Completer();

  /// Request body encoding.
  Encoding _encoding = UTF8;

  /// Request headers. Stored in a case-insensitive map since HTTP headers are
  /// case-insensitive.
  CaseInsensitiveMap<String> _headers = new CaseInsensitiveMap();

  /// Whether or not to send the request with credentials.
  bool _withCredentials = false;

  /// Gets the content length of the request. If the size of the request is not
  /// known in advance, the content length should be null.
  int get contentLength;

  /// Sets the content length of the request body. This is only supported in
  /// streamed requests since the body may be sent asynchronously after the
  /// headers have been sent.
  set contentLength(int length) {
    throw new UnsupportedError(
        'The content-length of a request cannot be set manually when the request body is known in advance.');
  }

  /// Content-type of this request. Set automatically based on the body type and
  /// the [encoding].
  MediaType get contentType {
    if (_contentType == null) {
      _contentType = defaultContentType;
      if (_contentType != null) {
        _contentType.change(parameters: {'charset': encoding.name});
      }
    }
    return _contentType;
  }

  /// By default, the content-type cannot be set manually because it's set
  /// automatically based on the type of request. Streamed requests will be the
  /// exception to this rule because the body is not known in advance.
  set contentType(MediaType contentType) {
    throw new UnsupportedError(
        'The content-type is set automatically when the request body and type is known in advance.');
  }

  /// Set the content-type of this request. Used to update the charset
  /// parameter when the encoding changes.
  updateContentType(MediaType contentType) {
    _contentType = contentType;
  }

  /// Default content-type. This will depend on the type of request and should
  /// be implemented by the subclasses.
  MediaType get defaultContentType;

  /// Future that resolves when the request has completed (successful or
  /// otherwise).
  Future<Null> get done => _done.future;

  /// [RequestProgress] stream for this HTTP request's download.
  Stream<RequestProgress> get downloadProgress =>
      downloadProgressController.stream;

  /// Encoding to use to encode/decode the request body.
  Encoding get encoding => _encoding;

  /// Set the encoding to use to encode/decode the request body. Setting this
  /// will update the [contentType] `charset` parameter.
  set encoding(Encoding encoding) {
    verifyUnsent();
    _encoding = encoding;
    updateContentType(
        contentType.change(parameters: {'charset': encoding.name}));
  }

  /// Get the request headers to be sent with this HTTP request.
  Map<String, String> get headers {
    // If the request has been sent, the headers are effectively frozen.
    // To respect this, an unmodifiable Map is returned.
    if (isSent) return new Map.unmodifiable(_headers);

    // Otherwise, the underlying case-insensitive Map is returned, which allows
    // modification of the individual headers.
    return _headers;
  }

  /// Set the request headers to send with this HTTP request.
  set headers(Map<String, String> headers) {
    verifyUnsent();
    _headers = new CaseInsensitiveMap.from(headers);
  }

  /// Request interceptor. Called right before request is sent.
  RequestInterceptor get requestInterceptor => _requestInterceptor;

  /// Set the request interceptor. Will throw if the request has already been
  /// sent.
  set requestInterceptor(RequestInterceptor interceptor) {
    verifyUnsent();
    _requestInterceptor = interceptor;
  }

  /// Response interceptor. Called after response is received and before it is
  /// delivered to the request sender.
  ResponseInterceptor get responseInterceptor => _responseInterceptor;

  /// Set the response interceptor. Will throw if the request has already been
  /// sent.
  set responseInterceptor(ResponseInterceptor interceptor) {
    verifyUnsent();
    _responseInterceptor = interceptor;
  }

  /// [RequestProgress] stream for this HTTP request's upload.
  Stream<RequestProgress> get uploadProgress => uploadProgressController.stream;

  /// Whether or not to send the request with credentials.
  bool get withCredentials => _withCredentials;

  /// Set the withCredentials flag, determining whether or not the request
  /// will include credentials (secure cookies).
  set withCredentials(bool flag) {
    verifyUnsent();
    _withCredentials = flag;
  }

  /// Abort the request using the underlying HTTP API.
  ///
  /// This logic is platform-specific and should be implemented by the subclass.
  void abortRequest();

  /// Perform any cleanup that may be necessary after the request has completed
  /// (either successfully or not).
  void cleanUp() {}

  /// Finalize the request body. If a body was supplied to the request dispatch
  /// method, it will be available as [body]. Otherwise the body from this
  /// request should be used.
  ///
  /// This logic is platform-specific and should be implemented by the subclass.
  Future<BaseHttpBody> finalizeBody([body]);

  /// Open the request. If [client] is given, that client should be used to open
  /// the request.
  ///
  /// This logic is platform-specific and should be implemented by the subclass.
  Future openRequest([client]);

  /// Send the request described in [finalizedRequest] and fetch the response.
  /// If [streamResponse] is true, the response should be streamed.
  ///
  /// This logic is platform-specific and should be implemented by the subclass.
  Future<BaseResponse> sendRequestAndFetchResponse(
      FinalizedRequest finalizedRequest,
      {bool streamResponse: false});

  /// Cancel this request. If the request has already finished, this will do nothing.
  void abort([Object error]) {
    abortRequest();
    isCanceled = true;
    _cancellationError = error;
    _cancellationCompleter.complete();
    if (!_done.isCompleted) {
      _done.complete();
    }
  }

  /// Check if this request has been canceled.
  void checkForCancellation({BaseResponse response}) {
    if (isCanceled) {
      throw new RequestException(
          method,
          this.uri,
          this,
          response,
          _cancellationError != null
              ? _cancellationError
              : new Exception('Request canceled.'));
    }
  }

  /// Allows more advanced configuration of this request prior to sending.
  /// The supplied callback [configureRequest] should be called after opening,
  /// but prior to sending, this request. The [request] parameter will either
  /// be an instance of [HttpRequest] or [HttpClientRequest],
  /// depending on the w_transport usage. If [configureRequest] returns a Future,
  /// the request will not be sent until the returned Future completes.
  void configure(configure(request)) {
    verifyUnsent();
    configureFn = configure;
  }

  /// Finalize the request headers, in particular the content-length and
  /// content-type headers since they depend on the request body. The returned
  /// map should be unmodifiable.
  Map<String, String> finalizeHeaders() {
    if (contentLength != null) {
      headers['content-length'] = contentLength.toString();
    }
    headers['content-type'] = contentType.toString();
    return new Map.unmodifiable(headers);
  }

  /// Freeze this request in preparation of it being sent. This freezes all
  /// fields, preventing further unexpected modification, and triggers the
  /// creation of a finalized request body.
  Future<FinalizedRequest> finalizeRequest([body]) async {
    Map<String, String> finalizedHeaders = finalizeHeaders();
    BaseHttpBody finalizedBody = await finalizeBody(body);
    FinalizedRequest finalizedRequest = new FinalizedRequest(
        method, uri, finalizedHeaders, finalizedBody, withCredentials);

    if (isSent)
      throw new StateError(
          'Request (${this.toString()}) has already been sent - it cannot be sent again.');
    isSent = true;

    return finalizedRequest;
  }

  @override
  String toString() => '$method $uri ($contentType)';

  /// Verify that this request has not yet been sent. Once it has, all fields
  /// should be considered frozen. If this request has been sent, this throws
  /// a [StateError].
  void verifyUnsent() {
    if (isSent)
      throw new StateError(
          'Request (${this.toString()}) has already been sent and can no longer be modified.');
  }

  Future<Response> delete({Map<String, String> headers, Uri uri}) =>
      _send('DELETE', headers: headers, uri: uri);

  Future<Response> get({Map<String, String> headers, Uri uri}) =>
      _send('GET', headers: headers, uri: uri);

  Future<Response> head({Map<String, String> headers, Uri uri}) =>
      _send('HEAD', headers: headers, uri: uri);

  Future<Response> options({Map<String, String> headers, Uri uri}) =>
      _send('OPTIONS', headers: headers, uri: uri);

  Future<Response> patch({body, Map<String, String> headers, Uri uri}) =>
      _send('PATCH', body: body, headers: headers, uri: uri);

  Future<Response> post({body, Map<String, String> headers, Uri uri}) =>
      _send('POST', body: body, headers: headers, uri: uri);

  Future<Response> put({body, Map<String, String> headers, Uri uri}) =>
      _send('PUT', body: body, headers: headers, uri: uri);

  Future<Response> send(String method,
          {body, Map<String, String> headers, Uri uri}) =>
      _send(method, headers: headers, uri: uri);

  Future<StreamedResponse> streamDelete(
          {Map<String, String> headers, Uri uri}) =>
      _send('DELETE', headers: headers, streamResponse: true, uri: uri);

  Future<StreamedResponse> streamGet({Map<String, String> headers, Uri uri}) =>
      _send('GET', headers: headers, streamResponse: true, uri: uri);

  Future<StreamedResponse> streamHead({Map<String, String> headers, Uri uri}) =>
      _send('HEAD', headers: headers, streamResponse: true, uri: uri);

  Future<StreamedResponse> streamOptions(
          {Map<String, String> headers, Uri uri}) =>
      _send('OPTIONS', headers: headers, streamResponse: true, uri: uri);

  Future<StreamedResponse> streamPatch(
          {body, Map<String, String> headers, Uri uri}) =>
      _send('PATCH',
          body: body, headers: headers, streamResponse: true, uri: uri);

  Future<StreamedResponse> streamPost(
          {body, Map<String, String> headers, Uri uri}) =>
      _send('POST',
          body: body, headers: headers, streamResponse: true, uri: uri);

  Future<StreamedResponse> streamPut(
          {body, Map<String, String> headers, Uri uri}) =>
      _send('PUT',
          body: body, headers: headers, streamResponse: true, uri: uri);

  Future<StreamedResponse> streamSend(String method,
          {body, Map<String, String> headers, Uri uri}) =>
      _send(method,
          body: body, headers: headers, streamResponse: true, uri: uri);

  /// Send the HTTP request:
  /// - Finalize request (method, uri, headers, and body)
  /// - Open the request (using a client, if available)
  /// - Send the request and fetch the response (optionally as a stream)
  /// - Assert a successful HTTP request by checking for a 200-level status code
  ///
  /// During this process, we check for cancellation several times and catch any
  /// errors that may be thrown. These errors are wrapped in a
  /// [RequestException] and rethrown.
  Future<BaseResponse> _send(String method,
      {body, Map<String, String> headers, bool streamResponse, Uri uri}) async {
    this.method = method;
    if (uri != null) {
      this.uri = uri;
    }
    if (this.uri == null || this.uri.toString().isEmpty)
      throw new StateError('Request: Cannot send a request without a URI.');

    // Apply the request interceptor if set.
    if (requestInterceptor != null) {
      await requestInterceptor(this);
      checkForCancellation();
    }

    // No further changes should be made to the request at this point.
    FinalizedRequest finalizedRequest = await finalizeRequest(body);
    checkForCancellation();

    BaseResponse response;
    bool responseInterceptorThrew = false;
    try {
      await openRequest(client);
      checkForCancellation();
      Completer<BaseResponse> responseCompleter = new Completer();

      // Enforce a timeout threshold if set.
      Timer timeout;
      if (timeoutThreshold != null) {
        timeout = new Timer(timeoutThreshold, () {
          abort(new TimeoutException(
              'Request took too long to complete.', timeoutThreshold));
        });
      }

      // Attempt to fetch the response.
      sendRequestAndFetchResponse(finalizedRequest,
          streamResponse: streamResponse).then((response) {
        if (!responseCompleter.isCompleted) {
          responseCompleter.complete(response);
        }
      }, onError: (error, stackTrace) {
        if (!responseCompleter.isCompleted) {
          responseCompleter.completeError(error, stackTrace);
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

      // Response has been received, so the timeout timer can be canceled.
      if (timeout != null) {
        timeout.cancel();
      }

      if (response.status != 0 &&
          response.status != 304 &&
          !(response.status >= 200 && response.status < 300)) {
        throw new RequestException(method, this.uri, this, response);
      }

      // Apply the response interceptor if set.
      if (responseInterceptor != null) {
        try {
          response = await responseInterceptor(finalizedRequest, response);
        } catch (e) {
          // We try to apply the response interceptor even if the request fails,
          // but if the request failure was due to the response interceptor
          // throwing, then we should avoid applying it again.
          responseInterceptorThrew = true;
          rethrow;
        }
      }
    } catch (e) {
      var error = e;
      if (!_done.isCompleted) {
        _done.complete();
      }
      cleanUp();
      if (error is! RequestException) {
        error = new RequestException(method, this.uri, this, response, error);
      }
      // Apply the response interceptor even in the event of failure, unless the
      // response interceptor was the cause of failure.
      if (responseInterceptor != null && !responseInterceptorThrew) {
        response = await responseInterceptor(finalizedRequest, response, error);
        error = new RequestException(method, this.uri, this, response, error);
      }
      throw error;
    }
    if (!_done.isCompleted) {
      _done.complete();
    }
    cleanUp();
    checkForCancellation(response: response);
    return response;
  }
}
