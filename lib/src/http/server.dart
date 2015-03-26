library w_http_server.server;

// Dart imports
import 'dart:async';
import 'dart:convert';
import 'dart:io';

// Src imports
import 'transport.dart';
import 'w_http.dart';


/**
 * Configure WHttp for server-side usage.
 * This means dart:io.HttpClient and dart:io.HttpClientRequest
 * will be used to make the request.
 */
useServerConfiguration() {
  setWHttpConfiguration(() => new _ServerHttpTransport());
}

/**
 * Cache the HttpClient instance since it can open multiple connections.
 */
HttpClient _client;

/**
 * ServerHttpTransport implements the common HttpTransport interface
 * and wraps dart:io.HttpClient and dart:io.HttpClientRequest to
 * send HTTP requests.
 */
class _ServerHttpTransport implements HttpTransport {

  /**
   * Future that will complete once the HttpClient instance has successfully
   * opened the request. Will produce an error if connection fails.
   */
  Future<HttpClientRequest> _requestOpen;

  /**
   * Completer used to produce a future that completes when the request completes.
   */
  Completer _requestDone = new Completer();

  /**
   * The data received as a response from the request.
   */
  Object _response;

  /**
   * Response headers as a key-value map.
   */
  Map<String, String> _responseHeaders = new Map<String, String>();

  /**
   * The HTTP result code from the request (200, 404, etc).
   */
  int _status;

  /**
   * Attempt to open a connection with an HTTP server at the given URL.
   * Also takes care of setting the request headers.
   */
  void open(String method, Uri url, [Map<String, String> headers]) {
    // Create a new HttpClient if we don't already have one established
    // TODO: Handle crashes/closing and reestablishment
    // TODO: Close HttpClient instance when finished (how?)
    if (_client == null) {
      _client = new HttpClient();
    }

    // Attempt to open an HTTP connection
    _requestOpen = _client.openUrl(method, url);

    // Add request headers once the connection has been established
    if (headers != null) {
      _requestOpen.then((HttpClientRequest request) {
        headers.forEach((String header, String value) {
          request.headers.set(header, value);
        });
      });
    }
  }

  /**
   * Send the HTTP request.
   * Must call open() first in order to establish the connection.
   */
  void send([Object data]) {
    // Require an connection attempt before sending the request
    if (_requestOpen == null) {
      throw new StateError('WHttp: Cannot send data before the request has been opened.');
    }

    _requestOpen.then((HttpClientRequest request) {
      // Write data (if supplied) to the HTTP server
      // Calling request.write(data) will begin sending the data immediately
      if (data != null) {
        request.write(data);
      }

      // Close the request now that data (if any) has been sent and wait for response
      request.close().then((HttpClientResponse response) {

        // Parse the response header values into comma-delimited strings
        response.headers.forEach((String name, List<String> values) {
          _responseHeaders[name] = values.join(', ');
        });

        // Grab the response status code
        _status = response.statusCode;

        // Listen for and store the response body
        // TODO: Probably not a safe assumption to use a Utf8Decoder by default here
        // TODO: Idea - allow a list of transforms to be specified by consumer
        response.transform(new Utf8Decoder()).listen((Object contents) {
          // TODO: Determine whether there are actually multiple elements in the HttpClientResponse
          // TODO: stream, or if the entire response body comes in one stream update
          _response = contents;
        }, onDone: () {
          // Response has been read in full - request is now complete
          _requestDone.complete();
        });
      });
    });
  }

  /**
   * Future that will resolve when the request has completed and a response has been received.
   * Will produce an error if the request failed.
   */
  Future get done => _requestDone.future;

  /**
   * The data received as a response from the request.
   * Unavailable until the request has completed and the response has been received.
   *
   * TODO: Figure out what the response data looks like here.
   */
  Object get response => _response;

  /**
   * Response headers as a key-value map.
   * Unavailable until the request has completed and the response has been received.
   */
  Map<String, String> get responseHeaders => _responseHeaders;

  /**
   * The HTTP result code from the request (200, 404, etc).
   * Unavailable until the request has completed and the response has been received.
   */
  int get status => _status;

}

