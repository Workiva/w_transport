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

@TestOn('vm')
library w_transport.test.integration.ws.w_socket_server_integration_test;

import 'dart:async';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart' show WSocket, WSocketException;
import 'package:w_transport/w_transport_server.dart'
    show configureWTransportForServer;

import 'w_socket_common.dart' as common_tests;

void main() {
  configureWTransportForServer();

  common_tests.run('Server');

  group('WSocket (Server)', () {
    WSocket socket;
    Uri closeUri;
    Uri echoUri;
    Uri pingUri;

    setUp(() {
      closeUri = Uri.parse('ws://localhost:8024/test/ws/close');
      echoUri = Uri.parse('ws://localhost:8024/test/ws/echo');
      pingUri = Uri.parse('ws://localhost:8024/test/ws/ping');
    });

    tearDown(() async {
      if (socket != null) {
        await socket.close();
      }
    });

//    group('addError()', () {
//
//      TODO: Get this test passing.
//      test('should close the socket with an error that can be caught', () async {
//        socket = await WSocket.connect(echoUri);
//
//        // Trigger the socket shutdown by adding an error.
//        socket.addError(new Exception('Exception should close the socket with an error.'));
//
//        var error;
//        try {
//          await socket.done;
//        } catch (e) {
//          error = e;
//        }
//        expect(error, isNotNull);
//        expect(error, isException);
//      });
//
//    });

    group('data validation', () {
      test('should support List<int>', () async {
        List<int> data = [1, 2, 3];
        socket = await WSocket.connect(echoUri);
        socket.add(data);
      });

      test('should support String', () async {
        String data = 'data';
        socket = await WSocket.connect(echoUri);
        socket.add(data);
      });
    });
  });
}
