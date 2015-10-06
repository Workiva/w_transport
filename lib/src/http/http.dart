library w_transport.src.http.http;

import 'dart:async';

import 'package:w_transport/src/http/requests.dart';
import 'package:w_transport/src/http/response.dart';

/// Static methods for quickly sending HTTP requests.
class Http {
  /// Sends a DELETE request to [uri]. Includes request [headers] if given.
  ///
  /// Secure cookies (credentials) will be included (in the browser) if
  /// [withCredentials] is true.
  static Future<Response> delete(Uri uri, {Map<String, String> headers, bool withCredentials})
      => _createRequest(uri, headers: headers, withCredentials: withCredentials).delete();

  /// Sends a GET request to [uri]. Includes request [headers] if given.
  ///
  /// Secure cookies (credentials) will be included (in the browser) if
  /// [withCredentials] is true.
  static Future<Response> get(Uri uri, {Map<String, String> headers, bool withCredentials})
      => _createRequest(uri, headers: headers, withCredentials: withCredentials).get();

  /// Sends a HEAD request to [uri]. Includes request [headers] if given.
  ///
  /// Secure cookies (credentials) will be included (in the browser) if
  /// [withCredentials] is true.
  static Future<Response> head(Uri uri, {Map<String, String> headers, bool withCredentials})
      => _createRequest(uri, headers: headers, withCredentials: withCredentials).head();

  /// Sends an OPTIONS request to [uri]. Includes request [headers] if given.
  ///
  /// Secure cookies (credentials) will be included (in the browser) if
  /// [withCredentials] is true.
  static Future<Response> options(Uri uri, {Map<String, String> headers, bool withCredentials})
      => _createRequest(uri, headers: headers, withCredentials: withCredentials).options();

  /// Sends a PATCH request to [uri]. Includes request [headers] and a request
  /// [body] if given.
  ///
  /// Secure cookies (credentials) will be included (in the browser) if
  /// [withCredentials] is true.
  static Future<Response> patch(Uri uri, {String body, Map<String, String> headers, bool withCredentials})
      => _createRequest(uri, body: body, headers: headers, withCredentials: withCredentials).patch();

  /// Sends a POST request to [uri]. Includes request [headers] and a request
  /// [body] if given.
  ///
  /// Secure cookies (credentials) will be included (in the browser) if
  /// [withCredentials] is true.
  static Future<Response> post(Uri uri, {String body, Map<String, String> headers, bool withCredentials})
      => _createRequest(uri, body: body, headers: headers, withCredentials: withCredentials).post();

  /// Sends a PUT request to [uri]. Includes request [headers] and a request
  /// [body] if given.
  ///
  /// Secure cookies (credentials) will be included (in the browser) if
  /// [withCredentials] is true.
  static Future<Response> put(Uri uri, {String body, Map<String, String> headers, bool withCredentials})
      => _createRequest(uri, body: body, headers: headers, withCredentials: withCredentials).put();

  /// Sends a request to [uri] using the HTTP method specified by [method].
  /// Includes request [headers] and a request [body] if given.
  ///
  /// Secure cookies (credentials) will be included (in the browser) if
  /// [withCredentials] is true.
  static Future<Response> send(String method, Uri uri, {String body, Map<String, String> headers, bool withCredentials})
      => _createRequest(uri, body: body, headers: headers, withCredentials: withCredentials).send(method);

  static _createRequest(Uri uri, {String body, Map<String, String> headers, bool withCredentials}) {
    var request = new Request()
      ..uri = uri;
    if (body != null) {
      request.body = body;
    }
    if (headers != null) {
      request.headers = headers;
    }
    if (withCredentials != null) {
      request.withCredentials = withCredentials;
    }
    return request;
  }
}