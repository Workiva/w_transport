library  w_http.http;

// Dart imports
import 'dart:async';

// Src imports
import '../../w_url.dart';
import 'transport.dart';


// TODO: Find a way to expose the underlying HttpRequest/HttpClient/HttpClientRequest/HttpClientResponse
//       Idea - have futures return the underlying http objects (HttpRequest or HttpClientRequest/HttpClientResponse),
//              consumer would still have reference to WHttp instance to get response/headers/status, but would also
//              have access to anything else on the actual request instance if needed.
//              Would require the addition of "openMETHOD()" and "send()" methods where "METHOD()" is concatenation of both,
//              so that the consumer can hook into the underlying request before dispatch.
//
//  Client API:
//    Future<HttpRequest> openGet([Uri url]);
//    Future<HttpRequest> get([Uri url]);
//    Future<HttpRequest> send();
//
//  Client Usage:
//    // standard request
//    var http = new WHttp();
//    http.get('/test').then((HttpRequest req /* this arg could be ignored in most cases */) {
//      // Access to response, headers, and status through the top-level `http` instance
//      http.response;
//      http.responseHeaders;
//      http.status;
//      // Also have access to anything on the underlying HttpRequest instance
//      req.responseText;
//    });
//
//    // special request, need to hook into request before dispatch
//    var http = new WHttp();
//    http.openGet('/test').then((HttpRequest req) {
//      // Access to HttpRequest instance before request is sent
//      req.withCredentials = true;
//      // Send request when ready
//      http.send();
//    });
//
//    // listen to `done` flag to avoid nested futures
//    http.done.then((HttpRequest req) {
//      // Again, access to main props through `http` instance, but also
//      // have access to anything on the underlying HttpRequest
//    });
//
//  Server API:
//    Future<HttpClientRequest> openGet([Uri url]);
//    Future<HttpClientResponse> get([Uri url]);
//    Future<HttpClientResponse> send();
//
//  Server Usage:
//    // standard request
//    var http = new WHttp();
//    http.get('/test').then((HttpClientResponse resp /* this arg could be ignored in most cases */) {
//      // Access to response, headers, and status through the top-level `http` instance
//      http.response;
//      http.responseHeaders;
//      http.status;
//      // Also have access to anything on the underlying HttpClientResponse instance
//      resp.redirects;
//    });
//
//    // special request, need to hook into request before dispatch
//    var http = new WHttp();
//    http.openGet('/test').then((HttpClientRequest req) {
//      // Access to HttpClientRequest instance before request is sent
//      req.addStream(...).then((_) {
//        // Send request when ready
//        http.send();
//      });
//    });
//
//    // listen to `done` flag to avoid nested futures
//    http.done.then((HttpClientResponse resp) {
//      // Again, access to main props through `http` instance, but also
//      // have access to anything on the underlying HttpClientResponse
//    });




/**
 * The transport factory that will be used by WHttp.
 * Should be configured before using the default WHttp constructor.
 */
HttpTransportFactory _wHttpTransportFactory;

/**
 * Set the WHttp transport configuration by supplying a
 * transport factory that will produce an HttpTransport instance.
 *
 * This is called by:
 *  - w_http_client.useClientConfiguration()
 *  - w_http_server.useServerConfiguration()
 */
setWHttpConfiguration(HttpTransportFactory transportFactory) {
  _wHttpTransportFactory = transportFactory;
}

/**
 * WHttp provides a single API for sending HTTP requests.
 * It has no explicit dependency on dart:html or dart:io,
 * such that it can be used in either a client app or a
 * server app. This design decision allows the consumer
 * to make the decision between client and server.
 *
 * As such, a consumer must do one of the following before using WHttp:
 *  1) Client
 *      import 'package:w_http/w_http_client.dart' as w_http_client;
 *      w_http_client.useClientConfiguration();
 *
 *  2) Server
 *      import 'package:w_http/w_http_server.dart' as w_http_server;
 *      w_http_server.useServerConfiguration();
 *
 * Behind the scenes, this just sets the HttpTransportFactory that
 * WHttp will use. The client configuration supplies a factory that
 * produces a wrapper around dart:html.HttpRequest, and the server
 * configuration supplies a factory that produces a wrapper around
 * dart:io.HttpClient and dart:io.HttpClientRequest.
 *
 * If desired, a consumer could call setWHttpConfiguration with their
 * own HttpTransportFactory instance. Alternatively, the
 * WHttp.usingTransport() constructor can be used.
 */
