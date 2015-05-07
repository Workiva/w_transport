library w_transport.tool.server.handlers.example.http.cross_origin_file_transfer_handlers;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http_server/http_server.dart';
import 'package:mime/mime.dart';
import 'package:shelf/shelf.dart' as shelf;

import '../../../handler.dart';
import '../../../router.dart';


String pathPrefix = 'example/http/cross_origin_file_transfer';

List<Route> exampleHttpCrossOriginFileTransferRoutes = [
  new Route('$pathPrefix/files/', new FilesHandler()),
  new Route('$pathPrefix/download', new DownloadHandler()),
  new Route('$pathPrefix/upload', new UploadHandler()),
];

Directory filesDirectory = new Directory('example/http/cross_origin_file_transfer/files');


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
  Uri uploadDestination = Uri.parse('example/http/cross_origin_file_transfer/files/$filename');
  File upload = new File.fromUri(uploadDestination);
  upload.writeAsStringSync(contents);
}

void _writeFileUploadAsBytes(String filename, List<int> bytes) {
  _createUploadDirectory();
  Uri uploadDestination = Uri.parse('example/http/cross_origin_file_transfer/files/$filename');
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

  Future<shelf.Response> post(shelf.Request request) async {
    if (request.headers['content-type'] == null) {
      return new shelf.Response(HttpStatus.BAD_REQUEST);
    }
    ContentType contentType = ContentType.parse(request.headers['content-type']);
    String boundary = contentType.parameters['boundary'];
    Stream stream = request.read()
      .transform(new MimeMultipartTransformer(boundary))
      .map(HttpMultipartFormData.parse);

    await for (HttpMultipartFormData formData in stream) {
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

    return new shelf.Response(HttpStatus.OK);
  }
}


class FilesHandler extends Handler {
  FileWatcher fw;
  FilesHandler() : super(), fw = new FileWatcher(filesDirectory) {
    enableCors();
  }

  Future<shelf.Response> get(shelf.Request request) async {
    List<Map> filesPayload = fw.files.where((FileSystemEntity entity) => entity is File && entity.existsSync()).map((File entity) {
      return {
        'name': Uri.parse(entity.path).pathSegments.last,
        'size': entity.lengthSync()
      };
    }).toList();
    return new shelf.Response.ok(JSON.encode({
      'results': filesPayload
    }));
  }

  Future<shelf.Response> delete(shelf.Request request) async {
    fw.files.where((FileSystemEntity entity) => entity is File).forEach((File entity) {
      entity.deleteSync();
    });
    return new shelf.Response.ok('');
  }
}


class DownloadHandler extends Handler {
  DownloadHandler() : super() {
    enableCors();
  }

  Future<shelf.Response> get(shelf.Request request) async {
    if (request.url.queryParameters['file'] == null) return new shelf.Response.notFound('');
    String requestedFile = Uri.parse(request.url.queryParameters['file']).pathSegments.last;
    if (requestedFile == '' || requestedFile == null) return new shelf.Response.notFound('');

    bool shouldForceDownload = request.url.queryParameters['dl'] == '1';

    Uri fileUri = Uri.parse('example/http/cross_origin_file_transfer/files/$requestedFile');
    File file = new File.fromUri(fileUri);
    if (!file.existsSync()) return new shelf.Response.notFound('');

    Map headers = {
      'content-length': file.lengthSync().toString(),
      'content-type': lookupMimeType(fileUri.path),
    };

    if (shouldForceDownload) {
      headers['content-disposition'] = 'attachment; filename=$requestedFile';
    }

    return new shelf.Response.ok(file.openRead(), headers: headers);
  }
}