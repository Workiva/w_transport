// Copyright 2015 Workiva Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:io';

import 'package:dart2_constant/io.dart' as io_constant;

import 'handler.dart';
import 'handlers/example/http/cross_origin_credentials_handlers.dart'
    show exampleHttpCrossOriginCredentialsRoutes;
import 'handlers/example/http/cross_origin_file_transfer_handlers.dart'
    show exampleHttpCrossOriginFileTransferRoutes;
import 'handlers/example/http/proxy_cross_origin_file_transfer_handlers.dart'
    show proxyExampleHttpCrossOriginFileTransferRoutes;
import 'handlers/example/ws/routes.dart' show getExampleWsRoutes;
import 'handlers/ping_handler.dart' show PingHandler;
import 'handlers/test/http/routes.dart' show testHttpIntegrationRoutes;
import 'handlers/test/ws/routes.dart' show getTestWebSocketIntegrationRoutes;
import 'logger.dart';

class Router implements Function {
  Logger logger;
  Map<String, Handler> routes;

  Router(this.logger) {
    routes = {'/ping': new PingHandler()}
      ..addAll(exampleHttpCrossOriginCredentialsRoutes)
      ..addAll(exampleHttpCrossOriginFileTransferRoutes)
      ..addAll(getExampleWsRoutes(logger))
      ..addAll(proxyExampleHttpCrossOriginFileTransferRoutes)
      ..addAll(testHttpIntegrationRoutes)
      ..addAll(getTestWebSocketIntegrationRoutes(logger));
  }

  Future<Null> call(HttpRequest request) async {
    if (routes.containsKey(request.uri.path)) {
      await routes[request.uri.path].processRequest(request);
    } else {
      request.response.statusCode = io_constant.HttpStatus.notFound;
      await request.response.close();
    }
  }
}
