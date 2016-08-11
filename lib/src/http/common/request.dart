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
import 'package:w_transport/src/http/common/backoff.dart';

abstract class CommonRequest extends Object
    with FluriMixin
    implements BaseRequest, RequestDispatchers {
  CommonRequest() {
    autoRetry = new RequestAutoRetry(this);
  }

  CommonRequest.fromClient(Client wTransportClient, client)
      : this._wTransportClient = wTransportClient,
        this.client = client {
    autoRetry = new RequestAutoRetry(this);
  }

  /// Configuration of automatic request retrying for failed requests. Use this
  /// object to enable or disable automatic retrying, configure the criteria
  /// that determines whether or not a request should be retried, as well as the
  /// number of retries to attempt.
  RequestAutoRetry autoRetry;

  /// The underlying HTTP client instance. In the browser, this will be null
  /// because there is no HTTP client API available. In the VM, this will be an
  /// instance of `dart:io.HttpClient`.
  ///
  /// If this is not null, it should be used to open and send the HTTP request.
  dynamic client;

  /// Configuration callback for advanced request configuration.
  /// See [configure].
  Function configureFn;

  /// Whether or not the request has completed successfully.
  bool didSucceed = false;

  /// [RequestProgress] stream controller for this HTTP request's download.
  StreamController<RequestProgress> downloadProgressController =
      new StreamController<RequestProgress>();

  /// Whether or not the request has been canceled by the caller.
  bool isCanceled = false;

  /// Whether or not the request has been sent.
  bool isSent = false;

  /// Whether or not the request timed out.
  bool isTimedOut = false;

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

  /// Whether or not the content-type was set manually. If `false`, the
  /// content-type will continue to be updated automatically when the [encoding]
  /// is set/changed. If `true`, the content-type will be left alone.
  bool _contentTypeSetManually = false;

  /// Completer that should complete when the request has finished (successful
  /// or otherwise).
  Completer<Null> _done = new Completer();

  /// Request body encoding.
  Encoding _encoding = UTF8;

  /// Request headers. Stored in a case-insensitive map since HTTP headers are
  /// case-insensitive.
  CaseInsensitiveMap<String> _headers = new CaseInsensitiveMap();

  /// Completes only when a request times out.
  Completer _timeoutCompleter = new Completer();

  /// Error associated with a cancellation.
  Object _timeoutError;

  /// Whether or not to send the request with credentials.
  bool _withCredentials = false;

  /// [Client] instance from which this request was created. Used in [clone] to
  /// correctly tie the clone to the same client.
  Client _wTransportClient;

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

  /// Manually set the content-type for this request.
  ///
  /// NOTE: By default, the content-type will be set automatically based on the
  /// request type and the [encoding]. Once you set the content-type manually,
  /// we assume you are intentionally overriding this behavior and the
  /// content-type will no longer be updated when [encoding] changes.
  set contentType(MediaType contentType) {
    verifyUnsent();
    _contentTypeSetManually = true;
    updateContentType(contentType);
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
    if (encoding == null) throw new ArgumentError.notNull('encoding');
    _encoding = encoding;
    if (!_contentTypeSetManually) {
      updateContentType(
          contentType.change(parameters: {'charset': encoding.name}));
    }
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

  /// Returns `true` if this request is complete (successful or failed), `false`
  /// otherwise.
  bool get isDone => isCanceled || _done.isCompleted;

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

  /// Cancel this request. If the request has already finished, this will do
  /// nothing.
  void abort([Object error]) {
    if (isCanceled) return;
    isCanceled = true;

    abortRequest();
    _cancellationError = error;
    _cancellationCompleter.complete();
  }

  /// Check if this request has been canceled.
  void checkForCancellation({BaseResponse response}) {
    if (isCanceled) {
      var error = new RequestException(
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
  BaseRequest clone() {
    // StreamedRequests can't be cloned.
    if (this is StreamedRequest) return null;

    BaseRequest requestClone;
    bool fromClient = _wTransportClient != null;
    if (this is FormRequest) {
      requestClone =
          fromClient ? _wTransportClient.newFormRequest() : new FormRequest();
    } else if (this is JsonRequest) {
      requestClone =
          fromClient ? _wTransportClient.newJsonRequest() : new JsonRequest();
    } else if (this is MultipartRequest) {
      requestClone = fromClient
          ? _wTransportClient.newMultipartRequest()
          : new MultipartRequest();
    } else if (this is Request) {
      requestClone =
          fromClient ? _wTransportClient.newRequest() : new Request();
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
  String toString() => '$runtimeType: $method $uri ($contentType)';

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

  Future<Response> retry() {
    _verifyCanRetryManually();
    return clone().send(method);
  }

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
    BaseRequest retry = clone();
    return streamResponse ? retry.streamSend(method) : retry.send(method);
  }

  void _timeoutRequest() {
    abortRequest();
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
    Completer c = new Completer();

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
    streamResponse = streamResponse == true;

    // Apply the request interceptor if set.
    if (requestInterceptor != null) {
      await requestInterceptor(this);
      checkForCancellation();
      checkForTimeout();
    }

    // No further changes should be made to the request at this point.
    FinalizedRequest finalizedRequest = await finalizeRequest(body);
    checkForCancellation();
    checkForTimeout();

    BaseResponse response;
    bool responseInterceptorThrew = false;
    try {
      await openRequest(client);
      checkForCancellation();
      checkForTimeout();
      Completer<BaseResponse> responseCompleter = new Completer();

      // Enforce a timeout threshold if set.
      Timer timeout;
      if (timeoutThreshold != null) {
        timeout = new Timer(timeoutThreshold, _timeoutRequest);
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

      // Listen for cancellation and request timeout and break out of the
      // response fetching early if it occurs before the request has finished.
      void breakOutOfResponseFetching(_) {
        if (!responseCompleter.isCompleted) {
          response = null;
          responseCompleter.complete();
        }
      }

      _cancellationCompleter.future.then(breakOutOfResponseFetching);
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
      var requestException = e;
      if (requestException is! RequestException) {
        requestException = new RequestException(
            method, this.uri, this, response, requestException);
      }

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
        Completer<BaseResponse> retryCompleter = new Completer();

        // If retry back-off is configured, wait as necessary.
        Duration backOff = Backoff.calculateBackOff(autoRetry);

        if (backOff != null) {
          await new Future.delayed(backOff);
        }

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
