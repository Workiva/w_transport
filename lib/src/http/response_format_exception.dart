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

import 'dart:convert';
import 'dart:typed_data';

import 'package:http_parser/http_parser.dart' show MediaType;

/// An exception that is raised when a response to a request returns with a body
/// that cannot successfully be encoded or decoded based on the expected
/// content-type.
class ResponseFormatException implements Exception {
  final String body;

  final Uint8List bytes;

  final MediaType contentType;

  final Encoding encoding;

  /// Construct a new instance of [ResponseFormatException] using information
  /// from the body of the response.
  ResponseFormatException(this.contentType, this.encoding,
      {this.body, this.bytes});

  /// Descriptive error message that includes the content-type, encoding, as
  /// well as the string or bytes that could not be encoded or decoded,
  /// respectively.
  String get message {
    String description;
    String bodyLine;
    if (body != null) {
      description = 'Body could not be encoded.';
      bodyLine = 'Body: $body';
    } else {
      description = 'Bytes could not be decoded.';
      bodyLine = 'Bytes: $bytes';
    }

    String msg = description;
    final encodingName = encoding?.name ?? 'null';
    msg += '\n\tContent-Type: $contentType';
    msg += '\n\tEncoding: $encodingName';
    msg += '\n\t$bodyLine';

    return msg;
  }

  @override
  String toString() => 'ResponseFormatException: $message';
}
