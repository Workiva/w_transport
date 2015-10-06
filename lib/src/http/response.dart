library w_transport.src.http.response;

import 'dart:async';
import 'dart:convert';

import 'package:http_parser/http_parser.dart' show CaseInsensitiveMap, MediaType;

import 'package:w_transport/src/http/http_body.dart';
import 'package:w_transport/src/http/utils.dart' as http_utils;

abstract class BaseResponse {
  /// Gets and sets the content-length of the request, in bytes. If the size of
  /// the request is not known in advance, set this to null.
  int get contentLength;

  /// Content-type of this request.
  ///
  /// By default, the mime-type is "text/plain" and the charset is "UTF8".
  /// When the request body or the encoding is set or updated, the
  /// content-type will be updated accordingly.
  MediaType get contentType => _contentType;

  /// Status code of the response to the HTTP request.
  /// 200, 404, etc.
  final int status;

  /// Status text of the response to the HTTP request.
  /// 'OK', 'Not Found', etc.
  final String statusText;

  MediaType _contentType;
  Encoding _encoding;
  Map<String, String> _headers;

  BaseResponse(int this.status, String this.statusText, Map<String, String> headers) {
    _headers = new Map.unmodifiable(new CaseInsensitiveMap.from(headers));
    _encoding = http_utils.parseEncodingFromHeaders(_headers, fallback: LATIN1);
    _contentType = http_utils.parseContentTypeFromHeaders(_headers);
  }

  /// Encoding that will be used when decoding the response body. This encoding
  /// is selected based on [contentType]'s `charset` parameter. If `charset`
  /// is not given or the encoding name is unrecognized, [LATIN1] is used by
  /// default ([RFC 2616](http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html)).
  Encoding get encoding => _encoding;

  /// Headers sent with the response to the HTTP request.
  Map<String, String> get headers => _headers;
}

/// An HTTP response. Content of and meta data about a response to an HTTP
/// request. All meta data (headers, status, statusText) and the response body
/// are available immediately and synchronously.
///
/// The response body may be accessed in three different formats:
/// - bytes (`Uint8List`)
/// - text (`String`)
/// - JSON (`Map` or `List`) - assuming the response content type is JSON
class Response extends BaseResponse {
  /// This response's body. Provides synchronous access to the response body as
  /// bytes, text, or JSON.
  HttpBody get body => _body;

  /// Gets and sets the content-length of the request, in bytes. If the size of
  /// the request is not known in advance, set this to null.
  int get contentLength => body.asBytes().length;

  HttpBody _body;

  Response.fromBytes(int status, String statusText, Map<String, String> headers, List<int> bytes)
      : super(status, statusText, headers) {
    _body = new HttpBody.fromBytes(contentType, bytes, fallbackEncoding: encoding);
  }

  Response.fromString(int status, String statusText, Map<String, String> headers, String body)
      : super(status, statusText, headers) {
    _body = new HttpBody.fromString(contentType, body, fallbackEncoding: encoding);
  }
}

/// An HTTP response where the entire contents of the response body are not
/// immediately known. Meta data about a response to an HTTP request (headers,
/// status, statusText) are available immediately and synchronously. The
/// response body is available as a stream of bytes.
class StreamedResponse extends BaseResponse {
  /// This response's body. Provides access to the response body as a byte
  /// stream.
  StreamedHttpBody get body => _body;

  /// Gets and sets the content-length of the request, in bytes. If the size of
  /// the request is not known in advance, set this to null.
  int get contentLength => headers.containsKey('content-length')
      ? int.parse(headers['content-length'])
      : null;

  StreamedHttpBody _body;

  StreamedResponse.fromByteStream(int status, String statusText, Map<String, String> headers, Stream<List<int>> byteStream)
      : super(status, statusText, headers) {
    _body = new StreamedHttpBody.fromByteStream(contentType, byteStream, contentLength: contentLength, fallbackEncoding: encoding);
  }

}