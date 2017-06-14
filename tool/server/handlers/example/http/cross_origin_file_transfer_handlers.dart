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

library w_transport.tool.server.handlers.example.http.cross_origin_file_transfer_handlers;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http_server/http_server.dart';
import 'package:mime/mime.dart';

import '../../../handler.dart';

String pathPrefix = '/example/http/cross_origin_file_transfer';

Map<String, Handler> exampleHttpCrossOriginFileTransferRoutes = {
  '$pathPrefix/files/': new FilesHandler(),
  '$pathPrefix/download': new DownloadHandler(),
  '$pathPrefix/upload': new UploadHandler()
};

Directory filesDirectory =
    new Directory('example/http/cross_origin_file_transfer/files');

Future<String> _readFileUploadAsString(HttpMultipartFormData formData) async {
  List<String> parts = await formData.toList();
  return parts.join('');
}

Future<List<int>> _readFileUploadAsBytes(HttpMultipartFormData formData) async {
  List<int> bytes = [];
  await for (List<int> data in formData) {
    bytes.addAll(data);
  }
  return bytes;
}

void _writeFileUploadAsString(String filename, String contents) {
  _createUploadDirectory();
  Uri uploadDestination =
      Uri.parse('example/http/cross_origin_file_transfer/files/$filename');
  File upload = new File.fromUri(uploadDestination);
  upload.writeAsStringSync(contents);
}

void _writeFileUploadAsBytes(String filename, List<int> bytes) {
  _createUploadDirectory();
  Uri uploadDestination =
      Uri.parse('example/http/cross_origin_file_transfer/files/$filename');
  File upload = new File.fromUri(uploadDestination);
  upload.writeAsBytesSync(bytes);
}

void _createUploadDirectory() {
  if (!filesDirectory.existsSync()) {
    filesDirectory.createSync();
  }
}

class FileWatcher {
  static FileWatcher start(Directory directory) {
    return new FileWatcher(directory);
  }

  List<FileSystemEntity> files;

  Directory _dir;
  bool _watching;

  FileWatcher(this._dir) {
    files = [];

    _createUploadDirectory();

    _watching = true;
    _startWatching();
  }

  void close() {
    _endWatching();
  }

  void _startWatching() {
    if (!_watching) return;
    _listFiles();
    new Future.delayed(new Duration(seconds: 2)).then((_) => _startWatching());
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

  Future post(HttpRequest request) async {
    if (request.headers['content-type'] == null) {
      request.response.statusCode = HttpStatus.BAD_REQUEST;
      setCorsHeaders(request);
      return;
    }

    ContentType contentType =
        ContentType.parse(request.headers.value('content-type'));
    String boundary = contentType.parameters['boundary'];
    Stream stream = request
        .transform(new MimeMultipartTransformer(boundary))
        .map(HttpMultipartFormData.parse);

    await for (HttpMultipartFormData formData in stream) {
      switch (formData.contentDisposition.parameters['name']) {
        case 'file':
          String filename = formData.contentDisposition.parameters['filename'];
          if (filename == null) {
            filename = new DateTime.now().toString();
          }

          if (formData.isText) {
            String contents = await _readFileUploadAsString(formData);
            _writeFileUploadAsString(filename, contents);
          } else {
            List<int> bytes = await _readFileUploadAsBytes(formData);
            _writeFileUploadAsBytes(filename, bytes);
          }
      }
    }

    request.response.statusCode = HttpStatus.OK;
    setCorsHeaders(request);
  }
}

class FilesHandler extends Handler {
  FileWatcher fw;
  FilesHandler()
      :
        fw = new FileWatcher(filesDirectory) , super(){
    enableCors();
  }

  Future get(HttpRequest request) async {
    List<Map> filesPayload = fw.files
        .where(
            (FileSystemEntity entity) => entity is File && entity.existsSync())
        .map((FileSystemEntity entity) => {
              'name': Uri.parse(entity.path).pathSegments.last,
              'size': (entity as File).lengthSync()
            })
        .toList();
    request.response.statusCode = HttpStatus.OK;
    setCorsHeaders(request);
    request.response.write(JSON.encode({'results': filesPayload}));
  }

  Future delete(HttpRequest request) async {
    fw.files
        .where((FileSystemEntity entity) => entity is File)
        .forEach((FileSystemEntity entity) {
      entity.deleteSync();
    });
    request.response.statusCode = HttpStatus.OK;
    setCorsHeaders(request);
  }
}

class DownloadHandler extends Handler {
  DownloadHandler() : super() {
    enableCors();
  }

  Future get(HttpRequest request) async {
    if (request.uri.queryParameters['file'] == null) {
      request.response.statusCode = HttpStatus.NOT_FOUND;
      setCorsHeaders(request);
      return;
    }
    String requestedFile =
        Uri.parse(request.uri.queryParameters['file']).pathSegments.last;
    if (requestedFile == '' || requestedFile == null) {
      request.response.statusCode = HttpStatus.NOT_FOUND;
      setCorsHeaders(request);
      return;
    }

    bool shouldForceDownload = request.uri.queryParameters['dl'] == '1';

    Uri fileUri = Uri
        .parse('example/http/cross_origin_file_transfer/files/$requestedFile');
    File file = new File.fromUri(fileUri);
    if (!file.existsSync()) {
      request.response.statusCode = HttpStatus.NOT_FOUND;
      setCorsHeaders(request);
      return;
    }

    Map headers = {
      'content-length': file.lengthSync().toString(),
      'content-type': lookupMimeType(fileUri.path),
    };

    if (shouldForceDownload) {
      headers['content-disposition'] = 'attachment; filename=$requestedFile';
    }

    request.response.statusCode = HttpStatus.OK;
    setCorsHeaders(request);
    headers.forEach((h, v) {
      request.response.headers.set(h, v);
    });
    await request.response.addStream(file.openRead());
  }
}
