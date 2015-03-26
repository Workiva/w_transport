library w_transport.src.http.w_http_client;

import 'dart:async';
import 'dart:html';

import 'package:w_transport/w_url.dart' show UrlMutation;
import './w_http.dart';


/// Client-side implementation of an HTTP transport.
/// Uses dart:html.HttpRequest (XMLHttpRequest).
class WRequest extends UrlMutation implements WTransportRequest {
  HttpRequest _request;

  /// Data to send with the HTTP request.
  Object _data;
  Object get data => _data;
  void set data(Object data) {
    if (data is! String && data is! FormData) {
      throw new ArgumentError('WRequest body must be a String or a FormData.');
    }
    _data = data;
  }

  /// Headers to send with the HTTP request.
  Map<String, String> headers = {};

  /// Whether or not to send the request with credentials.
  bool withCredentials = false;

  /// dart:html.ProgressEvent stream for this HTTP request's upload.
  StreamController<ProgressEvent> _uploadProgressController = new StreamController<ProgressEvent>();
  Stream<ProgressEvent> get uploadProgress => _uploadProgressController.stream;

  /// dart:html.ProgressEvent stream for this HTTP request's download.
  StreamController<ProgressEvent> _downloadProgressController = new StreamController<ProgressEvent>();
  Stream<ProgressEvent> get downloadProgress => _downloadProgressController.stream;

  /// Register a callback that will be called after opening, but prior to sending,
  /// the request. The supplied [configure] callback will be called with the
  /// dart:html.HttpRequest instance. If the [configure] callback returns a
  /// Future, the request will not be sent until the returned Future completes.
  Function _configure;
  void configure(configure(HttpRequest request)) { _configure = configure; }

  /// Cancel the request. If the request has already finished, this will do nothing.
  void abort() {
    if (_request == null) {
      throw new StateError('Can\'t cancel a request that has not yet been opened.');
    }
    _request.abort();
  }

  // TODO: Should we expose an onAbort method here? Or an onAbort stream?

  /// Send a DELETE request.
  Future<WResponse> delete([Uri url]) {
    return _send('DELETE', url);
  }

  /// Send a GET request.
  Future<WResponse> get([Uri url]) {
    return _send('GET', url);
  }

  /// Send a HEAD request.
  Future<WResponse> head([Uri url]) {
    return _send('HEAD', url);
  }

  /// Send an OPTIONS request.
  Future<WResponse> options([Uri url]) {
    return _send('OPTIONS', url);
  }

  /// Send a PATCH request.
  Future<WResponse> patch([Uri url, Object data]) {
    return _send('PATCH', url, data);
  }

  /// Send a POST request.
  Future<WResponse> post([Uri url, Object data]) {
    return _send('POST', url, data);
  }

  /// Send a PUT request.
  Future<WResponse> put([Uri url, Object data]) {
    return _send('PUT', url, data);
  }

  /// Send an HTTP request using dart:html.HttpRequest.
  Future<WResponse> _send(String method, [Uri url, Object data]) async {
    if (url != null) {
      this.url = url;
    }
    if (data != null) {
      this.data = data;
    }

    if (this.url == null || this.url.toString() == null || this.url.toString() == '') {
      throw new StateError('WRequest: Cannot send a request without a URL.');
    }

    // Use a Completer to drive this async response.
    Completer<WResponse> completer = new Completer<WResponse>();

    // Create and open a new HttpRequest (XMLHttpRequest).
    _request = new HttpRequest();
    _request.open(method, this.url.toString());

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
          _request.status == 0 || _request.status == 304) {
        completer.complete(response);
      } else {
        String errorMessage = 'Failed: $method ${url} ${response.status} (${response.statusText})';
        completer.completeError(new WHttpException(errorMessage, url, response));
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
abstract class WResponse implements Stream<String>, WTransportResponse {
  /// The data received as a response from the request.
  ///
  /// Could be one of the following:
  /// * String
  /// * ByteBuffer
  /// * Document
  /// * Blob
  ///
  /// `null` indicates a response failure.
  Object get data;

  /// The data received as a response from the request in String format.
  String get text;
}


/// Internal implementation of a response to a client-side HTTP request.
/// By making the above abstract class public and this implementation private,
/// the class structure can be public without exposing the constructor, since
/// it will only be used internally.
class _WResponse extends Stream<String> implements WResponse {
  HttpRequest _request;
  Stream _stream;

  /// Create a response from a completed dart:html.HttpRequest.
  _WResponse.fromHttpRequest(HttpRequest request) {
    _request = request;
    _stream = new Stream.fromIterable([data]);
  }

  /// Make the data available via a stream for convenience.
  StreamSubscription<String> listen(void onData(String event),
                                    { Function onError,
                                      void onDone(),
                                      bool cancelOnError}) {
    return _stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  Map<String, String> get headers => _request.responseHeaders;
  int get status => _request.status;
  String get statusText => _request.statusText;
  Object get data => _request.response;
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
  final Uri url;

  WHttpException(this.message, [this.url, this.response]);
}