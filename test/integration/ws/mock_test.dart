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
import 'dart:async';

import 'package:test/test.dart';
import 'package:w_transport/mock.dart';

import '../../naming.dart';
import '../integration_paths.dart';
import 'common.dart';

void main() {
  final naming = Naming()
    ..platform = platformMock
    ..testType = testTypeIntegration
    ..topic = topicWebSocket;

  group(naming.toString(), () {
    MockWebSocketServer mockCloseWebSocketServer;
    MockWebSocketServer mockEchoWebSocketServer;
    MockWebSocketServer mockPingWebSocketServer;

    setUp(() {
      MockTransports.install();

      mockCloseWebSocketServer = MockWebSocketServer();
      mockEchoWebSocketServer = MockWebSocketServer();
      mockPingWebSocketServer = MockWebSocketServer();

      mockCloseWebSocketServer.onClientConnected.listen((connection) {
        connection.onData((data) {
          if (data.startsWith('close')) {
            final parts = data.split(':');
            int closeCode;
            String closeReason;
            if (parts.length >= 2) {
              closeCode = int.parse(parts[1]);
            }
            if (parts.length >= 3) {
              closeReason = parts[2];
            }
            connection.close(closeCode, closeReason);
          }
        });
      });

      mockEchoWebSocketServer.onClientConnected.listen((connection) {
        connection.onData(connection.send);
      });

      mockPingWebSocketServer.onClientConnected.listen((connection) {
        connection.onData((data) async {
          data = data.replaceAll('ping', '');
          int numPongs = 1;
          try {
            numPongs = int.parse(data);
          } catch (_) {}
          for (int i = 0; i < numPongs; i++) {
            await Future.delayed(Duration(milliseconds: 5));
            connection.send('pong');
          }
        });
      });

      MockTransports.webSocket
          .when(IntegrationPaths.fourOhFourUri, reject: true);

      MockTransports.webSocket.when(IntegrationPaths.closeUri,
          handler: (Uri uri, {protocols, headers}) async =>
              mockCloseWebSocketServer);

      MockTransports.webSocket.when(IntegrationPaths.echoUri,
          handler: (Uri uri, {protocols, headers}) async =>
              mockEchoWebSocketServer);

      MockTransports.webSocket.when(IntegrationPaths.pingUri,
          handler: (Uri uri, {protocols, headers}) async =>
              mockPingWebSocketServer);
    });

    tearDown(() async {
      await Future.wait([
        mockCloseWebSocketServer.shutDown(),
        mockEchoWebSocketServer.shutDown(),
        mockPingWebSocketServer.shutDown(),
      ]);
      MockTransports.verifyNoOutstandingExceptions();
      await MockTransports.uninstall();
    });

    runCommonWebSocketIntegrationTests();
  });

  group(naming.toString() + ' legacy', () {
    setUp(() {
      MockTransports.install();

      MockTransports.webSocket
          .when(IntegrationPaths.fourOhFourUri, reject: true);

      final closeServer = MockWebSocketServer()
        ..onClientConnected.listen((connection) {
          connection.onData((data) {
            if (data.startsWith('close')) {
              final parts = data.split(':');
              int closeCode;
              String closeReason;
              if (parts.length >= 2) {
                closeCode = int.parse(parts[1]);
              }
              if (parts.length >= 3) {
                closeReason = parts[2];
              }
              connection.close(closeCode, closeReason);
            }
          });
        });
      MockTransports.webSocket.when(IntegrationPaths.closeUri,
          handler: (Uri uri, {protocols, headers}) async => closeServer);

      final echoServer = MockWebSocketServer()
        ..onClientConnected.listen((connection) {
          connection.onData(connection.send);
        });
      MockTransports.webSocket.when(IntegrationPaths.echoUri,
          handler: (Uri uri, {protocols, headers}) async => echoServer);

      final pingServer = MockWebSocketServer()
        ..onClientConnected.listen((connection) {
          connection.onData((data) async {
            data = data.replaceAll('ping', '');
            int numPongs = 1;
            try {
              numPongs = int.parse(data);
            } catch (_) {}
            for (int i = 0; i < numPongs; i++) {
              await Future.delayed(Duration(milliseconds: 5));
              connection.send('pong');
            }
          });
        });
      MockTransports.webSocket.when(IntegrationPaths.pingUri,
          handler: (Uri uri, {protocols, headers}) async => pingServer);
    });

    tearDown(() async {
      MockTransports.verifyNoOutstandingExceptions();
      await MockTransports.uninstall();
    });

    runCommonWebSocketIntegrationTests();
  });
}
