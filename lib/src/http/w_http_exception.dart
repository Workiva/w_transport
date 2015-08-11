library w_transport.src.http.w_http_exception;

import 'package:w_transport/src/http/w_request.dart';
import 'package:w_transport/src/http/w_response.dart';

/// An exception that is raised when a response to a request returns with
/// an unsuccessful status code.
class WHttpException implements Exception {
  /// HTTP method.
  final String method;

  /// Failed request.
  final WRequest request;

  /// Response to the failed request (some of the properties may be unavailable).
  final WResponse response;

  /// URL of the attempted/unsuccessful request.
  final Uri uri;

  /// Original error, if any.
  var _error;

  /// Construct a new instance of [WHttpException] using information from
  /// an HTTP request and response.
  WHttpException(this.method, this.uri, this.request, this.response,
      [this._error]);

  /// Descriptive error message that includes the request method & URL and the response status.
  String get message {
    String msg = 'WHttpException: $method';
    if (response != null) {
      msg += ' ${response.status} ${response.statusText}';
    }
    msg += ' $uri';
    if (_error != null) {
      msg += '\n\t$_error';
    }
    return msg;
  }

  @override
  String toString() => message;
}
