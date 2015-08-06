library w_transport.tool.server.handlers.test.ws.close_handler;

import 'dart:io';

import '../../../handler.dart';
import '../../../logger.dart';

class CloseHandler extends WebSocketHandler {
  Logger _logger;

  CloseHandler(Logger this._logger) : super() {
    enableCors();
  }

  void onConnection(webSocket) {
    webSocket.listen((message) {
      if (message.startsWith('close')) {
        var parts = message.split(':');
        var closeCode;
        var closeReason;
        if (parts.length >= 2) {
          closeCode = int.parse(parts[1]);
        }
        if (parts.length >= 3) {
          closeReason = parts[2];
        }
        webSocket.close(closeCode, closeReason);
        _logger.withTime(' \t WS \tConnection closed by request.');
      } else {
        _logger.withTime(' \t WS \tInvalid close request.', true);
      }
    });
  }
}
