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

library w_transport.tool.server.server;

import 'dart:async';
import 'dart:io';

import 'logger.dart';
import 'router.dart';

const String defaultHost = 'localhost';
const int defaultPort = 8024;

main() => Server.run(dumpOutput: true);

class Server {
  static Future run(
      {bool dumpOutput: false,
      String host: defaultHost,
      int port: defaultPort}) {
    Server server = new Server(host: host, port: port);
    server.output.listen(print);
    return server.start();
  }

  final String host;
  final int port;

  Logger _logger = new Logger();
  HttpServer _server;
  StreamSubscription _subscription;

  Server({this.host: defaultHost, this.port: defaultPort});

  Stream get output => _logger.stream;

  Future start() async {
    var router = new Router();

    try {
      _server = await HttpServer.bind(host, port);
      _subscription = _server.listen((request) async {
        try {
          await router(request);
          _logger.logRequest(request);
        } catch (e, stackTrace) {
          _logger.logError(e, stackTrace);
        }
      });

      _logger('HTTP server ready - listening on http://$host:$port');
    } catch (e) {
      _logger.logError(
          'Failed to start HTTP server - port $port may already be taken.');
      exit(1);
    }
  }

  Future stop() async {
    await Future.wait(
        [_server.close(force: true), _subscription.cancel(), _logger.close()]);
  }
}
