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
