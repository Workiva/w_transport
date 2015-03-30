library w_http_client.w_http_client;

// Dart imports
import 'dart:async';
import 'dart:html';

// Src imports
import 'w_http.dart';


class WHttp implements IWHttp {

  WHttp() {
    _headers = new Map<String, String>();
    _withCredentials = false;
  }

  /**
   * URL to send the request to.
   */
  Uri _url;

  /**
   * Data object to write to the request.
   */
  Object _data;

  /**
   * Request headers.
   */
  Map<String, String> _headers;

  /**
   * Whether or not to send the request with credentials.
   */
  bool _withCredentials;

  /**
   * Progress listener.
   */
  Function _onProgress;

  /**
   * Function used by caller to perform additional request preparation.
   */
  Function _prepare;

  /**
   * Set the request URL.
   */
  WHttp url(Uri url) {
    _url = url;
    return this;
  }

  /**
   * Set the request data.
   */
  WHttp data(Object data) {
    _data = data;
    return this;
  }

  /**
   * Set multiple request headers.
   */
  WHttp headers(Map<String, String> headers) {
    _headers.addAll(headers);
    return this;
  }

  /**
   * Set a single request header.
   */
  WHttp header(String header, String value) {
    _headers[header] = value;
    return this;
  }

  /**
   * Set the withCredentials flag.
   */
  WHttp withCredentials() {
    _withCredentials = true;
    return this;
  }

  /**
   * Add a callback used to prepare the outgoing HttpRequest before being sent.
   * Will be called just before sending the request. If the method returns a
   * Future, the request will not be sent until the Future resolves.
   */
  WHttp prepare(dynamic prepareRequest(HttpRequest request)) {
    _prepare = prepareRequest;
    return this;
  }

  /**
   * Register a progress callback.
   */
  WHttp onProgress(void onProgress(ProgressEvent event)) {
    _onProgress = onProgress;
    return this;
  }

  /**
   * Send a DELETE request.
   */
  Future<WResponse> delete([Uri url]) {
    return _send('DELETE', url);
  }

  /**
   * Send a GET request.
   */
  Future<WResponse> get([Uri url]) {
    return _send('GET', url);
  }

  /**
   * Send a HEAD request.
   */
  Future<WResponse> head([Uri url]) {
    return _send('HEAD', url);
  }

  /**
   * Send an OPTIONS request.
   */
  Future<WResponse> options([Uri url]) {
    return _send('OPTIONS', url);
  }

  /**
   * Send a PATCH request.
   */
  Future<WResponse> patch([Uri url, Object data]) {
    return _send('PATCH', url, data);
  }

  /**
   * Send a POST request.
   */
  Future<WResponse> post([Uri url, Object data]) {
    return _send('POST', url, data);
  }

  /**
   * Send a PUT request.
   */
  Future<WResponse> put([Uri url, Object data]) {
    return _send('PUT', url, data);
  }

  /**
   * Send a TRACE request.
   */
  Future<WResponse> trace([Uri url]) {
    return _send('TRACE', url);
  }

  /**
   * Send an HTTP request using dart:html.HttpRequest.
   */
  Future<WResponse> _send(String method, [Uri url, Object data]) {
    if (url != null) {
      this.url(url);
    }
    if (data != null) {
      this.data(data);
    }

    if (this._url.toString() == null || this._url.toString() == '') {
      throw new StateError('WHttp: Cannot send a request without a URL.');
    }

    // Use a Completer to drive this async response
    Completer<WResponse> completer = new Completer<WResponse>();

    // Create and open a new HttpRequest (XMLHttpRequest)
    HttpRequest request = new HttpRequest();
    request.open(method, _url.toString());

    // Add request headers
    _headers.forEach(request.setRequestHeader);

    // Set the withCredentials flag if desired
    if (_withCredentials) {
      request.withCredentials = true;
    }

    // Add a progress listener if one was registered
    if (_onProgress != null) {
      request.onProgress.listen(_onProgress);
    }

    // Listen for request completion/errors
    request.onLoad.listen((ProgressEvent e) {
      if ((request.status >= 200 && request.status < 300) ||
          request.status == 0 || request.status == 304) {
        completer.complete(new _WResponse.fromHttpRequest(request));
      } else {
        completer.completeError(e);
      }
    });
    request.onError.listen(completer.completeError);

    // Allow the caller to prepare the request
    dynamic prepare;
    if (_prepare != null) {
      prepare = _prepare(request);
    }

    // Send the HTTP request (waiting for the preparation to complete, if applicable)
    if (prepare != null && prepare is Future) {
      prepare.then((_) {
        request.send(_data);
      });
    } else {
      request.send(_data);
    }

    return completer.future;
  }

}


abstract class WResponse extends IWResponse {

  Object get data;
  String get text;
  Stream get stream;

}


class _WResponse implements WResponse {

  /**
   * Create a response from a completed HttpRequest.
   */
  _WResponse.fromHttpRequest(HttpRequest request) {
    _request = request;
    _stream = new Stream.fromIterable([data]);
  }

  HttpRequest _request;
  Stream _stream;

  /**
   * The data received as a response from the request.
   *
   * Could be one of the following:
   *  String
   *  ByteBuffer
   *  Document
   *  Blob
   *
   * `null` indicates a response failure.
   */
  Object get data => _request.response;

  /**
   * The data received as a response from the request in String format.
   */
  String get text => _request.responseText;

  /**
   * The data received as a response from the request in Stream format.
   * Stream will always only contain one element.
   */
  Stream get stream => _stream;

  /**
   * Response headers as a key-value map.
   */
  Map<String, String> get headers => _request.responseHeaders;

  /**
   * The HTTP result code from the request (200, 404, etc).
   */
  int get status => _request.status;

  /**
   * The HTTP result code and reason/phrase ("200 OK").
   */
  String get statusText => _request.statusText;

}