class WHttp extends UrlBased {

  /**
   * Construct a new WHttp instance to make an HTTP request.
   *
   * Requires that a WHttp transport factory has been set by importing
   * either the client or server portion of this lib and calling the
   * appropriate configuration method, or by setting it manually.
   */
  WHttp() {
    if (_wHttpTransportFactory == null) {
      throw new StateError('WHttp: No HttpTransportFactory has been set. You must either:\n' +
        '\timport \'w_http/w_http_client\' and call setClientConfiguration(), or\n' +
        '\timport \'w_http/w_http_server\' and call setServerConfiguration()\n' +
        'Alternatively, you can use the WHttp.usingTransport() constructor.');
    }

    _transportFactory = _wHttpTransportFactory;
    _transport = null;
  }

  /**
   * Construct a new WHttp instance to make an HTTP request using
   * an explicitly provided transport factory.
   */
  WHttp.usingTransport(HttpTransportFactory transportFactory) {
    _transportFactory = transportFactory;
    _transport = null;
  }

  /**
   * Data object to write to the request.
   */
  Object _data = null;

  /**
   * Request headers.
   */
  Map<String, String> _headers = new Map<String, String>();

  /**
   * Transport factory to use when constructing new requests.
   */
  HttpTransportFactory _transportFactory;

  /**
   * Transport instance used to actually dispatch the HTTP request.
   */
  HttpTransport _transport;

  /**
   * Set the request headers. Will overwrite all existing headers.
   */
  void set headers(Map<String, String> headers) { _headers = headers; }

  /**
   * Set a single request header.
   */
  void header(String header, String value) {
    _headers[header] = value;
  }

  /**
   * Set the request data.
   */
  void set data(Object data) {
    _data = data;
  }

  /**
   * Send a DELETE request.
   */
  Future<WHttp> delete([Uri url]) {
    return _send('DELETE', url);
  }

  /**
   * Send a GET request.
   */
  Future<WHttp> get([Uri url]) {
    return _send('GET', url);
  }

  /**
   * Send a HEAD request.
   */
  Future<WHttp> head([Uri url]) {
    return _send('HEAD', url);
  }

  /**
   * Send an OPTIONS request.
   */
  Future<WHttp> options([Uri url]) {
    return _send('OPTIONS', url);
  }

  /**
   * Send a PATCH request.
   */
  Future<WHttp> patch([Uri url, Object data]) {
    return _send('PATCH', url, data);
  }

  /**
   * Send a POST request.
   */
  Future<WHttp> post([Uri url, Object data]) {
    return _send('POST', url, data);
  }

  /**
   * Send a PUT request.
   */
  Future<WHttp> put([Uri url, Object data]) {
    return _send('PUT', url, data);
  }

  /**
   * Send a TRACE request.
   */
  Future<WHttp> trace([Uri url]) {
    return _send('TRACE', url);
  }

  /**
   * Use the transport factory to create a new HttpTransport instance
   * and use it to dispatch the HTTP request.
   */
  Future<WHttp> _send(String method, [Uri url, Object data]) {
    if (url != null) {
      this.url = url;
    }
    if (data != null) {
      this.data = data;
    }

    if (this.url.toString() == null || this.url.toString() == '') {
      throw new StateError('WHttp: Cannot send a request without a URL.');
    }

    _transport = _transportFactory();
    _transport.open(method, this.url, this._headers);
    _transport.send(this._data);

    Completer<WHttp> completer = new Completer<WHttp>();
    _transport.done.then((_) {
      completer.complete(this);
    });
    return completer.future;
  }

  // TODO: Add `done` future
  // Future get done => ...

  /**
   * The data received as a response from the request.
   * Unavailable until the request has completed and the response has been received.
   *
   *
   */
  Object get response => _transport != null ? _transport.response : null;

  /**
   * Response headers as a key-value map.
   * Unavailable until the request has completed and the response has been received.
   */
  Map<String, String> get responseHeaders => _transport != null ? _transport.responseHeaders : null;

  /**
   * The HTTP result code from the request (200, 404, etc).
   * Unavailable until the request has completed and the response has been received.
   */
  int get status => _transport != null ? _transport.status : null;
}