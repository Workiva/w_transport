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
library w_transport.test.unit.ws.w_socket_test;

import 'dart:async';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_mock.dart';

void main() {
  group('WSocket', () {
    Uri webSocketUri = Uri.parse('ws://mock.com/ws');

    setUp(() {
      configureWTransportForTest();
      MockTransports.reset();
    });

    test('add() should send data to underlying web socket', () async {
      MockWSocket mockWebSocket = new MockWSocket();
      MockTransports.webSocket.expect(webSocketUri, connectTo: mockWebSocket);
      WSocket webSocket = await WSocket.connect(webSocketUri);

      Completer c = new Completer();
      mockWebSocket.onOutgoing(c.complete);

      webSocket.add('message');

      expect(await c.future, equals('message'));
      await webSocket.close();
    });

    test('addStream() should send data to underlying web socket', () async {
      MockWSocket mockWebSocket = new MockWSocket();
      MockTransports.webSocket.expect(webSocketUri, connectTo: mockWebSocket);
      WSocket webSocket = await WSocket.connect(webSocketUri);

      StreamController controller = new StreamController();
      mockWebSocket.onOutgoing(controller.add);

      await webSocket.addStream(new Stream.fromIterable(['one', 'two']));
      controller.close();
      webSocket.close();

      expect(await controller.stream.toList(), equals(['one', 'two']));
    });

    test('addError() should add an error to the underlying web socket',
        () async {
      MockWSocket mockWebSocket = new MockWSocket();
      MockTransports.webSocket.expect(webSocketUri, connectTo: mockWebSocket);
      WSocket webSocket = await WSocket.connect(webSocketUri);

      Completer c = new Completer();
      mockWebSocket.onOutgoingError(c.completeError);
      expect(c.future, throwsException);

      webSocket.addError(new Exception('web socket consumer error'));

      await webSocket.close();
    });
  });
}
