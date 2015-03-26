library w_http.transport;

// Dart imports
import 'dart:async';


/**
 * Factory that produces an HttpTransport instance.
 * Used by WHttp to retrieve a dynamic transport piece that will
 * actually send the HTTP request.
 *
 * Doing this allows WHttp to be client/server agnostic.
 */
typedef HttpTransport HttpTransportFactory();


/**
 * Client/server agnostic transport interface that when implemented,
 * must be able to open a connection with an HTTP server and send
 * an HTTP request to it, exposing the response once complete.
 */
abstract class HttpTransport {

  /**
   * Attempt to open a connection with an HTTP server at the given URL.
   * Also takes care of setting the request headers.
   */
  void open(String method, Uri url, [Map<String, String> headers]);

  /**
   * Send the HTTP request.
   * Must call open() first in order to establish the connection.
   */
  void send([Object data]);

  /**
   * Future that should resolve when the request has completed and a response has been received.
   * Should produce an error if the request failed.
   */
  Future get done;

  /**
   * Response properties that should be available once the `done` future completes.
   */
  Object get response;
  Map<String, String> get responseHeaders;
  int get status;

}
