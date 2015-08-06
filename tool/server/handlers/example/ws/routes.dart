library w_transport.tool.server.handlers.example.ws.routes;

import '../../../handler.dart';
import '../../../logger.dart';
import 'echo_handler.dart';

String pathPrefix = '/example/ws';

Map<String, Handler> getExampleWsRoutes(Logger logger) =>
    {'$pathPrefix/echo': new EchoHandler(logger),};
