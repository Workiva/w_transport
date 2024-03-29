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
import 'dart:typed_data';

import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:w_transport/src/http/response_format_exception.dart';
import 'package:w_transport/src/http/utils.dart' as http_utils;

abstract class BaseHttpBody {
  /// The size of this request/response body in bytes.
  ///
  /// If the size is not known in advance, this will be null.
  int? get contentLength;

  /// The content type of this request/response. Includes the mime-type and
  /// parameters such as charset.
  MediaType? get contentType;

  /// Encoding used to encode/decode this request/response body.
  Encoding? get encoding;
}

/// Representation of an HTTP request body or an HTTP response body.
///
/// Body is available in three different formats:
/// - bytes (`Uint8List`)
/// - text (`String`)
/// - JSON (`Map` or `List`) - assuming the content-type is JSON
class HttpBody extends BaseHttpBody {
  /// The content type of this request/response. Includes the mime-type and
  /// parameters such as charset.
  @override
  final MediaType? contentType;

  String? _body;
  Uint8List? _bytes;
  final Encoding? _encoding;
  final Encoding _fallbackEncoding;

  /// Construct the body to an HTTP request or an HTTP response from bytes.
  ///
  /// If [encoding] is given, it will be used to encode/decode the body.
  ///
  /// Otherwise, the `charset` parameter from [contentType] will be mapped to an
  /// Encoding supported by Dart.
  ///
  /// If a `charset` parameter is not available or the value is unrecognized,
  /// [fallbackEncoding] will be used.
  ///
  /// If [fallbackEncoding] is `null`, utf-8 will be the default encoding.
  ///
  /// If an encoding cannot be parsed from the content-type header (via the
  /// `charset` param), then [fallbackEncoding] will be used (utf-8 by default).
  HttpBody.fromBytes(this.contentType, List<int>? bytes,
      {Encoding? encoding, Encoding? fallbackEncoding})
      : _encoding =
            encoding ?? http_utils.parseEncodingFromContentType(contentType),
        _fallbackEncoding = fallbackEncoding ?? utf8,
        _bytes = Uint8List.fromList(bytes ?? []);

  /// Construct the body to an HTTP request or an HTTP response from text.
  ///
  /// If [encoding] is given, it will be used to encode/decode the body.
  ///
  /// Otherwise, the `charset` parameter from [contentType] will be mapped to an
  /// Encoding supported by Dart.
  ///
  /// If a `charset` parameter is not available or the value is unrecognized,
  /// [fallbackEncoding] will be used.
  ///
  /// If [fallbackEncoding] is `null`, utf-8 will be the default encoding.
  ///
  /// If an encoding cannot be parsed from the content-type header (via the
  /// `charset` param), then [fallbackEncoding] will be used (utf-8 by default).
  HttpBody.fromString(this.contentType, String? body,
      {Encoding? encoding, Encoding? fallbackEncoding})
      : _encoding =
            encoding ?? http_utils.parseEncodingFromContentType(contentType),
        _fallbackEncoding = fallbackEncoding ?? utf8,
        _body = body ?? '';

  /// The size of this request/response body in bytes.
  @override
  int get contentLength => asBytes().length;

  /// Encoding used to encode/decode this request/response body.
  @override
  Encoding get encoding => _encoding ?? _fallbackEncoding;

  /// Returns this request/response body as a list of bytes.
  Uint8List asBytes() {
    if (_bytes == null) {
      List<int> encoded;
      try {
        encoded = encoding.encode(_body!);
      } on ArgumentError {
        throw ResponseFormatException(contentType, encoding, body: _body);
      }
      _bytes = Uint8List.fromList(encoded);
    }
    return _bytes!;
  }

  /// Returns this request/response body as a String.
  String asString() => _asString(encoding);

  String _asString(Encoding charset) {
    if (_body == null) {
      try {
        _body = charset.decode(_bytes!);
      } on FormatException {
        throw ResponseFormatException(contentType, charset, bytes: _bytes);
      }
    }
    return _body!;
  }

  /// Returns this request/response body as a JSON object - either a `Map` or a
  /// `List`.
  ///
  /// This attempts to read this request/response body as a String and decode it
  /// to a JSON object. If no encoding is specified, it will use UTF-8, rather
  /// than the generic fallback from the response. Throws a [FormatException] if this
  /// request/response body cannot be decoded to text or if the text is not
  /// valid JSON.
  dynamic asJson() => json.decode(_asString(_encoding ?? utf8));
}

/// Representation of an HTTP request body or an HTTP response body where the
/// body is a stream of bytes. Used for large request or response bodies (often
/// when uploading/downloading a file).
class StreamedHttpBody extends BaseHttpBody {
  /// Single subscription stream of chunks of bytes.
  Stream<List<int>> byteStream;

  /// The size of this request/response body in bytes.
  ///
  /// If the size is not known in advance, this will be null.
  @override
  final int? contentLength;

  /// The content type of this request/response. Includes the mime-type and
  /// parameters such as charset.
  @override
  final MediaType? contentType;

  final Encoding _fallbackEncoding;

  StreamedHttpBody._(this.contentType, this.byteStream, this.contentLength,
      this._fallbackEncoding) {
    _encoding = http_utils.parseEncodingFromContentType(contentType);
  }

  /// Construct the body to an HTTP request or an HTTP response from a stream
  /// of chunks of bytes. The given [byteStream] should be a single-
  /// subscription stream.
  factory StreamedHttpBody.fromByteStream(
      MediaType? contentType, Stream<List<int>> byteStream,
      {int? contentLength, Encoding? fallbackEncoding}) {
    final nonNullFallbackEncoding =
        fallbackEncoding ?? utf8; // Use UTF-8 as the default fallback encoding.
    return StreamedHttpBody._(
        contentType, byteStream, contentLength, nonNullFallbackEncoding);
  }

  /// Encoding used to encode/decode this request/response body. Encoding is
  /// selected by parsing the content-type from the headers.
  @override
  Encoding? get encoding => _encoding ?? _fallbackEncoding;
  Encoding? _encoding;

  /// Listens to this streamed request/response body and combines all chunks of
  /// bytes into a single list of bytes.
  Future<Uint8List> toBytes() => http_utils.reduceByteStream(byteStream);
}
