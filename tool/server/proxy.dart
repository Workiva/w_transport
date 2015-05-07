library w_transport.example.cross_origin_file_transfer.proxy_server;

import 'dart:async';

import 'package:shelf/shelf.dart' as shelf;
import 'package:w_transport/w_http_server.dart';

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

WHttp http = new WHttp();

class FilesProxy extends Handler {
  FilesProxy() : super() {
    enableCors();
  }

  Future<shelf.Response> get(shelf.Request request) async {
    WRequest proxyRequest = http.newRequest()..headers = request.headers;

    WStreamedResponse proxyResponse = await proxyRequest.get(filesEndpoint);
    return new shelf.Response.ok(proxyResponse, headers: proxyResponse.headers);
  }

  Future<shelf.Response> delete(shelf.Request request) async {
    WRequest proxyRequest = http.newRequest()..headers = request.headers;

    WStreamedResponse proxyResponse = await proxyRequest.delete(filesEndpoint);
    return new shelf.Response.ok(proxyResponse, headers: proxyResponse.headers);
  }
}

class UploadProxy extends Handler {
  UploadProxy() : super() {
    enableCors();
  }

  Future<shelf.Response> post(shelf.Request request) async {
    WRequest proxyRequest = http.newRequest()
      ..headers = request.headers
      ..data = request.read();

    WStreamedResponse proxyResponse = await proxyRequest.post(uploadEndpoint);
    return new shelf.Response.ok(proxyResponse, headers: proxyResponse.headers);
  }
}

class DownloadProxy extends Handler {
  DownloadProxy() : super() {
    enableCors();
  }

  Future<shelf.Response> get(shelf.Request request) async {
    WRequest proxyRequest = http.newRequest()
      ..url = downloadEndpoint
      ..query = request.url.query
      ..headers = request.headers;

    WStreamedResponse proxyResponse = await proxyRequest.get();
    return new shelf.Response.ok(proxyResponse, headers: proxyResponse.headers);
  }
}

void startProxy() {
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
