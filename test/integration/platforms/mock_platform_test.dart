@TestOn('browser || vm')
library w_transport.test.integration.platforms.mock_platform_test;

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_mock.dart';

import 'package:w_transport/src/http/mock/client.dart';
import 'package:w_transport/src/http/mock/requests.dart';
import 'package:w_transport/src/web_socket/mock/w_socket.dart';

void main() {
  group('Mock platform adapter', () {

    setUp(() {
      configureWTransportForTest();
    });

    test('newClient()', () {
      expect(new Client(), new isInstanceOf<MockClient>());
    });

    test('newFormRequest()', () {
      expect(new FormRequest(), new isInstanceOf<MockFormRequest>());
    });

    test('newJsonRequest()', () {
      expect(new JsonRequest(), new isInstanceOf<MockJsonRequest>());
    });

    test('newMultipartRequest()', () {
      expect(new MultipartRequest(), new isInstanceOf<MockMultipartRequest>());
    });

    test('newRequest()', () {
      expect(new Request(), new isInstanceOf<MockPlainTextRequest>());
    });

    test('newStreamedRequest()', () {
      expect(new StreamedRequest(), new isInstanceOf<MockStreamedRequest>());
    });

    test('newWSocket()', () async {
      Uri wsUri = Uri.parse('ws://test/ws');
      MockTransports.webSocket.expect(wsUri, connectTo: new MockWSocket());
      expect(await WSocket.connect(wsUri), new isInstanceOf<MockWSocket>());
    });

  });
}