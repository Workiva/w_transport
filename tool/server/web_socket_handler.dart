library w_transport.tool.server.web_socket_handler;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import './logger.dart';

class WebSocketHandler {
  WebSocketListener newWebSocketListener(WebSocket webSocket, Logger logger) => new WebSocketListener(webSocket, logger);
}

class WebSocketListener {
  Logger logger;
  int numMessages = 0;
  WebSocket webSocket;

  WebSocketListener(WebSocket this.webSocket, Logger this.logger);

  void call(message) {
    numMessages++;

    try {
      message = JSON.decode(message);
      if (message['action'] == null) {
        logger.withTime('Message did not specify an action: $message', true);
        return;
      }
      handle(message['action'], message);
    } catch (e) {
      logger.withTime('Message: $message');
    }
  }

  handle(String action, message) async {
    switch (action) {
      case 'close':
        webSocket.close();
        logger.withTime('Connection closed by request.');
        break;
      case 'echo':
        webSocket.add(JSON.encode(message));
        logger.withTime('Echo: $message');
        break;
      case 'ping':
        int numPongs = message['pongs'] != null ? message['pongs'] : 1;
        for (int i = 0; i < numPongs; i++) {
          await new Future.delayed(new Duration(milliseconds: 50));
          webSocket.add('pong');
          logger.withTime('Pong');
        }
        break;
      default:
        logger.withTime('Message with unkown action ($action): $message', true);
        break;
    }
  }
}