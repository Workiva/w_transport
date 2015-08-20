library w_transport.tool.server.router;

import 'dart:async';
import 'dart:io';

import 'handler.dart';
import 'handlers/example/http/cross_origin_credentials_handlers.dart'
    show exampleHttpCrossOriginCredentialsRoutes;
import 'handlers/example/http/cross_origin_file_transfer_handlers.dart'
    show exampleHttpCrossOriginFileTransferRoutes;
import 'handlers/example/http/proxy_cross_origin_file_transfer_handlers.dart'
    show proxyExampleHttpCrossOriginFileTransferRoutes;
import 'handlers/ping_handler.dart' show PingHandler;
import 'handlers/test/http/routes.dart' show testHttpIntegrationRoutes;

class Router implements Function {
  Map<String, Handler> routes;

  Router() {
    routes = {'/ping': new PingHandler()}
      ..addAll(exampleHttpCrossOriginCredentialsRoutes)
      ..addAll(exampleHttpCrossOriginFileTransferRoutes)
      ..addAll(proxyExampleHttpCrossOriginFileTransferRoutes)
      ..addAll(testHttpIntegrationRoutes);
  }

  Future call(HttpRequest request) async {
    if (routes.containsKey(request.uri.path)) {
      await routes[request.uri.path].processRequest(request);
    } else {
      request.response.statusCode = HttpStatus.NOT_FOUND;
      request.response.close();
    }
  }
}
