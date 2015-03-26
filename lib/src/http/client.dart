library w_http_client.client;

// Dart imports
import 'dart:async';
import 'dart:html';

// Src imports
import 'transport.dart';
import 'w_http.dart';


/**
 * Configure WHttp for client-side usage.
 * This means dart:html.HttpRequest will be used to make the request.
 */
useClientConfiguration() {
  setWHttpConfiguration(() => new _ClientHttpTransport());
}

/**
 * ClientHttpTransport implements the common HttpTransport interface
 * and wraps dart:html.HttpRequest to send HTTP requests.
 */
class _ClientHttpTransport implements HttpTransport {

  /**
   * HttpRequest instance used to make the HTTP request.
   */
  HttpRequest _request;

  /**
   * Completer used to produce a future that completes when the request completes.
   */
  Completer _requestDone = new Completer();

  /**
   * Attempt to open a connection with an HTTP server at the given URL.
   * Also takes care of setting the request headers.
   */
  open(String method, Uri url, [Map<String, String> headers]) {
    // Create and open a new HttpRequest (XMLHttpRequest)
    _request = new HttpRequest();
    _request.open(method, url.toString());

    // Add request headers
    headers.forEach((String header, String value) {
      _request.setRequestHeader(header, value);
    });

    // TODO: Handle withCredentials
    // TODO: Add and expose progress listener

    // Listen for request completion
    _request.onReadyStateChange.listen((ProgressEvent event) {
      if (_request.readyState == HttpRequest.DONE) {
        _requestDone.complete();
      }
    });
  }

  /**
   * Send the HTTP request.
   * Must call open() first in order to establish the connection.
   */
  send([Object data]) {
    // Require a connection attempt before sending the request
    if (_request == null) {
      throw new StateError('WHttp: Cannot send data before the request has been opened.');
    }
    _request.send(data);
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
   * Could be one of the following:
   *  String
   *  ByteBuffer
   *  Document
   *  Blob
   *
   * `null` indicates a response failure.
   */
  Object get response => _request.response;

  /**
   * Response headers as a key-value map.
   * Unavailable until the request has completed and the response has been received.
   */
  Map<String, String> get responseHeaders => _request.responseHeaders;

  /**
   * The HTTP result code from the request (200, 404, etc).
   * Unavailable until the request has completed and the response has been received.
   */
  int get status => _request.status;

}