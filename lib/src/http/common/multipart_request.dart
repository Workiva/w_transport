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
import 'dart:math';

import 'package:http_parser/http_parser.dart' show MediaType;

import 'package:w_transport/src/http/client.dart';
import 'package:w_transport/src/http/common/request.dart';
import 'package:w_transport/src/http/http_body.dart';
import 'package:w_transport/src/http/multipart_file.dart';
import 'package:w_transport/src/http/requests.dart';
import 'package:w_transport/src/http/utils.dart' as http_utils;
import 'package:w_transport/src/transport_platform.dart';

abstract class CommonMultipartRequest extends CommonRequest
    implements MultipartRequest {
  /// http://tools.ietf.org/html/rfc1341.html
  static const int _boundaryLength = 70;

  /// http://tools.ietf.org/html/rfc2046#section-5.1.1
  static final List<int> _boundaryChars = <String>[
    '\'', '(', ')', '+', '_', ',', '-', '.', '/', ':', '=', '?', // chars
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', // digits
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', // ALPHA
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', // ALPHA
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', // alpha
    'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', // alpha
  ].map((c) => c.codeUnitAt(0)).toList(growable: false);

  static const int _boundaryDelimiterLength =
      _boundaryHyphens.length + _boundaryLength + _crlf.length;

  static const int _boundaryClosingDelimeterLength =
      _boundaryDelimiterLength + _boundaryHyphens.length;

  static const String _boundaryHyphens = '--';

  static const String _crlf = '\r\n';

  static final RegExp _crlfPattern = new RegExp(r'\r\n|\r|\n');

  static final Random _random = new Random();

  String _boundary;

  Map<String, String> _fields = {};

  Map<String, dynamic> _files = {};

  CommonMultipartRequest(TransportPlatform transportPlatform)
      : super(transportPlatform);
  // ignore: deprecated_member_use
  CommonMultipartRequest.fromClient(Client wTransportClient, client)
      : super.fromClient(wTransportClient, client);

  static String _generateBoundaryString() {
    final senderPrefix = 'dart-w-transport-boundary-';
    final boundaryChars =
        new List<int>.generate(_boundaryLength - senderPrefix.length, (_) {
      return _boundaryChars[_random.nextInt(_boundaryChars.length)];
    }, growable: false);
    return '$senderPrefix${new String.fromCharCodes(boundaryChars)}';
  }

  String get boundary {
    _boundary ??= _generateBoundaryString();
    return _boundary;
  }

  @override
  int get contentLength {
    int length = 0;

    fields.forEach((name, value) {
      length += _boundaryDelimiterLength;
      length += UTF8.encode(_multipartFieldHeaders(name, value)).length;
      length += UTF8.encode(value).length;
      length += _crlf.length;
    });

    files.forEach((name, file) {
      if (file is! MultipartFile)
        throw new UnsupportedError('Illegal multipart file type: $file');
      length += _boundaryDelimiterLength;
      length += UTF8.encode(_multipartFileHeaders(name, file)).length;
      length += file.length;
      length += _crlf.length;
    });

    length += _boundaryClosingDelimeterLength;
    return length;
  }

  @override
  set contentLength(int contentLength) {
    throw new UnsupportedError(
        'The content-length of a multipart request cannot be set manually.');
  }

  @override
  set contentType(MediaType contentType) {
    throw new UnsupportedError(
        'The content-type of a multipart request cannot be set manually.');
  }

  @override
  MediaType get defaultContentType =>
      new MediaType('multipart', 'form-data', {'boundary': boundary});

  @override
  set encoding(Encoding encoding) {
    throw new UnsupportedError(
        'A multipart request has many individually-encoded parts. An encoding '
        'cannot be set for the entire request.');
  }

  @override
  Map<String, String> get fields =>
      isSent ? new Map<String, String>.unmodifiable(_fields) : _fields;

  @override
  set fields(Map<String, String> fields) {
    verifyUnsent();
    _fields = new Map<String, String>.from(fields);
  }

  @override
  Map<String, dynamic> get files =>
      isSent ? new Map<String, dynamic>.unmodifiable(_files) : _files;

  @override
  set files(Map<String, dynamic> files) {
    verifyUnsent();
    _files = new Map<String, dynamic>.from(files);
  }

  @override
  MultipartRequest clone() {
    final MultipartRequest requestClone = super.clone();
    return requestClone
      ..fields = fields
      ..files = files;
  }

  @override
  Map<String, String> finalizeHeaders() {
    final headers = super.finalizeHeaders();
    final finalizedHeaders = new Map<String, String>.from(headers);
    finalizedHeaders['content-transfer-encoding'] = 'binary';
    return new Map<String, String>.unmodifiable(finalizedHeaders);
  }

  @override
  Future<StreamedHttpBody> finalizeBody([dynamic body]) async {
    if (body != null) {
      throw new UnsupportedError(
          'The body of a Multipart request must be set via `fields` and/or `files`.');
    }

    if (fields.isEmpty && files.isEmpty) {
      throw new UnsupportedError(
          'The body of a Multipart request cannot be empty.');
    }

    final controller = new StreamController<List<int>>();
    void write(String content) {
      controller.add(UTF8.encode(content));
    }

    Future<Null> writeByteStream(Stream<List<int>> byteStream) {
      final c = new Completer<Null>();
      byteStream.listen(controller.add,
          onError: controller.addError, onDone: c.complete);
      return c.future;
    }

    fields.forEach((name, value) {
      write('$_boundaryHyphens$boundary$_crlf'); // Boundary delimiter.
      write(_multipartFieldHeaders(name, value)); // Field headers.
      write(value); // Field value.
      write(_crlf); // Ending newline.
    });

    final fileList = <Map<String, dynamic>>[];
    files.forEach((name, file) {
      fileList.add({
        'headers': _multipartFileHeaders(name, file),
        'byteStream': file.byteStream,
      });
    });

    // ignore: unawaited_futures
    Future.forEach(fileList, (Map file) {
      // TODO: make this better
      Stream<List<int>> byteStream;
      final bs = file['byteStream'];
      if (bs is Stream<List<int>>) {
        byteStream = bs;
      } else {
        throw new Exception('Expected Multipart file to have a '
            '`Stream<List<int>> byteStream` property.');
      }

      write('$_boundaryHyphens$boundary$_crlf'); // Boundary delimiter.
      write(file['headers']); // File headers.

      // File bytes and ending newline.
      return writeByteStream(byteStream).then((_) => write(_crlf));
    }).then((_) {
      // Ending boundary delimiter.
      write('$_boundaryHyphens$boundary$_boundaryHyphens$_crlf');

      controller.close();
    });

    return new StreamedHttpBody.fromByteStream(contentType, controller.stream,
        contentLength: contentLength);
  }

  /// Encode [name] in preparation of being included as a filename or field name
  /// in the body of a multipart request.
  String _encodeName(String name) {
    // Just like the `http` package, this follows the behavior of browsers when
    // encoding field names and file names:
    //
    // > http://tools.ietf.org/html/rfc2388 mandates some complex encodings for
    // > field names and file names, but in practice user agents seem not to
    // > follow this at all. Instead, they URL-encode `\r`, `\n`, and `\r\n` as
    // > `\r\n`; URL-encode `"`; and do nothing else (even for `%` or non-ASCII
    // > characters).
    return name.replaceAll(_crlfPattern, '%0D%0A').replaceAll('"', '%22');
  }

  String _multipartFieldHeaders(String name, String value) {
    final headers = <String>[
      'content-disposition: form-data; name="${_encodeName(name)}"'
    ];
    if (!http_utils.isAsciiOnly(value)) {
      // Field value has non-ASCII-compatible characters, so a content-type
      // header is required for this part.
      headers.add('content-type: text/plain; charset=utf-8');
    }
    return '${headers.join(_crlf)}${_crlf * 2}';
  }

  String _multipartFileHeaders(String field, MultipartFile file) {
    final headers = <String>['content-type: ${file.contentType}'];

    String disposition =
        'content-disposition: form-data; name="${_encodeName(field)}"';
    if (file.filename != null) {
      disposition = '$disposition; filename="${_encodeName(file.filename)}"';
    }
    headers.add(disposition);

    return '${headers.join(_crlf)}${_crlf * 2}';
  }
}
