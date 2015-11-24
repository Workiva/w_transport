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
library w_transport.test.integration.ws.sockjs_test;

import 'dart:html';
import 'dart:typed_data';

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
    ..topic = topicWebSocket;

  Naming xhrNaming = new Naming()
    ..platform = platformBrowserSockjsXhr
    ..testType = testTypeIntegration
    ..topic = topicWebSocket;

  group(wsNaming.toString(), () {
    setUp(() {
      configureWTransportForBrowser(
          useSockJS: true,
          sockJSNoCredentials: true,
          sockJSProtocolsWhitelist: ['websocket']);
    });

    sockJSSuite();
  });

  group(xhrNaming.toString(), () {
    setUp(() {
      configureWTransportForBrowser(
          useSockJS: true,
          sockJSNoCredentials: true,
          sockJSProtocolsWhitelist: ['xhr-streaming']);
    });

    sockJSSuite();
  });
}

sockJSSuite() {
  runCommonWebSocketIntegrationTests(port: sockjsPort);

  var echoUri = IntegrationPaths.echoUri.replace(port: sockjsPort);
  var pingUri = IntegrationPaths.pingUri.replace(port: sockjsPort);

  test('should not support Blob', () async {
    Blob blob = new Blob(['one', 'two']);
    WSocket socket = await WSocket.connect(pingUri);
    expect(() {
      socket.add(blob);
    }, throwsArgumentError);
    socket.close();
  });

  test('should support String', () async {
    String data = 'data';
    WSocket socket = await WSocket.connect(echoUri);
    socket.add(data);
    socket.close();
  });

  test('should not support TypedData', () async {
    TypedData data = new Uint16List.fromList([1, 2, 3]);
    WSocket socket = await WSocket.connect(echoUri);
    expect(() {
      socket.add(data);
    }, throwsArgumentError);
    socket.close();
  });

  test('should throw when attempting to send invalid data', () async {
    WSocket socket = await WSocket.connect(pingUri);
    expect(() {
      socket.add(true);
    }, throwsArgumentError);
    socket.close();
  });
}
