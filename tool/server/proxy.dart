library w_transport.example.cross_origin_file_transfer.proxy_server;

import 'dart:async';

import 'package:shelf/shelf.dart' as shelf;
import 'package:w_transport/w_http.dart';
import 'package:w_transport/w_http_server.dart' show configureWHttpForServer;

import './handlers/ping_handler.dart';
import './handler.dart';
import './logger.dart';
import './router.dart';
import './server.dart';

Uri filesEndpoint = Uri.parse(
    'http://localhost:8024/example/http/cross_origin_file_transfer/files/');
Uri uploadEndpoint = Uri.parse(
    'http://localhost:8024/example/http/cross_origin_file_transfer/upload');
Uri downloadEndpoint = Uri.parse(
    'http://localhost:8024/example/http/cross_origin_file_transfer/download');

WHttp http;
WHttp getHttpClient() {
  if (http == null) {
    http = new WHttp();
  }
  return http;
}

class FilesProxy extends Handler {
  FilesProxy() : super() {
    enableCors();
  }

  Future<shelf.Response> get(shelf.Request request) async {
    WRequest proxyRequest = getHttpClient().newRequest()
      ..headers = request.headers;

    WResponse proxyResponse = await proxyRequest.get(filesEndpoint);
    return new shelf.Response.ok(proxyResponse.stream,
        headers: proxyResponse.headers);
  }

  Future<shelf.Response> delete(shelf.Request request) async {
    WRequest proxyRequest = getHttpClient().newRequest()
      ..headers = request.headers;

    WResponse proxyResponse = await proxyRequest.delete(filesEndpoint);
    return new shelf.Response.ok(proxyResponse.stream,
        headers: proxyResponse.headers);
  }
}

class UploadProxy extends Handler {
  UploadProxy() : super() {
    enableCors();
  }

  Future<shelf.Response> post(shelf.Request request) async {
    WRequest proxyRequest = getHttpClient().newRequest()
      ..headers = request.headers
      ..data = request.read()
      ..contentLength = request.contentLength;

    proxyRequest.uploadProgress.listen((WProgress progress) {
      print('Uploading: ${progress.percent}%');
    });

    WResponse proxyResponse = await proxyRequest.post(uploadEndpoint);
    return new shelf.Response.ok(proxyResponse.stream,
        headers: proxyResponse.headers);
  }
}

class DownloadProxy extends Handler {
  DownloadProxy() : super() {
    enableCors();
  }

  Future<shelf.Response> get(shelf.Request request) async {
    WRequest proxyRequest = getHttpClient().newRequest()
      ..uri = downloadEndpoint
      ..query = request.url.query
      ..headers = request.headers;

    proxyRequest.downloadProgress.listen((WProgress progress) {
      print(
          'Downloading ${request.url.queryParameters['file']}: ${progress.percent}%');
    });

    WResponse proxyResponse = await proxyRequest.get();
    return new shelf.Response.ok(proxyResponse.stream,
        headers: proxyResponse.headers);
  }
}

void startProxy() {
  configureWHttpForServer();
  Router router = new Router([
    new Route('download', new DownloadProxy()),
    new Route('files/', new FilesProxy()),
    new Route('ping', new PingHandler()),
    new Route('upload', new UploadProxy()),
  ]);
  Logger logger = new Logger('Proxy', yellow: true);
  Server.start('Proxy', 'localhost', 8025, router, logger);
}

void main() {
  startProxy();
}
