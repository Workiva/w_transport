// Copyright 2015 Workiva Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:convert';

import 'package:http_parser/http_parser.dart'
    show CaseInsensitiveMap, MediaType;

import 'package:w_transport/src/http/http_body.dart';
import 'package:w_transport/src/http/utils.dart' as http_utils;

abstract class BaseResponse {
  /// Status code of the response to the HTTP request.
  /// 200, 404, etc.
  final int status;

  /// Status text of the response to the HTTP request.
  /// 'OK', 'Not Found', etc.
  final String statusText;

  MediaType _contentType;
  Encoding _encoding;
  Map<String, String> _headers;

  BaseResponse(this.status, this.statusText, Map<String, String> headers) {
    _headers = new Map<String, String>.unmodifiable(
        new CaseInsensitiveMap<String>.from(headers));
    _encoding = http_utils.parseEncodingFromHeaders(_headers, fallback: LATIN1);
    _contentType = http_utils.parseContentTypeFromHeaders(_headers);
  }

  /// Gets and sets the content-length of the request, in bytes. If the size of
  /// the request is not known in advance, set this to null.
  int get contentLength;

  /// Content-type of this request.
  ///
  /// By default, the mime-type is "text/plain" and the charset is "UTF8".
  /// When the request body or the encoding is set or updated, the
  /// content-type will be updated accordingly.
  MediaType get contentType => _contentType;

  /// Encoding that will be used to decode the response body. This encoding is
  /// selected based on [contentType]'s `charset` parameter. If `charset` is not
  /// given or the encoding name is unrecognized, [LATIN1] is used by default
  /// ([RFC 2616](http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html)).
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
  HttpBody _body;

  Response._(
      int status, String statusText, Map<String, String> headers, HttpBody body)
      : _body = body,
        super(status, statusText, headers);

  Response.fromBytes(int status, String statusText, Map<String, String> headers,
      List<int> bytes)
      : super(status, statusText, headers) {
    _body =
        new HttpBody.fromBytes(contentType, bytes, fallbackEncoding: encoding);
  }

  Response.fromString(
      int status, String statusText, Map<String, String> headers, String body)
      : super(status, statusText, headers) {
    _body =
        new HttpBody.fromString(contentType, body, fallbackEncoding: encoding);
  }

  /// This response's body. Provides synchronous access to the response body as
  /// bytes, text, or JSON.
  HttpBody get body => _body;

  /// Gets and sets the content-length of the request, in bytes. If the size of
  /// the request is not known in advance, set this to null.
  @override
  int get contentLength => body.asBytes().length;

  /// Create a new [Response] using all the values from this instance except
  /// for the parameters specified.
  Response replace(
      {List<int> bodyBytes,
      String bodyString,
      int status,
      String statusText,
      Map<String, String> headers}) {
    status ??= this.status;
    statusText ??= this.statusText;
    headers ??= this.headers;
    if (bodyBytes == null) {
      if (bodyString == null) {
        return new Response._(status, statusText, headers, _body);
      } else {
        return new Response.fromString(status, statusText, headers, bodyString);
      }
    } else {
      return new Response.fromBytes(status, statusText, headers, bodyBytes);
    }
  }
}

/// An HTTP response where the entire contents of the response body are not
/// immediately known. Meta data about a response to an HTTP request (headers,
/// status, statusText) are available immediately and synchronously. The
/// response body is available as a stream of bytes.
class StreamedResponse extends BaseResponse {
  StreamedHttpBody _body;

  StreamedResponse._(int status, String statusText, Map<String, String> headers,
      StreamedHttpBody body)
      : _body = body,
        super(status, statusText, headers);

  StreamedResponse.fromByteStream(int status, String statusText,
      Map<String, String> headers, Stream<List<int>> byteStream)
      : super(status, statusText, headers) {
    _body = new StreamedHttpBody.fromByteStream(contentType, byteStream,
        contentLength: contentLength, fallbackEncoding: encoding);
  }

  /// This response's body. Provides access to the response body as a byte
  /// stream.
  StreamedHttpBody get body => _body;

  /// Gets and sets the content-length of the request, in bytes. If the size of
  /// the request is not known in advance, set this to null.
  @override
  int get contentLength => headers.containsKey('content-length')
      ? int.parse(headers['content-length'])
      : null;

  /// Create a new [StreamedResponse] using all the values from this instance
  /// except for the parameters specified.
  StreamedResponse replace(
      {Stream<List<int>> byteStream,
      int status,
      String statusText,
      Map<String, String> headers}) {
    status ??= this.status;
    statusText ??= this.statusText;
    headers ??= this.headers;
    if (byteStream == null) {
      return new StreamedResponse._(status, statusText, headers, _body);
    } else {
      return new StreamedResponse.fromByteStream(
          status, statusText, headers, byteStream);
    }
  }
}
