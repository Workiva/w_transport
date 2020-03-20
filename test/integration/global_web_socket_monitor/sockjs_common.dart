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

import 'package:test/test.dart';
import 'package:w_transport/browser.dart';
import 'package:w_transport/w_transport.dart' as transport;

import '../../naming.dart';
import '../integration_paths.dart';
import 'common.dart';

const _sockjsPort = 8026;

void runCommonSockJSSuite(List<String> protocolsToTest,
    {bool usingSockjsPort = true}) {
  final sockjsPortNaming = Naming()
    ..platform = usingSockjsPort
        ? platformBrowserSockjsPort
        : platformBrowserSockjsWrapper
    ..testType = testTypeIntegration
    ..topic = topicGlobalWebSocketMonitor;

  final sockjsPortDeprecatedNaming = Naming()
    ..platform = usingSockjsPort
        ? platformBrowserSockjsPortDeprecated
        : platformBrowserSockjsWrapperDeprecated
    ..testType = testTypeIntegration
    ..topic = topicGlobalWebSocketMonitor;

  group(sockjsPortNaming.toString(), () {
    _sockJSSuite(
        protocolsToTest,
        (Uri uri, String protocol) => transport.WebSocket.connect(uri,
            transportPlatform: BrowserTransportPlatformWithSockJS(
                sockJSNoCredentials: true,
                sockJSProtocolsWhitelist: [protocol])));
  });

  group(sockjsPortDeprecatedNaming.toString(), () {
    _sockJSSuite(
        protocolsToTest,
        (Uri uri, String protocol) => transport.WebSocket.connect(uri,
            // ignore: deprecated_member_use_from_same_package
            useSockJS: true,
            // ignore: deprecated_member_use_from_same_package
            sockJSNoCredentials: true,
            // ignore: deprecated_member_use_from_same_package
            sockJSProtocolsWhitelist: [protocol],
            transportPlatform: browserTransportPlatform));
  });
}

void _sockJSSuite(List<String> protocolsToTest,
    Future<transport.WebSocket> connect(Uri uri, String protocol)) {
  for (final protocol in protocolsToTest) {
    group('(protocol=$protocol)', () {
      runCommonGlobalWebSocketMonitorIntegrationTests(
          (Uri uri) => connect(uri, protocol),
          port: _sockjsPort);

      var echoUri = IntegrationPaths.echoUri.replace(port: _sockjsPort);
      var fourOhFourUri = IntegrationPaths.fourOhFourUri;

      test('didAttemptToConnect events should include SockJS info', () async {
        var monitor = transport.WebSocket.getGlobalEventMonitor();
        var events = <transport.WebSocketConnectEvent>[];
        monitor.didAttemptToConnect.listen(events.add);

        var webSocket = await connect(echoUri, protocol);
        await webSocket.close();

        await connect(fourOhFourUri, protocol).catchError((_) {});

        await monitor.close();

        expect(events.length, equals(2));

        expect(events[0].url, equals(echoUri.toString()));
        expect(events[0].wasSuccessful, isTrue);
        expect(events[0].sockJsProtocolsWhitelist, equals([protocol]));
        expect(events[0].sockJsSelectedProtocol, equals(protocol));

        expect(events[1].url, equals(fourOhFourUri.toString()));
        expect(events[1].wasSuccessful, isFalse);
        expect(events[1].sockJsProtocolsWhitelist, equals([protocol]));
        expect(events[1].sockJsSelectedProtocol, isNull);
      });
    });
  }
}
