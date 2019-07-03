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
import 'dart:io';

import 'package:dart2_constant/convert.dart' as convert_constant;
import 'package:dart2_constant/io.dart' as io_constant;
import 'package:http_server/http_server.dart';
import 'package:mime/mime.dart';

import '../../../handler.dart';

String pathPrefix = '/example/http/cross_origin_file_transfer';

Map<String, Handler> exampleHttpCrossOriginFileTransferRoutes = {
  '$pathPrefix/files/': FilesHandler(),
  '$pathPrefix/download': DownloadHandler(),
  '$pathPrefix/upload': UploadHandler()
};

Directory filesDirectory =
    Directory('example/http/cross_origin_file_transfer/files');

Future<String> _readFileUploadAsString(HttpMultipartFormData formData) async {
  final parts = await formData.toList();
  return parts.join('');
}

Future<List<int>> _readFileUploadAsBytes(HttpMultipartFormData formData) async {
  List<int> bytes = [];
  await for (final data in formData) {
    if (data is List<int>) {
      bytes.addAll(data);
    }
  }
  return bytes;
}

void _writeFileUploadAsString(String filename, String contents) {
  _createUploadDirectory();
  final uploadDestination =
      Uri.parse('example/http/cross_origin_file_transfer/files/$filename');
  final upload = File.fromUri(uploadDestination);
  upload.writeAsStringSync(contents);
}

void _writeFileUploadAsBytes(String filename, List<int> bytes) {
  _createUploadDirectory();
  final uploadDestination =
      Uri.parse('example/http/cross_origin_file_transfer/files/$filename');
  final upload = File.fromUri(uploadDestination);
  upload.writeAsBytesSync(bytes);
}

void _createUploadDirectory() {
  if (!filesDirectory.existsSync()) {
    filesDirectory.createSync();
  }
}

class FileWatcher {
  List<FileSystemEntity> files;

  Directory _dir;
  bool _watching;

  FileWatcher(this._dir) {
    files = [];

    _createUploadDirectory();

    _watching = true;
    _startWatching();
  }

  static FileWatcher start(Directory directory) {
    return FileWatcher(directory);
  }

  void close() {
    _endWatching();
  }

  void _startWatching() {
    if (!_watching) return;
    _listFiles();
    Future<void>.delayed(Duration(seconds: 2)).then((_) => _startWatching());
  }

  void _endWatching() {
    _watching = false;
  }

  void _listFiles() {
    if (!_watching) return;
    files = _dir.listSync();
  }
}

class UploadHandler extends Handler {
  UploadHandler() : super() {
    enableCors();
  }

  @override
  Future<void> post(HttpRequest request) async {
    if (request.headers['content-type'] == null) {
      request.response.statusCode = io_constant.HttpStatus.badRequest;
      setCorsHeaders(request);
      return;
    }

    final contentType =
        ContentType.parse(request.headers.value('content-type'));
    final boundary = contentType.parameters['boundary'];
    final stream = request
        .transform(MimeMultipartTransformer(boundary))
        .map(HttpMultipartFormData.parse);

    await for (HttpMultipartFormData formData in stream) {
      switch (formData.contentDisposition.parameters['name']) {
        case 'file':
          String filename =
              formData.contentDisposition.parameters['filename'] ??
                  DateTime.now().toString();

          if (formData.isText) {
            final contents = await _readFileUploadAsString(formData);
            _writeFileUploadAsString(filename, contents);
          } else {
            final bytes = await _readFileUploadAsBytes(formData);
            _writeFileUploadAsBytes(filename, bytes);
          }
      }
    }

    request.response.statusCode = io_constant.HttpStatus.ok;
    setCorsHeaders(request);
  }
}

class FilesHandler extends Handler {
  FileWatcher fw;
  FilesHandler()
      : fw = FileWatcher(filesDirectory),
        super() {
    enableCors();
  }

  @override
  Future<void> get(HttpRequest request) async {
    final files = fw.files.whereType<File>().where((file) => file.existsSync());
    final filesPayload = files
        .map((entity) => {
              'name': Uri.parse(entity.path).pathSegments.last,
              'size': entity.lengthSync()
            })
        .toList();
    request.response.statusCode = io_constant.HttpStatus.ok;
    setCorsHeaders(request);
    request.response
        .write(convert_constant.json.encode({'results': filesPayload}));
  }

  @override
  Future<void> delete(HttpRequest request) async {
    Iterable<File> files = fw.files.whereType<File>();
    for (final entity in files) {
      entity.deleteSync();
    }
    request.response.statusCode = io_constant.HttpStatus.ok;
    setCorsHeaders(request);
  }
}

class DownloadHandler extends Handler {
  DownloadHandler() : super() {
    enableCors();
  }

  @override
  Future<void> get(HttpRequest request) async {
    if (request.uri.queryParameters['file'] == null) {
      request.response.statusCode = io_constant.HttpStatus.notFound;
      setCorsHeaders(request);
      return;
    }
    final requestedFile =
        Uri.parse(request.uri.queryParameters['file']).pathSegments.last;
    if (requestedFile == '' || requestedFile == null) {
      request.response.statusCode = io_constant.HttpStatus.notFound;
      setCorsHeaders(request);
      return;
    }

    final shouldForceDownload = request.uri.queryParameters['dl'] == '1';

    final fileUri = Uri.parse(
        'example/http/cross_origin_file_transfer/files/$requestedFile');
    final file = File.fromUri(fileUri);
    if (!file.existsSync()) {
      request.response.statusCode = io_constant.HttpStatus.notFound;
      setCorsHeaders(request);
      return;
    }

    final headers = <String, String>{
      'content-length': file.lengthSync().toString(),
      'content-type': lookupMimeType(fileUri.path),
    };

    if (shouldForceDownload) {
      headers['content-disposition'] = 'attachment; filename=$requestedFile';
    }

    request.response.statusCode = io_constant.HttpStatus.ok;
    setCorsHeaders(request);
    headers.forEach((h, v) {
      request.response.headers.set(h, v);
    });
    await request.response.addStream(file.openRead());
  }
}
