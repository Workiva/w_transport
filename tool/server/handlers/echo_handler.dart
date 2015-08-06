library w_transport.tool.server.handlers.echo_handler;

import '../handler.dart';
import '../logger.dart';

class EchoHandler extends WebSocketHandler {
  Logger _logger;

  EchoHandler(Logger this._logger) : super() {
    enableCors();
  }

  void onConnection(webSocket) {
    webSocket.listen((message) {
      webSocket.add(message);
      _logger.withTime(' \t WS \tEcho: $message');
    });
  }
}
