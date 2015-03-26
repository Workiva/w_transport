library w_transport.src.http.w_http;

import 'dart:async';

import 'package:w_transport/w_url.dart';


/// Abstract transport class for HTTP requests used internally to
/// define the contract that must be fulfilled by the client and
/// server implementations.
abstract class WTransportRequest implements UrlMutation {
  /// Data to send on the HTTP request.
  void set data(dynamic data);

  /// Headers to send with the HTTP request.
  Map<String, String> headers;

  /// Allows more advanced configuration of the request prior to sending.
  /// The supplied callback [configureRequest] should be called after opening,
  /// but prior to sending, the request. The [request] parameter should be the
  /// instance of either dart:html.HttpRequest or dart:io.HttpClientRequest,
  /// depending on the implementation. If [configureRequest] returns a Future,
  /// the request should not be sent until the returned Future completes.
  void configure(configure(request));

  /// Cancel the request. If the request has already finished, this will do nothing.
  void abort();

  /// The following methods should send an HTTP request with the appropriate HTTP method,
  /// returning a Future that should complete with the response.
  Future<WTransportResponse> delete([Uri url]);
  Future<WTransportResponse> get([Uri url]);
  Future<WTransportResponse> head([Uri url]);
  Future<WTransportResponse> options([Uri url]);
  Future<WTransportResponse> patch([Uri url, Object data]);
  Future<WTransportResponse> post([Uri url, Object data]);
  Future<WTransportResponse> put([Uri url, Object data]);
}


/// Abstract transport class for an HTTP client capable of sending many
/// HTTP requests and maintaining persistent connections. Currently this
/// is only possible from the server using dart:io.HttpClient.
abstract class WTransportHttp {
  /// Generates a new WTransportRequest instance that should use this client
  /// to actually send the request.
  WTransportRequest newRequest();

  /// Closes the client, cancelling or closing any outstanding connections.
  void close();
}


/// Abstract class that defines the common response meta data that will be
/// available on a response to an HTTP request (client- or server-side).
abstract class WTransportResponse {
  /// Headers sent with the response to the HTTP request.
  Map<String, String> get headers;

  /// Status code of the response to the HTTP request.
  /// 200, 404, etc.
  int get status;

  /// Status text of the response to the HTTP request.
  /// 'OK', 'Not Found', etc.
  String get statusText;
}


/// Abstract class that defines what an HTTP exception should look like.
/// An implementation of this exception should be rasied when a response
/// to an HTTP request returns with an unsuccessful status code.
abstract class WTransportHttpException implements Exception {
  /// Descriptive error message that includes the request method & URL and the response status.
  String get message;

  /// Response to the request (some of the properties may be unavailable).
  WTransportResponse get response;

  /// URL of the attempted/unsuccessful request.
  Uri get url;
}