/*
 * Copyright 2015 Workiva Inc.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

library w_transport.tool.server;

import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

import './logger.dart';
import './router.dart';
import './web_socket_handler.dart';

class Server {
  static startHttp(String host, int port, Router router, Logger logger) async {
    shelf.Handler handler = const shelf.Pipeline()
        .addMiddleware(shelf.logRequests(logger: logger))
        .addHandler(router.route);

    try {
      await io.serve(handler, host, port);
      logger('ready - HTTP listening on http://$host:$port');
    } catch (e) {
      logger('failed to start HTTP server - port $port may already be taken.');
      exit(1);
    }
  }

  static startWebSocket(String host, int port, WebSocketHandler handler, Logger logger) async {
    try {
      HttpServer server = await HttpServer.bind(host, port);
      server.listen((request) async {
        if (request.uri.path == '/ping') {
          request.response.statusCode = HttpStatus.OK;
          request.response.close();
          logger.withTime('200  GET  /ping');
        } else {
          try {
            WebSocket webSocket = await WebSocketTransformer.upgrade(request);
            WebSocketListener listener = handler.newWebSocketListener(webSocket, logger);
            webSocket.listen(listener,
            onError: (error) {
              logger.withTime('WebSocket error: $error', true);
            }, onDone: () {
              logger.withTime('WebSocket closed: ${webSocket.closeCode} ${webSocket.closeReason} (serviced ${listener.numMessages} messages)');
            }, cancelOnError: true);
            logger.withTime('WebSocket opened\tGET\t[101]');
          } catch (e) {
            logger.withTime('$e', true);
          }
        }
      });
      logger('ready - WebSocket listening on ws://$host:$port');
    } catch (e) {
      logger('failed to start WebSocket server - port $port may already be taken.');
      exit(1);
    }
  }
}
