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

const int sockjsPort = 8026;

void main() {
  final wsDeprecatedNaming = new Naming()
    ..platform = platformBrowserSockjsWSDeprecated
    ..testType = testTypeIntegration
    ..topic = topicGlobalWebSocketMonitor;

  final xhrDeprecatedNaming = new Naming()
    ..platform = platformBrowserSockjsXhrDeprecated
    ..testType = testTypeIntegration
    ..topic = topicGlobalWebSocketMonitor;

  final wsNaming = new Naming()
    ..platform = platformBrowserSockjsWS
    ..testType = testTypeIntegration
    ..topic = topicGlobalWebSocketMonitor;

  final xhrNaming = new Naming()
    ..platform = platformBrowserSockjsXhr
    ..testType = testTypeIntegration
    ..topic = topicGlobalWebSocketMonitor;

  group(wsDeprecatedNaming.toString(), () {
    var protocolsWhitelist = ['websocket'];

    sockJSSuite(
        (Uri uri) => transport.WebSocket.connect(uri,
            // ignore: deprecated_member_use
            useSockJS: true,
            // ignore: deprecated_member_use
            sockJSNoCredentials: true,
            // ignore: deprecated_member_use
            sockJSProtocolsWhitelist: protocolsWhitelist,
            transportPlatform: browserTransportPlatform),
        protocolsWhitelist);
  });

  group(xhrDeprecatedNaming.toString(), () {
    var protocolsWhitelist = ['xhr-streaming'];

    sockJSSuite(
        (Uri uri) => transport.WebSocket.connect(uri,
            // ignore: deprecated_member_use
            useSockJS: true,
            // ignore: deprecated_member_use
            sockJSNoCredentials: true,
            // ignore: deprecated_member_use
            sockJSProtocolsWhitelist: protocolsWhitelist,
            transportPlatform: browserTransportPlatform),
        protocolsWhitelist);
  });

  group(wsNaming.toString(), () {
    var protocolsWhitelist = ['websocket'];

    sockJSSuite(
        (Uri uri) => transport.WebSocket.connect(uri,
            transportPlatform: new BrowserTransportPlatformWithSockJS(
                sockJSNoCredentials: true,
                sockJSProtocolsWhitelist: protocolsWhitelist)),
        protocolsWhitelist);
  });

  group(xhrNaming.toString(), () {
    var protocolsWhitelist = ['xhr-streaming'];

    sockJSSuite(
        (Uri uri) => transport.WebSocket.connect(uri,
            transportPlatform: new BrowserTransportPlatformWithSockJS(
                sockJSNoCredentials: true,
                sockJSProtocolsWhitelist: protocolsWhitelist)),
        protocolsWhitelist);
  });
}

void sockJSSuite(Future<transport.WebSocket> connect(Uri uri),
    List<String> protocolsWhitelist) {
  runCommonGlobalWebSocketMonitorIntegrationTests(connect, port: sockjsPort);

  var echoUri = IntegrationPaths.echoUri.replace(port: sockjsPort);
  var fourOhFourUri = IntegrationPaths.fourOhFourUri;

  test('didAttemptToConnect events should include sockJS info', () async {
    var monitor = transport.WebSocket.getGlobalEventMonitor();
    var events = <transport.WebSocketConnectEvent>[];
    monitor.didAttemptToConnect.listen(events.add);

    var webSocket = await connect(echoUri);
    await webSocket.close();

    await connect(fourOhFourUri).catchError((_) {});

    await monitor.close();

    expect(events.length, equals(2));

    expect(events[0].url, equals(echoUri.toString()));
    expect(events[0].wasSuccessful, isTrue);
    expect(events[0].sockJsProtocolsWhitelist, equals(protocolsWhitelist));
    expect(events[0].sockJsSelectedProtocol, equals(protocolsWhitelist.last));

    expect(events[1].url, equals(fourOhFourUri.toString()));
    expect(events[1].wasSuccessful, isFalse);
    expect(events[1].sockJsProtocolsWhitelist, equals(protocolsWhitelist));
    expect(events[1].sockJsSelectedProtocol, isNull);
  });
}
