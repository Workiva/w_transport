library w_http_server.w_http_server;

// Dart imports
import 'dart:async';
import 'dart:convert';
import 'dart:io';

// Src imports
import 'w_http.dart';


class WHttp implements IWHttp {

  WHttp() {
    _client = new HttpClient();
    _headers = new Map<String, String>();
  }

  /**
   * Create a WHttp request with a pre-existing HttpClient instance.
   * The given HttpClient instance will be used instead of a new one.
   * WHttpClient uses this constructor.
   */
  WHttp._withClient(HttpClient client) {
    _client = client;
  }

  /**
   * HttpClient used to send the request.
   */
  HttpClient _client;

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
   * Add a callback used to prepare the outgoing HttpClientRequest before being sent.
   * Will be called just before sending the request. If the method returns a
   * Future, the request will not be sent until the Future resolves.
   */
  WHttp prepare(dynamic prepareRequest(HttpClientRequest request)) {
    _prepare = prepareRequest;
    return this;
  }

  /**
   * Send a DELETE request.
   */
  Future<WStreamedResponse> delete([Uri url]) {
    return _send('DELETE', url);
  }

  /**
   * Send a GET request.
   */
  Future<WStreamedResponse> get([Uri url]) {
    return _send('GET', url);
  }

  /**
   * Send a HEAD request.
   */
  Future<WStreamedResponse> head([Uri url]) {
    return _send('HEAD', url);
  }

  /**
   * Send an OPTIONS request.
   */
  Future<WStreamedResponse> options([Uri url]) {
    return _send('OPTIONS', url);
  }

  /**
   * Send a PATCH request.
   */
  Future<WStreamedResponse> patch([Uri url, Object data]) {
    return _send('PATCH', url, data);
  }

  /**
   * Send a POST request.
   */
  Future<WStreamedResponse> post([Uri url, Object data]) {
    return _send('POST', url, data);
  }

  /**
   * Send a PUT request.
   */
  Future<WStreamedResponse> put([Uri url, Object data]) {
    return _send('PUT', url, data);
  }

  /**
   * Send a TRACE request.
   */
  Future<WStreamedResponse> trace([Uri url]) {
    return _send('TRACE', url);
  }

  Future<WStreamedResponse> _send(String method, [Uri url, Object data]) {
    if (url != null) {
      this.url(url);
    }
    if (data != null) {
      this.data(data);
    }

    if (_url.toString() == null || _url.toString() == '') {
      throw new StateError('WHttp: Cannot send a request without a URL.');
    }

    // Use a Completer to drive this async response
    Completer<WStreamedResponse> completer = new Completer<WStreamedResponse>();

    // Attempt to open an HTTP connection
    _client.openUrl(method, _url).then((HttpClientRequest request) {
      // Add request headers
      _headers.forEach(request.headers.set);

      // Allow the caller to prepare the request
      dynamic prepare;
      if (_prepare != null) {
        prepare = _prepare(request);
      }

      // Write request data (if supplied) and send the request (waiting for prep if applicable)
      if (prepare != null && prepare is Future) {
        prepare.then((_) {
          _write(request, completer);
        });
      } else {
        _write(request, completer);
      }
    });

    return completer.future;
  }

  void _write(HttpClientRequest request, Completer<WStreamedResponse> completer) {
    // Write data (if supplied) to the HTTP server
    // Calling request.write() will begin sending the data immediately
    if (data != null) {
      request.contentLength = -1;
      request.write(_data);
    } else {
      request.contentLength = 0;
    }

    // Close the request now that data (if any) has been sent and wait for response
    request.close().then((HttpClientResponse response) {
      completer.complete(new _WStreamedResponse.fromHttpClientResponse(response));
    }).catchError(completer.completeError);
  }

}


abstract class WStreamedResponse extends IWResponse {

  Stream<List<int>> get stream;
  Future<List<int>> get data;
  Future<String> get utf8Text;

}

class _WStreamedResponse implements WStreamedResponse {

  /**
   * Create a streamed response from a completed HttpClientResponse.
   */
  _WStreamedResponse.fromHttpClientResponse(HttpClientResponse response) {
    _response = response;
    _headers = new Map<String, String>();
    _response.headers.forEach((String name, List<String> values) {
      _headers[name] = values.join(',');
    });
  }

  Map<String, String> _headers;
  HttpClientResponse _response;

  /**
   * The data received as a response from the request in the format of a
   * stream of chunks of bytes representing a single piece of data.
   *
   * Note: The underlying response stream is a single-subscription stream,
   * so if you listen to this stream, you will no longer be able to use the
   * `data` or `text` property on this WStreamedResponse.
   */
  Stream<List<int>> get stream => _response;

  /**
   * The data received as a response from the request in the format of a
   * list of chunks of bytes.
   *
   * Note: This listens to the underlying response stream, which is a single-
   * subscription stream, so if you use this property, you will no longer be
   * able to use the `text` property or listen to the `stream` on this
   * WStreamedResponse. This also means you should store the returned Future
   * instead of calling this multiple times.
   */
  Future<List<int>> get data {
    Completer<List<int>> completer = new Completer<List<int>>();
    List<int> bytes = [];

    _response.listen((List<int> chunk) {
      bytes.addAll(chunk);
    }, onDone: () {
      completer.complete(bytes);
    }, onError: completer.completeError);

    return completer.future;
  }

  /**
   * The data received as a response from the request decoded into a UTF8 String.
   *
   * Note: This listens to the underlying response stream, which is a single-
   * subscription stream, so if you use this property, you will no longer be
   * able to use the `data` property or listen to the `stream` on this
   * WStreamedResponse. This also means you shoudl store the returned Future
   * instead of calling this multiple times.
   */
  Future<String> get utf8Text => _response.transform(new Utf8Decoder()).join('');

  /**
   * Response headers as a key-value map.
   */
  Map<String, String> get headers => _headers;

  /**
   * The HTTP result code from the request (200, 404, etc).
   */
  int get status => _response.statusCode;

  /**
   * The HTTP result code and reason/phrase ("200 OK").
   */
  String get statusText => '${_response.statusCode} ${_response.reasonPhrase}';

}