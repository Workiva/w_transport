library w_transport.src.http.http_body;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http_parser/http_parser.dart' show MediaType;

import 'package:w_transport/src/http/utils.dart' as http_utils;

abstract class BaseHttpBody {
  /// The size of this request/response body in bytes.
  ///
  /// If the size is not known in advance, this will be null.
  int get contentLength;

  /// The content type of this request/response. Includes the mime-type and
  /// parameters such as charset.
  MediaType get contentType;

  /// Encoding used to encode/decode this request/response body.
  Encoding get encoding;
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
  final MediaType contentType;

  /// Encoding used to encode/decode this request/response body.
  Encoding get encoding => _encoding;

  String _body;
  Uint8List _bytes;
  Encoding _encoding;

  /// Construct the body to an HTTP request or an HTTP response from bytes.
  HttpBody.fromBytes(MediaType this.contentType, List<int> bytes, {Encoding fallbackEncoding}) {
    _encoding = http_utils.parseEncodingFromContentType(contentType, fallback: fallbackEncoding);
    if (bytes == null) {
      bytes = [];
    }
    _bytes = new Uint8List.fromList(bytes);
  }

  /// Construct the body to an HTTP request or an HTTP response from text.
  HttpBody.fromString(MediaType this.contentType, String body, {Encoding fallbackEncoding}) {
    _encoding = http_utils.parseEncodingFromContentType(contentType, fallback: fallbackEncoding);
    if (body == null) {
      body = '';
    }
    _body = body;
  }

  /// The size of this request/response body in bytes.
  int get contentLength => asBytes().length;

  /// Returns this request/response body as a list of bytes.
  Uint8List asBytes() {
    if (_bytes == null) {
      _bytes = new Uint8List.fromList(encoding.encode(_body));
    }
    return _bytes;
  }

  /// Returns this request/response body as a String.
  String asString() {
    if (_body == null) {
      _body = encoding.decode(_bytes);
    }
    return _body;
  }

  /// Returns this request/response body as a JSON object - either a `Map` or a
  /// `List`.
  ///
  /// This attempts to read this request/response body as a `String` and decode
  /// it to a JSON object. Throws a [FormatException] if this request/response
  /// body cannot be decoded to text or if the text is not valid JSON.
  dynamic asJson() => JSON.decode(asString());
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
  final int contentLength;

  /// The content type of this request/response. Includes the mime-type and
  /// parameters such as charset.
  final MediaType contentType;

  /// Encoding used to encode/decode this request/response body. Encoding is
  /// selected by parsing the content-type from the headers.
  Encoding get encoding => _encoding;

  Encoding _encoding;

  /// Construct the body to an HTTP request or an HTTP response from a stream
  /// of chunks of bytes. The given [byteStream] should be a single-
  /// subscription stream.
  StreamedHttpBody.fromByteStream(MediaType this.contentType, Stream<List<int>> this.byteStream, {int contentLength, Encoding fallbackEncoding})
      : this.contentLength = contentLength {
    if (byteStream == null) throw new ArgumentError.notNull('byteStream');
    _encoding = http_utils.parseEncodingFromContentType(contentType, fallback: fallbackEncoding);
  }

  /// Listens to this streamed request/response body and combines all chunks of
  /// bytes into a single list of bytes.
  Future<Uint8List> toBytes() => http_utils.reduceByteStream(byteStream);
}