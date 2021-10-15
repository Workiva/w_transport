@TestOn('browser')
import 'package:test/test.dart';
import 'package:w_transport/browser.dart';
import 'package:w_transport/w_transport.dart';

import '../../naming.dart';

void main() {
  final sockjsNaming = Naming()
    ..platform = platformBrowserSockjsWrapper
    ..testType = testTypeIntegration
    ..topic = topicWebSocket;
  group(sockjsNaming, () {
    test('throws if sockjs.js is missing', () {
      expect(
          WebSocket.connect(Uri.parse('ws://foo'),
              transportPlatform: browserTransportPlatformWithSockJS),
          throwsA(isA<MissingSockJSException>()));
    });
  });
}
