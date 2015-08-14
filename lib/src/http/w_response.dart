library w_transport.src.http.w_response;

import 'dart:async';

/// Content of and meta data about a response to an HTTP request.
/// All meta data (headers, status, statusText) are available immediately.
/// Response content (data, text, or stream) is available asynchronously.
abstract class WResponse {
  /// Headers sent with the response to the HTTP request.
  Map<String, String> get headers;

  /// Status code of the response to the HTTP request.
  /// 200, 404, etc.
  int get status;

  /// Status text of the response to the HTTP request.
  /// 'OK', 'Not Found', etc.
  String get statusText;

  /// The data received as a response from the request.
  ///
  /// On the client side, the type of data will be one of:
  ///
  ///   - `Blob`
  ///   - `ByteBuffer`
  ///   - `Document`
  ///   - `String`
  ///
  /// On the server side, the type of data will be:
  ///
  ///   - `List<int>`
  Future<Object> asFuture();

  /// The data stream received as a response from the request.
  Stream asStream();

  /// The data received as a response from the request in String format.
  Future<String> asText();

  /// Update the underlying response data source.
  /// [asFuture], [asText], and [asStream] all use this data source.
  void update(dynamic dataSource);
}
