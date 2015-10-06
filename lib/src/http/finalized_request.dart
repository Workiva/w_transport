library w_transport.src.http.common.finalized_request;

import 'package:http_parser/http_parser.dart' show CaseInsensitiveMap;

import 'package:w_transport/src/http/http_body.dart';

/// A finalized, read-only representation of a request.
class FinalizedRequest {
  /// The request body. Will either be an instance of [HttpBody] or
  /// [StreamedHttpBody].
  final BaseHttpBody body;

  /// The request headers. Case-insensitive.
  final Map<String, String> headers;

  /// The HTTP method (get, post, put, etc.).
  final String method;

  /// The URI the request will be opened against.
  final Uri uri;

  /// Whether or not credentials (secure cookies) will be sent with this
  /// request. Applicable only to the browser platform.
  final bool withCredentials;

  FinalizedRequest(
      String this.method,
      Uri this.uri,
      Map<String, String> headers,
      BaseHttpBody this.body,
      bool this.withCredentials)
      : this.headers =
            new Map.unmodifiable(new CaseInsensitiveMap.from(headers));
}