library w_transport.tool.server;

import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

import './logger.dart';
import './router.dart';

class Server {
  static start(
      String name, String host, int port, Router router, Logger logger) async {
    shelf.Handler handler = const shelf.Pipeline()
        .addMiddleware(shelf.logRequests(logger: logger))
        .addHandler(router.route);

    try {
      await io.serve(handler, host, port);
      logger('ready - listening on http://$host:$port');
    } catch (e) {
      logger('failed to start - port 8024 already taken.');
      exit(1);
    }
  }
}
