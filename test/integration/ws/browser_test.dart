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
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/browser.dart';

import '../../naming.dart';
import '../integration_paths.dart';
import 'common.dart';

void main() {
  final naming = new Naming()
    ..platform = platformBrowser
    ..testType = testTypeIntegration
    ..topic = topicWebSocket;

  group(naming.toString(), () {
    setUp(() {
      configureWTransportForBrowser();
    });

    runCommonWebSocketIntegrationTests();

    test('should support Blob', () async {
      final blob = new Blob(['one', 'two']);
      final socket = await WSocket.connect(IntegrationPaths.echoUri);
      socket.add(blob);
      await socket.close();
    });

    test('should support String', () async {
      final data = 'data';
      final socket = await WSocket.connect(IntegrationPaths.echoUri);
      socket.add(data);
      await socket.close();
    });

    test('should support TypedData', () async {
      final data = new Uint16List.fromList([1, 2, 3]);
      final socket = await WSocket.connect(IntegrationPaths.echoUri);
      socket.add(data);
      await socket.close();
    });

    test('should throw when attempting to send invalid data', () async {
      final socket = await WSocket.connect(IntegrationPaths.pingUri);
      expect(() {
        socket.add(true);
      }, throwsArgumentError);
      await socket.close();
    });
  });
}
