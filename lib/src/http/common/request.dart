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
import 'dart:convert';

import 'package:fluri/fluri.dart';
import 'package:http_parser/http_parser.dart';

import 'package:w_transport/src/http/auto_retry.dart';
import 'package:w_transport/src/http/base_request.dart';
import 'package:w_transport/src/http/client.dart';
import 'package:w_transport/src/http/finalized_request.dart';
import 'package:w_transport/src/http/http_body.dart';
import 'package:w_transport/src/http/request_dispatchers.dart';
import 'package:w_transport/src/http/request_exception.dart';
import 'package:w_transport/src/http/request_progress.dart';
import 'package:w_transport/src/http/requests.dart';
import 'package:w_transport/src/http/response.dart';
import 'package:w_transport/src/http/utils.dart' as utils;
import 'package:w_transport/src/mocks/mock_transports.dart'
    show MockHttpInternal;
import 'package:w_transport/src/mocks/mock_transports.dart'
    show MockTransportsInternal;
import 'package:w_transport/src/transport_platform.dart';

abstract class CommonRequest extends Object
    with FluriMixin
    implements BaseRequest, RequestDispatchers {
  CommonRequest(TransportPlatform transportPlatform)
      : this._transportPlatform = transportPlatform {
    autoRetry = new RequestAutoRetry(this);
  }

  // ignore: deprecated_member_use
  CommonRequest.fromClient(Client wTransportClient, client)
      : this._wTransportClient = wTransportClient,
        this.client = client {
    autoRetry = new RequestAutoRetry(this);
  }

  /// Configuration of automatic request retrying for failed requests. Use this
  /// object to enable or disable automatic retrying, configure the criteria
  /// that determines whether or not a request should be retried, as well as the
  /// number of retries to attempt.
  @override
  RequestAutoRetry autoRetry;

  /// The underlying HTTP client instance. In the browser, this will be null
  /// because there is no HTTP client API available. In the VM, this will be an
  /// instance of `dart:io.HttpClient`.
  ///
  /// If this is not null, it should be used to open and send the HTTP request.
  Object client;

  /// Configuration callback for advanced request configuration.
  /// See [configure].
  Function configureFn;

  /// Whether or not the request has completed successfully.
  bool didSucceed = false;

  // Ignoring close() here because it cannot be closed, but it should not live
  // past the request's lifecycle
  /// [RequestProgress] stream controller for this HTTP request's download.
  // ignore: close_sinks
  StreamController<RequestProgress> downloadProgressController =
      new StreamController<RequestProgress>();

  /// Whether or not the request has been canceled by the caller.
  bool isCanceled = false;

  /// Whether or not the request has been sent.
  bool isSent = false;

  /// Whether or not the request timed out.
  bool isTimedOut = false;

  /// HTTP method ('GET', 'POST', etc).
  @override
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
  @override
  Duration timeoutThreshold;

  // Ignoring close() here because it cannot be closed, but it should not live
  // past the request's lifecycle
  /// [RequestProgress] stream controller for this HTTP request's upload.
  // ignore: close_sinks
  StreamController<RequestProgress> uploadProgressController =
      new StreamController<RequestProgress>();

  /// Completes only when a request is canceled.
  Completer<Null> _cancellationCompleter = new Completer<Null>();

  /// Error associated with a cancellation.
  Object _cancellationError;

  /// Content-type of this request.
  MediaType _contentType;

  /// Whether or not the content-type was set manually. If `false`, the
  /// content-type will continue to be updated automatically when the [encoding]
  /// is set/changed. If `true`, the content-type will be left alone.
  bool _contentTypeSetManually = false;

  /// Completer that should complete when the request has finished (successful
  /// or otherwise).
  Completer<Null> _done = new Completer<Null>();

  /// Request body encoding.
  Encoding _encoding = UTF8;

  /// Request headers. Stored in a case-insensitive map since HTTP headers are
  /// case-insensitive.
  CaseInsensitiveMap<String> _headers = new CaseInsensitiveMap<String>();

  /// Completes only when a request times out.
  Completer<Null> _timeoutCompleter = new Completer<Null>();

  /// Error associated with a cancellation.
  Object _timeoutError;

  /// TransportPlatform used to create this request. Required in order to
  /// support cloning and auto retrying.
  TransportPlatform _transportPlatform;

  /// Whether or not to send the request with credentials.
  bool _withCredentials = false;

  /// HttpClient instance from which this request was created. Used in [clone]
  /// to correctly tie the clone to the same client.
  // ignore: deprecated_member_use
  Client _wTransportClient;

  /// Gets the content length of the request. If the size of the request is not
  /// known in advance, the content length should be null.
  @override
  int get contentLength;

  /// Sets the content length of the request body. This is only supported in
  /// streamed requests since the body may be sent asynchronously after the
  /// headers have been sent.
  @override
  set contentLength(int length) {
    throw new UnsupportedError(
        'The content-length of a request cannot be set manually when the request body is known in advance.');
  }

  /// Content-type of this request. Set automatically based on the body type and
  /// the [encoding].
  @override
  MediaType get contentType {
    if (_contentType == null) {
      _contentType = defaultContentType;
      if (_contentType != null) {
        _contentType.change(parameters: {'charset': encoding.name});
      }
    }
    return _contentType;
  }

  /// Manually set the content-type for this request.
  ///
  /// NOTE: By default, the content-type will be set automatically based on the
  /// request type and the [encoding]. Once you set the content-type manually,
  /// we assume you are intentionally overriding this behavior and the
  /// content-type will no longer be updated when [encoding] changes.
  @override
  set contentType(MediaType contentType) {
    verifyUnsent();
    _contentTypeSetManually = true;
    updateContentType(contentType);
  }

  /// Set the content-type of this request. Used to update the charset
  /// parameter when the encoding changes.
  void updateContentType(MediaType contentType) {
    _contentType = contentType;
  }

  /// Default content-type. This will depend on the type of request and should
  /// be implemented by the subclasses.
  MediaType get defaultContentType;

  /// Future that resolves when the request has completed (successful or
  /// otherwise).
  @override
  Future<Null> get done => _done.future;

  /// [RequestProgress] stream for this HTTP request's download.
  @override
  Stream<RequestProgress> get downloadProgress =>
      downloadProgressController.stream;

  /// Encoding to use to encode/decode the request body.
  @override
  Encoding get encoding => _encoding;

  /// Set the encoding to use to encode/decode the request body. Setting this
  /// will update the [contentType] `charset` parameter.
  @override
  set encoding(Encoding encoding) {
    verifyUnsent();
    if (encoding == null) throw new ArgumentError.notNull('encoding');
    _encoding = encoding;
    if (!_contentTypeSetManually) {
      updateContentType(
          contentType.change(parameters: {'charset': encoding.name}));
    }
  }

  /// Get the request headers to be sent with this HTTP request.
  @override
  Map<String, String> get headers {
    // If the request has been sent, the headers are effectively frozen.
    // To respect this, an unmodifiable Map is returned.
    if (isSent) return new Map<String, String>.unmodifiable(_headers);

    // Otherwise, the underlying case-insensitive Map is returned, which allows
    // modification of the individual headers.
    return _headers;
  }

  /// Set the request headers to send with this HTTP request.
  @override
  set headers(Map<String, String> headers) {
    verifyUnsent();
    _headers = new CaseInsensitiveMap<String>.from(headers);
  }

  /// Returns `true` if this request is complete (successful or failed), `false`
  /// otherwise.
  @override
  bool get isDone => isCanceled || _done.isCompleted;

  /// Whether or not this request is wrapped in a mock-aware class.
  bool get isMockAware => false;

  /// Request interceptor. Called right before request is sent.
  @override
  RequestInterceptor get requestInterceptor => _requestInterceptor;

  /// Set the request interceptor. Will throw if the request has already been
  /// sent.
  @override
  set requestInterceptor(RequestInterceptor interceptor) {
    verifyUnsent();
    _requestInterceptor = interceptor;
  }

  /// Response interceptor. Called after response is received and before it is
  /// delivered to the request sender.
  @override
  ResponseInterceptor get responseInterceptor => _responseInterceptor;

  /// Set the response interceptor. Will throw if the request has already been
  /// sent.
  @override
  set responseInterceptor(ResponseInterceptor interceptor) {
    verifyUnsent();
    _responseInterceptor = interceptor;
  }

  /// [RequestProgress] stream for this HTTP request's upload.
  @override
  Stream<RequestProgress> get uploadProgress => uploadProgressController.stream;

  /// Whether or not to send the request with credentials.
  @override
  bool get withCredentials => _withCredentials;

  /// Set the withCredentials flag, determining whether or not the request
  /// will include credentials (secure cookies).
  @override
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
  Future<BaseHttpBody> finalizeBody([dynamic body]);

  /// Open the request. If [client] is given, that client should be used to open
  /// the request.
  ///
  /// This logic is platform-specific and should be implemented by the subclass.
  Future<Null> openRequest([Object client]);

  /// Send the request described in [finalizedRequest] and fetch the response.
  /// If [streamResponse] is true, the response should be streamed.
  ///
  /// This logic is platform-specific and should be implemented by the subclass.
  Future<BaseResponse> sendRequestAndFetchResponse(
      FinalizedRequest finalizedRequest,
      {bool streamResponse: false});

  /// Cancel this request. If the request has already finished, this will do
  /// nothing.
  @override
  void abort([Object error]) {
    if (isCanceled) return;
    isCanceled = true;

    abortRequest();
    _cancellationError = error;
    _cancellationCompleter.complete();
    if (!_done.isCompleted) {
      _done.complete();
    }
  }

  /// Check if this request has been canceled.
  void checkForCancellation({BaseResponse response}) {
    if (isCanceled) {
      final error = new RequestException(
          method,
          this.uri,
          this,
          response,
          _cancellationError != null
              ? _cancellationError
              : new Exception('Request canceled'));
      autoRetry.failures.add(error);
      throw error;
    }
  }

  /// Check if this request has exceeded the timeout threshold.
  void checkForTimeout() {
    if (isTimedOut) {
      throw new RequestException(method, this.uri, this, null, _timeoutError);
    }
  }

  /// Returns a clone of this request.
  ///
  /// Sub classes should override this, call super.clone() first to get the base
  /// clone, and then add fields specific to their implementation.
  @override
  BaseRequest clone() {
    // StreamedRequests can't be cloned.
    if (this is StreamedRequest) return null;

    BaseRequest requestClone;
    final fromClient = _wTransportClient != null;
    if (this is FormRequest) {
      requestClone = fromClient
          ? _wTransportClient.newFormRequest()
          : new FormRequest(transportPlatform: _transportPlatform);
    } else if (this is JsonRequest) {
      requestClone = fromClient
          ? _wTransportClient.newJsonRequest()
          : new JsonRequest(transportPlatform: _transportPlatform);
    } else if (this is MultipartRequest) {
      requestClone = fromClient
          ? _wTransportClient.newMultipartRequest()
          : new MultipartRequest(transportPlatform: _transportPlatform);
    } else if (this is Request) {
      requestClone = fromClient
          ? _wTransportClient.newRequest()
          : new Request(transportPlatform: _transportPlatform);
    }

    requestClone
      ..autoRetry = autoRetry
      ..headers = headers
      ..requestInterceptor = requestInterceptor
      ..responseInterceptor = responseInterceptor
      ..timeoutThreshold = timeoutThreshold
      ..uri = uri
      ..withCredentials = withCredentials;

    // Encoding cannot be set on MultipartRequests
    if (this is! MultipartRequest) {
      requestClone.encoding = encoding;
    }

    // Don't need to worry about content-type and -length because they can only
    // be set on streamed requests, which can't be cloned.

    return requestClone;
  }

  /// Allows more advanced configuration of this request prior to sending.
  /// The supplied callback [configureRequest] should be called after opening,
  /// but prior to sending, this request. The [request] parameter will either
  /// be an instance of [HttpRequest] or [HttpClientRequest],
  /// depending on the w_transport usage. If [configureRequest] returns a Future,
  /// the request will not be sent until the returned Future completes.
  @override
  void configure(configure(Object request)) {
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
    return new Map<String, String>.unmodifiable(headers);
  }

  /// Freeze this request in preparation of it being sent. This freezes all
  /// fields, preventing further unexpected modification, and triggers the
  /// creation of a finalized request body.
  Future<FinalizedRequest> finalizeRequest([dynamic body]) async {
    final finalizedHeaders = finalizeHeaders();
    final finalizedBody = await finalizeBody(body);
    final finalizedRequest = new FinalizedRequest(
        method, uri, finalizedHeaders, finalizedBody, withCredentials);

    if (isSent)
      throw new StateError(
          'Request (${this.toString()}) has already been sent - it cannot be sent again.');
    isSent = true;

    return finalizedRequest;
  }

  /// When a mock request is sent, we check to see if there is a mock
  /// expectation or handler setup to handle the request. If not, we switch to
  /// a real request instance (created from a TransportPlatform instance).
  ///
  /// This is handled by the mock request mixin.
  Future<BaseResponse> switchToRealRequest({bool streamResponse}) {
    throw new UnimplementedError();
  }

  @override
  String toString() => '$runtimeType: $method $uri ($contentType)';

  /// Verify that this request has not yet been sent. Once it has, all fields
  /// should be considered frozen. If this request has been sent, this throws
  /// a [StateError].
  void verifyUnsent() {
    if (isSent)
      throw new StateError(
          'Request (${this.toString()}) has already been sent and can no longer be modified.');
  }

  @override
  Future<Response> delete({Map<String, String> headers, Uri uri}) async {
    final r = await _send('DELETE', headers: headers, uri: uri);
    assert(r is Response, 'delete() should return a Response');
    Response response = r;
    return response;
  }

  @override
  Future<Response> get({Map<String, String> headers, Uri uri}) async {
    final r = await _send('GET', headers: headers, uri: uri);
    assert(r is Response, 'get() should return a Response');
    Response response = r;
    return response;
  }

  @override
  Future<Response> head({Map<String, String> headers, Uri uri}) async {
    final r = await _send('HEAD', headers: headers, uri: uri);
    assert(r is Response, 'head() should return a Response');
    Response response = r;
    return response;
  }

  @override
  Future<Response> options({Map<String, String> headers, Uri uri}) async {
    final r = await _send('OPTIONS', headers: headers, uri: uri);
    assert(r is Response, 'options() should return a Response');
    Response response = r;
    return response;
  }

  @override
  Future<Response> patch(
      {dynamic body, Map<String, String> headers, Uri uri}) async {
    final r = await _send('PATCH', body: body, headers: headers, uri: uri);
    assert(r is Response, 'patch() should return a Response');
    Response response = r;
    return response;
  }

  @override
  Future<Response> post(
      {dynamic body, Map<String, String> headers, Uri uri}) async {
    final r = await _send('POST', body: body, headers: headers, uri: uri);
    assert(r is Response, 'post() should return a Response');
    Response response = r;
    return response;
  }

  @override
  Future<Response> put(
      {dynamic body, Map<String, String> headers, Uri uri}) async {
    final r = await _send('PUT', body: body, headers: headers, uri: uri);
    assert(r is Response, 'put() should return a Response');
    Response response = r;
    return response;
  }

  @override
  Future<Response> send(String method,
      {dynamic body, Map<String, String> headers, Uri uri}) async {
    final r = await _send(method, headers: headers, uri: uri);
    assert(r is Response, 'delete() should return a Response');
    Response response = r;
    return response;
  }

  @override
  Future<StreamedResponse> streamDelete(
      {Map<String, String> headers, Uri uri}) async {
    final r =
        await _send('DELETE', headers: headers, streamResponse: true, uri: uri);
    assert(r is StreamedResponse,
        'streamDelete() should return a StreamedResponse');
    StreamedResponse response = r;
    return response;
  }

  @override
  Future<StreamedResponse> streamGet(
      {Map<String, String> headers, Uri uri}) async {
    final r =
        await _send('GET', headers: headers, streamResponse: true, uri: uri);
    assert(
        r is StreamedResponse, 'streamGet() should return a StreamedResponse');
    StreamedResponse response = r;
    return response;
  }

  @override
  Future<StreamedResponse> streamHead(
      {Map<String, String> headers, Uri uri}) async {
    final r =
        await _send('HEAD', headers: headers, streamResponse: true, uri: uri);
    assert(
        r is StreamedResponse, 'streamHead() should return a StreamedResponse');
    StreamedResponse response = r;
    return response;
  }

  @override
  Future<StreamedResponse> streamOptions(
      {Map<String, String> headers, Uri uri}) async {
    final r = await _send('OPTIONS',
        headers: headers, streamResponse: true, uri: uri);
    assert(r is StreamedResponse,
        'streamOptions() should return a StreamedResponse');
    StreamedResponse response = r;
    return response;
  }

  @override
  Future<StreamedResponse> streamPatch(
      {dynamic body, Map<String, String> headers, Uri uri}) async {
    final r = await _send('PATCH',
        body: body, headers: headers, streamResponse: true, uri: uri);
    assert(r is StreamedResponse,
        'streamPatch() should return a StreamedResponse');
    StreamedResponse response = r;
    return response;
  }

  @override
  Future<StreamedResponse> streamPost(
      {dynamic body, Map<String, String> headers, Uri uri}) async {
    final r = await _send('POST',
        body: body, headers: headers, streamResponse: true, uri: uri);
    assert(
        r is StreamedResponse, 'streamPost() should return a StreamedResponse');
    StreamedResponse response = r;
    return response;
  }

  @override
  Future<StreamedResponse> streamPut(
      {dynamic body, Map<String, String> headers, Uri uri}) async {
    final r = await _send('PUT',
        body: body, headers: headers, streamResponse: true, uri: uri);
    assert(
        r is StreamedResponse, 'streamPut() should return a StreamedResponse');
    StreamedResponse response = r;
    return response;
  }

  @override
  Future<StreamedResponse> streamSend(String method,
      {dynamic body, Map<String, String> headers, Uri uri}) async {
    final r = await _send(method,
        body: body, headers: headers, streamResponse: true, uri: uri);
    assert(
        r is StreamedResponse, 'streamSend() should return a StreamedResponse');
    StreamedResponse response = r;
    return response;
  }

  @override
  Future<Response> retry() {
    _verifyCanRetryManually();
    return clone().send(method);
  }

  @override
  Future<StreamedResponse> streamRetry() {
    _verifyCanRetryManually();
    return clone().streamSend(method);
  }

  /// Determine if this request failure is eligible for retry.
  Future<bool> _canRetry(FinalizedRequest request, BaseResponse response,
      RequestException requestException) async {
    if (!autoRetry.enabled ||
        !autoRetry.supported ||
        autoRetry.didExceedMaxNumberOfAttempts) return false;

    // If the request was explicitly canceled, then there is no reason to retry.
    if (isCanceled) return false;

    // If the request failed due to exceeding the timeout threshold, check if
    // it is configured to retry for timeouts.
    if (requestException.error is TimeoutException) {
      return autoRetry.forTimeouts;
    }

    bool willRetry = autoRetry.forHttpMethods.contains(method);
    if (response != null && response.status != null) {
      willRetry =
          willRetry && autoRetry.forStatusCodes.contains(response.status);
    } else {
      willRetry = false;
    }
    if (autoRetry.test != null) {
      willRetry = await autoRetry.test(request, response, willRetry);
    }
    return willRetry;
  }

  /// Retry this request by creating and sending a clone.
  Future<BaseResponse> _retry(bool streamResponse) async {
    final retry = clone();
    return streamResponse ? retry.streamSend(method) : retry.send(method);
  }

  void _timeoutRequest() {
    if (!isCanceled) {
      abortRequest();
    }
    isTimedOut = true;
    _timeoutError = new TimeoutException(
        'Request took too long to complete.', timeoutThreshold);
    _timeoutCompleter.complete();
  }

  void _verifyCanRetryManually() {
    if (!isSent)
      throw new StateError(
          'Cannot retry a request that has not yet been sent.');
    if (!_done.isCompleted)
      throw new StateError(
          'Cannot retry a request that has not yet completed.');
    if (didSucceed)
      throw new StateError('Cannot retry a request that did not fail.');
  }

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
    autoRetry.numAttempts++;

    // Use a completer so that an exception can be wrapped in a RequestException
    // instance while still preserving the stack trace of the original error.
    final c = new Completer<BaseResponse>();

    this.method = method;
    if (uri != null) {
      this.uri = uri;
    }
    if (this.uri == null || this.uri.toString().isEmpty)
      throw new StateError('Request: Cannot send a request without a URI.');
    if (headers != null) {
      headers.forEach((key, value) {
        this.headers[key] = value;
      });
    }

    // Ensure non-null.
    streamResponse ??= false;

    // Apply the request interceptor if set.
    if (requestInterceptor != null) {
      await requestInterceptor(this);
      checkForCancellation();
      checkForTimeout();
    }

    // If this is a mock-aware request without an expectation or handler setup
    // to process it, switch to a real request.
    if (isMockAware &&
        MockTransportsInternal.fallThrough &&
        !MockHttpInternal.hasHandlerForRequest(
            this.method, this.uri, this.headers)) {
      return switchToRealRequest(streamResponse: streamResponse);
    }

    // Otherwise, carry on with the send logic and the mocks will do the rest.

    // No further changes should be made to the request at this point.
    final finalizedRequest = await finalizeRequest(body);
    checkForCancellation();
    checkForTimeout();

    BaseResponse response;
    bool responseInterceptorThrew = false;
    try {
      await openRequest(client);
      checkForCancellation();
      checkForTimeout();
      final responseCompleter = new Completer<BaseResponse>();

      // Enforce a timeout threshold if set.
      Timer timeout;
      if (timeoutThreshold != null) {
        timeout = new Timer(timeoutThreshold, _timeoutRequest);
      }

      // Attempt to fetch the response.
      // ignore: unawaited_futures
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

      // Listen for cancellation and request timeout and break out of the
      // response fetching early if it occurs before the request has finished.
      void breakOutOfResponseFetching(_) {
        if (!responseCompleter.isCompleted) {
          response = null;
          responseCompleter.complete();
        }
      }

      // ignore: unawaited_futures
      _cancellationCompleter.future.then(breakOutOfResponseFetching);
      // ignore: unawaited_futures
      _timeoutCompleter.future.then(breakOutOfResponseFetching);

      response = await responseCompleter.future;
      if (response == null) {
        checkForTimeout();
      }
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

      c.complete();
    } catch (e, stackTrace) {
      Object exception = e;
      if (exception is! RequestException) {
        exception =
            new RequestException(method, this.uri, this, response, exception);
      }
      RequestException requestException = exception;

      // Apply the response interceptor even in the event of failure, unless the
      // response interceptor was the cause of failure.
      if (responseInterceptor != null && !responseInterceptorThrew) {
        response = await responseInterceptor(
            finalizedRequest, response, requestException);
        requestException = new RequestException(
            method, this.uri, this, response, requestException.error);
      }

      // Store the failure for context.
      autoRetry.failures.add(requestException);

      // Attempt to retry the request if configuration and state permit it.
      bool retrySucceeded = false;
      if (await _canRetry(finalizedRequest, response, requestException)) {
        final retryCompleter = new Completer<BaseResponse>();

        // If retry back-off is configured, wait as necessary.
        final backOff = utils.calculateBackOff(autoRetry);

        if (backOff != null) {
          await new Future.delayed(backOff);
        }

        // ignore: unawaited_futures
        _retry(streamResponse).then((retryResponse) {
          if (!retryCompleter.isCompleted) {
            response = retryResponse;
            retrySucceeded = true;
            retryCompleter.complete();
          }
        }, onError: (retryError, retryStackTrace) {
          if (!retryCompleter.isCompleted) {
            requestException = retryError;
            // TODO: Combine stack trace from above with the retry stack trace?
            retryCompleter.complete();
          }
        });

        // Listen for cancellation and break out of the retry early if
        // cancellation occurs before the retry has finished.
        // ignore: unawaited_futures
        _cancellationCompleter.future.then((_) {
          if (!retryCompleter.isCompleted) {
            retryCompleter.complete();
          }
        });

        await retryCompleter.future;
        checkForCancellation(response: response);
      }

      retrySucceeded
          ? c.complete()
          : c.completeError(requestException, stackTrace);
    } finally {
      cleanUp();
      if (!_done.isCompleted) {
        _done.complete();
      }
    }
    await c.future;
    checkForCancellation(response: response);
    didSucceed = true;
    return response;
  }
}
