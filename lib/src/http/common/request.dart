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

abstract class CommonRequest extends Object with FluriMixin implements BaseRequest, RequestDispatchers {
  CommonRequest();
  CommonRequest.withClient(client) : this.client = client;

  /// TODO
  dynamic client;

  /// Configuration callback for advanced request configuration.
  /// See [configure].
  Function configureFn;

  /// Default content-type. This will depend on the type of request and should
  /// be implemented by the subclasses.
  MediaType get defaultContentType;

  /// [RequestProgress] stream controller for this HTTP request's download.
  StreamController<RequestProgress> downloadProgressController =
      new StreamController<RequestProgress>();

  /// Whether or not the request has been canceled by the caller.
  bool isCanceled = false;

  /// Whether or not the request has been sent.
  bool isSent = false;

  /// HTTP method ('GET', 'POST', etc).
  String method;

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
    throw new UnsupportedError('The content-length of a request cannot be set manually when the request body is known in advance.');
  }

  /// Content-type of this request. Set automatically based on the body type and
  /// the [encoding].
  MediaType get contentType => _contentType != null ? _contentType : defaultContentType;

  /// Set the content-type of this request. Used to update the charset
  /// parameter when the encoding changes.
  set contentType(MediaType contentType) {
    _contentType = contentType;
  }

  /// Future that resolves when the request has completed (successful or
  /// otherwise).
  Future<Null> get done => _done.future;

  /// [RequestProgress] stream for this HTTP request's download.
  Stream<RequestProgress> get downloadProgress
      => downloadProgressController.stream;

  /// Encoding to use to encode/decode the request body.
  Encoding get encoding => _encoding;

  /// Set the encoding to use to encode/decode the request body. Setting this
  /// will update the [contentType] `charset` parameter.
  set encoding(Encoding encoding) {
    verifyUnsent();
    _encoding = encoding;
    contentType = contentType.change(parameters: {'charset': encoding.name});
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

  /// [RequestProgress] stream for this HTTP request's upload.
  Stream<RequestProgress> get uploadProgress
      => uploadProgressController.stream;

  /// Whether or not to send the request with credentials.
  bool get withCredentials => _withCredentials;

  /// Set the withCredentials flag, determining whether or not the request
  /// will include credentials (secure cookies).
  set withCredentials(bool flag) {
    verifyUnsent();
    _withCredentials = flag;
  }

  void abortRequest();

  void cleanUp() {}

  BaseHttpBody finalizeBody([body]);

  Future openRequest([client]);

  Future<BaseResponse> sendRequestAndFetchResponse(FinalizedRequest finalizedRequest, {bool streamResponse: false});

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

  void checkForCancellation({Response response}) {
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

  Map<String, String> finalizeHeaders() {
    headers['content-type'] = contentType.toString();
    return new Map.unmodifiable(headers);
  }

  /// Freeze this request in preparation of it being sent. This freezes all
  /// fields, preventing further unexpected modification, and triggers the
  /// creation of a finalized request body.
  FinalizedRequest finalizeRequest([body]) {
    Map<String, String> finalizedHeaders = finalizeHeaders();
    BaseHttpBody finalizedBody = finalizeBody(body);
    FinalizedRequest finalizedRequest = new FinalizedRequest(method, uri, finalizedHeaders, finalizedBody, withCredentials);

    if (isSent) throw new StateError('Request (${this.toString()}) has already been sent - it cannot be sent again.');
    isSent = true;

    return finalizedRequest;
  }

  @override
  String toString() => '$method $uri';

  /// Verify that this request has not yet been sent. Once it has, all fields
  /// should be considered frozen. If this request has been sent, this throws
  /// a [StateError].
  void verifyUnsent() {
    if (isSent) throw new StateError('Request (${this.toString()}) has already been sent and can no longer be modified.');
  }

  /// TODO
  Future<Response> delete({Map<String, String> headers, Uri uri}) => _send('DELETE', headers: headers, uri: uri);

  /// TODO
  Future<Response> get({Map<String, String> headers, Uri uri}) => _send('GET', headers: headers, uri: uri);

  /// TODO
  Future<Response> head({Map<String, String> headers, Uri uri}) => _send('HEAD', headers: headers, uri: uri);

  /// TODO
  Future<Response> options({Map<String, String> headers, Uri uri}) => _send('OPTIONS', headers: headers, uri: uri);

  /// TODO
  Future<Response> patch({body, Map<String, String> headers, Uri uri}) => _send('PATCH', body: body, headers: headers, uri: uri);

  /// TODO
  Future<Response> post({body, Map<String, String> headers, Uri uri}) => _send('POST', body: body, headers: headers, uri: uri);

  /// TODO
  Future<Response> put({body, Map<String, String> headers, Uri uri}) => _send('PUT', body: body, headers: headers, uri: uri);

  /// TODO
  Future<Response> trace({Map<String, String> headers, Uri uri}) => _send('TRACE', headers: headers, uri: uri);

  /// TODO
  Future<Response> send(String method, {body, Map<String, String> headers, Uri uri}) => _send(method, headers: headers, uri: uri);

  /// TODO
  Future<StreamedResponse> streamDelete({Map<String, String> headers, Uri uri}) => _send('DELETE', headers: headers, streamResponse: true, uri: uri);

  /// TODO
  Future<StreamedResponse> streamGet({Map<String, String> headers, Uri uri}) => _send('GET', headers: headers, streamResponse: true, uri: uri);

  /// TODO
  Future<StreamedResponse> streamHead({Map<String, String> headers, Uri uri}) => _send('HEAD', headers: headers, streamResponse: true, uri: uri);

  /// TODO
  Future<StreamedResponse> streamOptions({Map<String, String> headers, Uri uri}) => _send('OPTIONS', headers: headers, streamResponse: true, uri: uri);

  /// TODO
  Future<StreamedResponse> streamPatch({body, Map<String, String> headers, Uri uri}) => _send('PATCH', body: body, headers: headers, streamResponse: true, uri: uri);

  /// TODO
  Future<StreamedResponse> streamPost({body, Map<String, String> headers, Uri uri}) => _send('POST', body: body, headers: headers, streamResponse: true, uri: uri);

  /// TODO
  Future<StreamedResponse> streamPut({body, Map<String, String> headers, Uri uri}) => _send('PUT', body: body, headers: headers, streamResponse: true, uri: uri);

  /// TODO
  Future<StreamedResponse> streamTrace({Map<String, String> headers, Uri uri}) => _send('TRACE', headers: headers, streamResponse: true, uri: uri);

  /// TODO
  Future<StreamedResponse> streamSend(String method, {body, Map<String, String> headers, Uri uri}) => _send(method, body: body, headers: headers, streamResponse: true, uri: uri);

  Future<BaseResponse> _send(String method, {body, Map<String, String> headers, bool streamResponse, Uri uri}) async {
    this.method = method;
    if (uri != null) {
      this.uri = uri;
    }
    if (this.uri == null || this.uri.toString().isEmpty) throw new StateError('Request: Cannot send a request without a URI.');

    FinalizedRequest finalizedRequest = finalizeRequest(body);
    checkForCancellation();

    BaseResponse response;
    try {
      await openRequest(client);
      checkForCancellation();
      Completer<BaseResponse> responseCompleter = new Completer();

      // Attempt to fetch the response.
      sendRequestAndFetchResponse(finalizedRequest, streamResponse: streamResponse).then((response) {
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

      if (response.status != 0 &&
          response.status != 304 &&
          !(response.status >= 200 && response.status < 300)) {
        throw new RequestException(method, this.uri, this, response);
      }
    } catch (e) {
      var error = e;
      if (!_done.isCompleted) {
        _done.complete();
      }
      cleanUp();
      checkForCancellation(response: response);
      if (error is! RequestException) {
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