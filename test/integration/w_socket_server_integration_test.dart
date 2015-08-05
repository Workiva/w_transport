@TestOn('vm')
library w_transport.test.integration.w_socket_server_integration_test;

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

    tearDown(() {
      if (socket != null) {
        socket.close();
      }
    });

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
