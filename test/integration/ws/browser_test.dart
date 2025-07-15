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
import 'dart:html';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:w_transport/browser.dart';
import 'package:w_transport/w_transport.dart' as transport;

import '../../naming.dart';
import '../integration_paths.dart';
import 'common.dart';

void main() {
  final naming = Naming()
    ..platform = platformBrowser
    ..testType = testTypeIntegration
    ..topic = topicWebSocket;

  group(naming.toString(), () {
    runCommonWebSocketIntegrationTests(
        transportPlatform: browserTransportPlatform);

    test('should support Blob', () async {
      final blob = Blob(['one', 'two']);
      final socket = await transport.WebSocket.connect(IntegrationPaths.echoUri,
          transportPlatform: browserTransportPlatform);
      socket?.add(blob);
      await socket?.close();
    });

    test('should support String', () async {
      const data = 'data';
      final socket = await transport.WebSocket.connect(IntegrationPaths.echoUri,
          transportPlatform: browserTransportPlatform);
      socket?.add(data);
      await socket?.close();
    });

    test('should support TypedData', () async {
      final data = Uint16List.fromList([1, 2, 3]);
      final socket = await transport.WebSocket.connect(IntegrationPaths.echoUri,
          transportPlatform: browserTransportPlatform);
      socket?.add(data);
      await socket?.close();
    });

    test('should support configuring the binaryType to blob', () async {
      final socket = await transport.WebSocket.connect(IntegrationPaths.pingUri,
          transportPlatform: browserTransportPlatform);
      socket?.binaryType = 'blob';
      expect(socket?.binaryType, equals('blob'));
      socket?.add('data');
      await socket?.close();
    });

    test('should support configuring the binaryType to arraybuffer', () async {
      final socket = await transport.WebSocket.connect(IntegrationPaths.pingUri,
          transportPlatform: browserTransportPlatform);
      socket?.binaryType = 'arraybuffer';
      expect(socket?.binaryType, equals('arraybuffer'));
      socket?.add('data');
      await socket?.close();
    });

    test('should throw when attempting to send invalid data', () async {
      final socket = await transport.WebSocket.connect(IntegrationPaths.pingUri,
          transportPlatform: browserTransportPlatform);
      expect(() {
        socket?.add(true);
      }, throwsArgumentError);
      await socket?.close();
    });
  });
}
