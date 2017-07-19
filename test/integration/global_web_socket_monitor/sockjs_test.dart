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
import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_browser.dart';

import '../../naming.dart';
import '../integration_paths.dart';
import 'common.dart';

const int sockjsPort = 8026;

void main() {
  Naming wsNaming = new Naming()
    ..platform = platformBrowserSockjsWS
    ..testType = testTypeIntegration
    ..topic = topicGlobalWebSocketMonitor;

  Naming xhrNaming = new Naming()
    ..platform = platformBrowserSockjsXhr
    ..testType = testTypeIntegration
    ..topic = topicGlobalWebSocketMonitor;

  Naming wsDeprecatedNaming = new Naming()
    ..platform = platformBrowserSockjsWSDeprecated
    ..testType = testTypeIntegration
    ..topic = topicGlobalWebSocketMonitor;

  Naming xhrDeprecatedNaming = new Naming()
    ..platform = platformBrowserSockjsXhrDeprecated
    ..testType = testTypeIntegration
    ..topic = topicGlobalWebSocketMonitor;

  group(wsNaming.toString(), () {
    setUp(() {
      configureWTransportForBrowser();
    });

    var protocolsWhitelist = ['websocket'];
    sockJSSuite(
        (Uri uri) => WSocket.connect(uri,
            useSockJS: true,
            sockJSNoCredentials: true,
            sockJSProtocolsWhitelist: protocolsWhitelist),
        protocolsWhitelist);
  });

  group(xhrNaming.toString(), () {
    setUp(() {
      configureWTransportForBrowser();
    });

    var protocolsWhitelist = ['xhr-streaming'];
    sockJSSuite(
        (Uri uri) => WSocket.connect(uri,
            useSockJS: true,
            sockJSNoCredentials: true,
            sockJSProtocolsWhitelist: protocolsWhitelist),
        protocolsWhitelist);
  });

  group(wsDeprecatedNaming.toString(), () {
    var protocolsWhitelist = ['websocket'];

    setUp(() {
      configureWTransportForBrowser(
          useSockJS: true,
          sockJSNoCredentials: true,
          sockJSProtocolsWhitelist: protocolsWhitelist);
    });

    sockJSSuite((Uri uri) => WSocket.connect(uri), protocolsWhitelist);
  });

  group(xhrDeprecatedNaming.toString(), () {
    var protocolsWhitelist = ['xhr-streaming'];

    setUp(() {
      configureWTransportForBrowser(
          useSockJS: true,
          sockJSNoCredentials: true,
          sockJSProtocolsWhitelist: protocolsWhitelist);
    });

    sockJSSuite((Uri uri) => WSocket.connect(uri), protocolsWhitelist);
  });
}

void sockJSSuite(connect(Uri uri), List<String> protocolsWhitelist) {
  runCommonGlobalWebSocketMonitorIntegrationTests(
      connect: connect, port: sockjsPort);

  var echoUri = IntegrationPaths.echoUri.replace(port: sockjsPort);
  var fourOhFourUri = IntegrationPaths.fourOhFourUri;

  test('didAttemptToConnect events should include sockJS info', () async {
    var monitor = WSocket.getGlobalEventMonitor();
    var events = <WebSocketConnectEvent>[];
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
