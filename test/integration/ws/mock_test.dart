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

@TestOn('vm || browser')
library w_transport.test.integration.ws.mock_test;

import 'dart:async';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_mock.dart';

import 'common.dart';

void main() {
  configureWTransportForTest();

  WebSocketIntegrationConfig config =
      new WebSocketIntegrationConfig('Mock', Uri.parse('ws://localhost:8024'));

  MockTransports.webSocket.when(config.fourOhFourUri, reject: true);

  MockTransports.webSocket.when(config.closeUri,
      handler: (Uri uri, {protocols, headers}) {
    MockWSocket webSocket = new MockWSocket();

    webSocket.onOutgoing((data) {
      if (data.startsWith('close')) {
        var parts = data.split(':');
        var closeCode;
        var closeReason;
        if (parts.length >= 2) {
          closeCode = int.parse(parts[1]);
        }
        if (parts.length >= 3) {
          closeReason = parts[2];
        }
        webSocket.close(closeCode, closeReason);
      }
    });

    return webSocket;
  });

  MockTransports.webSocket.when(config.echoUri,
      handler: (Uri uri, {protocols, headers}) {
    MockWSocket webSocket = new MockWSocket();
    webSocket.onOutgoing(webSocket.addIncoming);
    return webSocket;
  });

  MockTransports.webSocket.when(config.pingUri,
      handler: (Uri uri, {protocols, headers}) {
    MockWSocket webSocket = new MockWSocket();

    webSocket.onOutgoing((data) async {
      data = data.replaceAll('ping', '');
      var numPongs = 1;
      try {
        numPongs = int.parse(data);
      } catch (e) {}
      for (int i = 0; i < numPongs; i++) {
        await new Future.delayed(new Duration(milliseconds: 50));
        webSocket.addIncoming('pong');
      }
    });

    return webSocket;
  });

  group(config.title, () {
    runCommonWebSocketIntegrationTests(config);
  });
}
