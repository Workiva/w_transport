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

library w_transport.tool.server.run;

import 'package:args/args.dart';

import './proxy.dart' show startProxyServer;
import './handlers/example/http/cross_origin_credentials_handlers.dart'
    show exampleHttpCrossOriginCredentialsRoutes;
import './handlers/example/http/cross_origin_file_transfer_handlers.dart'
    show exampleHttpCrossOriginFileTransferRoutes;
import './handlers/ping_handler.dart' show PingHandler;
import './handlers/test/http/routes.dart' show testHttpIntegrationRoutes;
import './logger.dart';
import './router.dart';
import './server.dart';
import './web_socket_handler.dart';

void startHttpServer() {
  List<List<Route>> routeLists = [
    /// META Endpoints

    /// Allows clients to ping server to ensure it's running.
    [new Route('ping', new PingHandler())],

    /// EXAMPLES

    /// Cross Origin Credentials
    exampleHttpCrossOriginCredentialsRoutes,
    /// Cross Origin File Transfer
    exampleHttpCrossOriginFileTransferRoutes,

    /// TESTS

    /// HTTP Integration
    testHttpIntegrationRoutes
  ];
  List<Route> routes = [];
  routeLists.forEach((list) => routes.addAll(list));

  Router router = new Router(routes);
  Logger httpLogger = new Logger('HTTP\t', cyan: true);
  Server.startHttp('localhost', 8024, router, httpLogger);
}

void startWebSocketServer() {
  WebSocketHandler webSocketHandler = new WebSocketHandler();
  Logger webSocketLogger = new Logger('WS\t', magenta: true);
  Server.startWebSocket('localhost', 8026, webSocketHandler, webSocketLogger);
}

void main(List<String> args) {
  ArgParser parser = new ArgParser();
  parser.addFlag('http');
  parser.addFlag('proxy');
  parser.addFlag('web-socket');

  var parsedArgs = parser.parse(args);
  bool http = parsedArgs['http'];
  bool proxy = parsedArgs['proxy'];
  bool webSocket = parsedArgs['web-socket'];
  if (!http && !proxy && !webSocket) {
    http = proxy = webSocket = true;
  }

  if (http) {
    startHttpServer();
  }
  if (proxy) {
    startProxyServer();
  }
  if (webSocket) {
    startWebSocketServer();
  }
}
