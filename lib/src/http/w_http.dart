library w_transport.src.http.w_http;

import 'dart:async';

import 'package:w_transport/src/http/w_request.dart';
import 'package:w_transport/src/http/w_response.dart';
import 'package:w_transport/src/platform_adapter.dart';

/// Abstract interface for an HTTP client that may be used to quickly
/// send HTTP requests or for sending multiple HTTP requests.
abstract class WHttp {
  /// Sends a DELETE request to the given [uri].
  static Future<WResponse> delete(Uri uri) => new WRequest().delete(uri);

  /// Sends a GET request to the given [uri].
  static Future<WResponse> get(Uri uri) => new WRequest().get(uri);

  /// Sends a HEAD request to the given [uri].
  static Future<WResponse> head(Uri uri) => new WRequest().head(uri);

  /// Sends an OPTIONS request to the given [uri].
  static Future<WResponse> options(Uri uri) => new WRequest().options(uri);

  /// Sends a PATCH request to the given [uri].
  /// Attaches [data], if given.
  static Future<WResponse> patch(Uri uri, [Object data]) =>
      new WRequest().patch(uri, data);

  /// Sends a POST request to the given [uri].
  /// Attaches [data], if given.
  static Future<WResponse> post(Uri uri, [Object data]) =>
      new WRequest().post(uri, data);

  /// Sends a PUT request to the given [uri].
  /// Attaches [data], if given.
  static Future<WResponse> put(Uri uri, [Object data]) =>
      new WRequest().put(uri, data);

  /// Sends a TRACE request to the given [uri].
  ///
  /// **Note:** For security reasons, TRACE requests are forbidden in the browser.
  static Future<WResponse> trace(Uri uri) => new WRequest().trace(uri);

  factory WHttp() => PlatformAdapter.retrieve().newWHttp();

  /// Whether or not the HTTP client has been closed.
  bool get isClosed;

  /// Closes the client, cancelling or closing any outstanding connections.
  void close();

  /// Generates a new [WRequest] instance that will use this client
  /// to send the request.
  ///
  /// Throws a [StateError] if this client has been closed.
  WRequest newRequest();
}
