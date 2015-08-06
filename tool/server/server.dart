library w_transport.tool.server.server;

import 'dart:async';
import 'dart:io';

import 'logger.dart';
import 'router.dart';

const String defaultHost = 'localhost';
const int defaultPort = 8024;

main() => Server.run(dumpOutput: true);

class Server {
  static Future run({bool dumpOutput: false, String host: defaultHost,
      int port: defaultPort}) {
    Server server = new Server(host: host, port: port);
    if (dumpOutput) {
      server.output.listen(print);
    }
    return server.start();
  }

  final String host;
  final int port;

  Logger _logger;
  StreamController<String> _output = new StreamController();
  HttpServer _server;

  Server({this.host: defaultHost, this.port: defaultPort});

  Stream<String> get output => _output.stream;

  Future start() async {
    _logger = new Logger(_output);
    var router = new Router(_logger);

    try {
      _server = await HttpServer.bind(host, port);
      _server.listen((request) async {
        try {
          await router(request);
          _logger.logRequest(request);
        } catch (e, stackTrace) {
          _logger.logError(e, stackTrace);
        }
      });

      _logger(
          'HTTP & WebSocket server ready - listening on http://$host:$port');
    } catch (e) {
      _logger.logError(
          'Failed to start HTTP & WebSocket server - port $port may already be taken.');
      exit(1);
    }
  }

  Future stop() async {
    _logger('Server closing.');
    await _server.close();
  }
}
