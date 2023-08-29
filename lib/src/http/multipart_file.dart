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

import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:mime/mime.dart' as mime;

/// A platform-independent file abstraction. The [MultipartRequest] accepts
/// files of this type.
class MultipartFile {
  /// File contents as a stream of chunks of bytes.
  final Stream<List<int>> byteStream;

  /// Filename.
  final String? filename;

  /// Length of the file contents.
  final int length;

  final MediaType _contentType;

  /// Construct a [MultipartFile] by supplying the file contents and the file
  /// length. Optionally include a filename and content-type.
  factory MultipartFile(Stream<List<int>> byteStream, int length,
      {MediaType? contentType, String? filename}) {
    if (contentType == null) {
      var mimeType = filename != null ? mime.lookupMimeType(filename) : null;
      if (mimeType == null) {
        mimeType = 'application/octet-stream';
      }
      contentType = MediaType.parse(mimeType);
    }
    return MultipartFile._(byteStream, length, contentType, filename);
  }

  MultipartFile._(
      this.byteStream, this.length, this._contentType, this.filename);

  /// File content-type. Defaults to "application/octet-stream".
  MediaType get contentType => _contentType;
}
