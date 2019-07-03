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

@TestOn('browser')
import 'dart:async';

import 'package:test/test.dart';
import 'package:w_transport/browser.dart';
import 'package:w_transport/w_transport.dart' as transport;

import '../../naming.dart';
import '../integration_paths.dart';
import 'common.dart';

void main() {
  Naming naming = Naming()
    ..platform = platformBrowser
    ..testType = testTypeIntegration
    ..topic = topicGlobalWebSocketMonitor;

  group(naming.toString(), () {
    // ignore: deprecated_member_use
    Future<transport.WebSocket> connect(Uri uri) =>
        transport.WebSocket.connect(uri,
            transportPlatform: browserTransportPlatform);

    runCommonGlobalWebSocketMonitorIntegrationTests(connect);

    test('didAttemptToConnect events should not include sockJS info', () async {
      var monitor = transport.WebSocket.getGlobalEventMonitor();
      var events = <transport.WebSocketConnectEvent>[];
      monitor.didAttemptToConnect.listen(events.add);

      var webSocket = await connect(IntegrationPaths.echoUri);
      await webSocket.close();

      await connect(IntegrationPaths.fourOhFourUri).catchError((_) {});

      await monitor.close();

      expect(events.length, equals(2));

      expect(events[0].url, equals(IntegrationPaths.echoUri.toString()));
      expect(events[0].wasSuccessful, isTrue);
      expect(events[0].sockJsProtocolsWhitelist, isNull);
      expect(events[0].sockJsSelectedProtocol, isNull);

      expect(events[1].url, equals(IntegrationPaths.fourOhFourUri.toString()));
      expect(events[1].wasSuccessful, isFalse);
      expect(events[1].sockJsProtocolsWhitelist, isNull);
      expect(events[1].sockJsSelectedProtocol, isNull);
    });
  });
}
