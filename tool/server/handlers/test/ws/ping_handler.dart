library w_transport.tool.server.handlers.test.ws.ping_handler;

import 'dart:async';
import 'dart:io';

import '../../../handler.dart';
import '../../../logger.dart';

class PingHandler extends WebSocketHandler {
  Logger _logger;

  PingHandler(Logger this._logger) : super() {
    enableCors();
  }

  void onConnection(webSocket) {
    webSocket.listen((message) async {
      message = message.replaceAll('ping', '');
      var numPongs = 1;
      try {
        numPongs = int.parse(message);
      } catch (e) {}
      for (int i = 0; i < numPongs; i++) {
        await new Future.delayed(new Duration(milliseconds: 50));
        webSocket.add('pong');
        _logger.withTime(' \t WS \tPong');
      }
    });
  }
}
