library w_transport.tool.server.handlers.test.http.reader;

import 'dart:async';
import 'dart:io';

import '../../../handler.dart';

/// Always responds with a 200 OK and reads the request body into memory to
/// verify that the body was sent successfully and the content-length was set
/// correctly. The response body then echos the request.
class EchoHandler extends Handler {
  EchoHandler() : super() {
    enableCors();
  }

  Future echo(HttpRequest request) async {
    request.response.statusCode = HttpStatus.OK;
    request.response.headers.contentType = request.headers.contentType;
    setCorsHeaders(request);
    await request.response.addStream(request);
  }

  Future copy(HttpRequest request) async => echo(request);
  Future delete(HttpRequest request) async => echo(request);
  Future get(HttpRequest request) async => echo(request);
  Future head(HttpRequest request) async => echo(request);
  Future options(HttpRequest request) async => echo(request);
  Future patch(HttpRequest request) async => echo(request);
  Future post(HttpRequest request) async => echo(request);
  Future put(HttpRequest request) async => echo(request);
  Future trace(HttpRequest request) async => echo(request);
}
