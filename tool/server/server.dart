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

class Server {
  static start(
      String name, String host, int port, Router router, Logger logger) async {
    shelf.Handler handler = const shelf.Pipeline()
        .addMiddleware(shelf.logRequests(logger: logger))
        .addHandler(router.route);

    try {
      await io.serve(handler, host, port);
      logger('ready - listening on http://$host:$port');
    } catch (e) {
      logger('failed to start - port 8024 already taken.');
      exit(1);
    }
  }
}
