@TestOn('browser')
library w_transport.test.integration.w_socket_client_integration_test;

import 'dart:html';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart' show WSocket, WSocketException;
import 'package:w_transport/w_transport_client.dart'
    show configureWTransportForBrowser;

import 'w_socket_common.dart' as common_tests;

void main() {
  configureWTransportForBrowser();

  common_tests.run('Client');

  group('WSocket (Client)', () {
    WSocket socket;
    Uri closeUri;
    Uri echoUri;
    Uri pingUri;

    setUp(() {
      closeUri = Uri.parse('ws://localhost:8024/test/ws/close');
      echoUri = Uri.parse('ws://localhost:8024/test/ws/echo');
      pingUri = Uri.parse('ws://localhost:8024/test/ws/ping');
    });

    tearDown(() {
      if (socket != null) {
        socket.close();
      }
    });

    group('data validation', () {
      test('should support Blob', () async {
        Blob blob = new Blob(['one', 'two']);
        socket = await WSocket.connect(echoUri);
        socket.add(blob);
      });

      test('should support String', () async {
        String data = 'data';
        socket = await WSocket.connect(echoUri);
        socket.add(data);
      });

      test('should support TypedData', () async {
        TypedData data = new Uint16List.fromList([1, 2, 3]);
        socket = await WSocket.connect(echoUri);
        socket.add(data);
      });
    });
  });
}
