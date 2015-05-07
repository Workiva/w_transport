library w_transport.tool.server.handlers.test.http.reflect_handler;

import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart' as shelf;

import '../../../handler.dart';


/// Always responds with a 200 OK and dumps a reflection
/// of the request to the response body. This reflection
/// is a JSON payload that includes the request method,
/// request URL path, request headers, and request body.
class ReflectHandler extends Handler {
  ReflectHandler(): super() {
    enableCors();
  }

  Future<shelf.Response> reflect(shelf.Request request) async {
    Map reflection = {
      'method': request.method,
      'path': request.url.path,
      'headers': request.headers,
      'body': await request.readAsString(),
    };

    return new shelf.Response.ok(JSON.encode(reflection));
  }

  Future<shelf.Response> delete(shelf.Request request) async => reflect(request);
  Future<shelf.Response> get(shelf.Request request) async => reflect(request);
  Future<shelf.Response> head(shelf.Request request) async => reflect(request);
  Future<shelf.Response> options(shelf.Request request) async => reflect(request);
  Future<shelf.Response> patch(shelf.Request request) async => reflect(request);
  Future<shelf.Response> post(shelf.Request request) async => reflect(request);
  Future<shelf.Response> put(shelf.Request request) async => reflect(request);
  Future<shelf.Response> trace(shelf.Request request) async => reflect(request);
}