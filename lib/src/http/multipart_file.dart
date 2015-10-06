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

library w_transport.src.http.multipart_file;

import 'dart:async';

import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:mime/mime.dart' as mime;

class MultipartFile {
  final Stream<List<int>> byteStream;
  final String filename;
  final int length;

  MediaType _contentType;

  MultipartFile(Stream<List<int>> this.byteStream, int this.length,
      {MediaType contentType, String this.filename}) {
    if (contentType != null) {
      _contentType = contentType;
    } else {
      var mimeType = filename != null ? mime.lookupMimeType(filename) : null;
      if (mimeType == null) {
        mimeType = 'application/octet-stream';
      }
      _contentType = new MediaType.parse(mimeType);
    }
  }

  MediaType get contentType => _contentType;
}
