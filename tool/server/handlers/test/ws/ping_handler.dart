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

import '../../../handler.dart';
import '../../../logger.dart';

class PingHandler extends WebSocketHandler {
  Logger _logger;

  PingHandler(this._logger) : super() {
    enableCors();
  }

  @override
  void onConnection(WebSocket webSocket) {
    webSocket.listen((message) async {
      message = message.replaceAll('ping', '');
      int numPongs = 1;
      try {
        numPongs = int.parse(message);
      } catch (_) {}
      for (int i = 0; i < numPongs; i++) {
        await new Future.delayed(new Duration(milliseconds: 50));
        webSocket.add('pong');
        _logger.withTime(' \t WS \tPong');
      }
    });
  }
}
