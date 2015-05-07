library w_transport.tool.server.handlers.ping_handler;

import 'dart:async';

import 'package:shelf/shelf.dart' as shelf;

import '../handler.dart';

/// Always responds with a 200 OK.
class PingHandler extends Handler {
  PingHandler() : super() {
    enableCors();
  }

  Future<shelf.Response> get(shelf.Request request) async {
    return new shelf.Response.ok('');
  }
}
