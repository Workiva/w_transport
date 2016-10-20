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
import 'dart:html';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:w_transport/browser.dart';
import 'package:w_transport/w_transport.dart' as transport;

import '../../naming.dart';
import '../integration_paths.dart';
import 'common.dart';

const int sockjsPort = 8026;

void main() {
  final wsNaming = new Naming()
    ..platform = platformBrowserSockjsWS
    ..testType = testTypeIntegration
    ..topic = topicWebSocket;

  final xhrNaming = new Naming()
    ..platform = platformBrowserSockjsXhr
    ..testType = testTypeIntegration
    ..topic = topicWebSocket;

  final wsDeprecatedNaming = new Naming()
    ..platform = platformBrowserSockjsWSDeprecated
    ..testType = testTypeIntegration
    ..topic = topicWebSocket;

  final xhrDeprecatedNaming = new Naming()
    ..platform = platformBrowserSockjsXhrDeprecated
    ..testType = testTypeIntegration
    ..topic = topicWebSocket;

  group(wsNaming.toString(), () {
    sockJSSuite((Uri uri) => transport.WebSocket.connect(uri,
        useSockJS: true,
        sockJSNoCredentials: true,
        sockJSProtocolsWhitelist: ['websocket'],
        transportPlatform: browserTransportPlatform));
  });

  group(xhrNaming.toString(), () {
    sockJSSuite((Uri uri) => transport.WebSocket.connect(uri,
        useSockJS: true,
        sockJSNoCredentials: true,
        sockJSProtocolsWhitelist: ['xhr-streaming'],
        transportPlatform: browserTransportPlatform));
  });

  group(wsDeprecatedNaming.toString(), () {
    sockJSSuite((Uri uri) => transport.WebSocket.connect(uri,
        transportPlatform: new BrowserTransportPlatformWithSockJS(
            sockJSNoCredentials: true,
            sockJSProtocolsWhitelist: ['websocket'])));
  });

  group(xhrDeprecatedNaming.toString(), () {
    sockJSSuite((Uri uri) => transport.WebSocket.connect(uri,
        transportPlatform: new BrowserTransportPlatformWithSockJS(
            sockJSNoCredentials: true,
            sockJSProtocolsWhitelist: ['xhr-streaming'])));
  });
}

void sockJSSuite(Future<transport.WebSocket> connect(Uri uri)) {
  runCommonWebSocketIntegrationTests(connect: connect, port: sockjsPort);

  final echoUri = IntegrationPaths.echoUri.replace(port: sockjsPort);
  final pingUri = IntegrationPaths.pingUri.replace(port: sockjsPort);

  test('should not support Blob', () async {
    final blob = new Blob(['one', 'two']);
    final socket = await connect(pingUri);
    expect(() {
      socket.add(blob);
    }, throwsArgumentError);
    await socket.close();
  });

  test('should support String', () async {
    final data = 'data';
    final socket = await connect(echoUri);
    socket.add(data);
    await socket.close();
  });

  test('should not support TypedData', () async {
    final data = new Uint16List.fromList([1, 2, 3]);
    final socket = await connect(echoUri);
    expect(() {
      socket.add(data);
    }, throwsArgumentError);
    await socket.close();
  });

  test('should throw when attempting to send invalid data', () async {
    final socket = await connect(pingUri);
    expect(() {
      socket.add(true);
    }, throwsArgumentError);
    await socket.close();
  });
}
