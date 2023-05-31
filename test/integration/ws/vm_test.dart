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

@TestOn('vm')
import 'package:test/test.dart';
import 'package:w_transport/vm.dart';
import 'package:w_transport/w_transport.dart' as transport;

import '../../naming.dart';
import '../integration_paths.dart';
import 'common.dart';

void main() {
  final naming = Naming()
    ..platform = platformVM
    ..testType = testTypeIntegration
    ..topic = topicWebSocket;

  group(naming.toString(), () {
    runCommonWebSocketIntegrationTests(transportPlatform: vmTransportPlatform);

    test('should support List<int>', () async {
      final data = <int>[1, 2, 3];
      final socket = await (transport.WebSocket.connect(IntegrationPaths.echoUri,
          transportPlatform: vmTransportPlatform) as FutureOr<WebSocket>);
      socket.add(data);
      await socket.close();
    });

    test('should support String', () async {
      const data = 'data';
      final socket = await (transport.WebSocket.connect(IntegrationPaths.echoUri,
          transportPlatform: vmTransportPlatform) as FutureOr<WebSocket>);
      socket.add(data);
      await socket.close();
    });

    test('should throw when attempting to send invalid data', () async {
      final socket = await (transport.WebSocket.connect(IntegrationPaths.pingUri,
          transportPlatform: vmTransportPlatform) as FutureOr<WebSocket>);
      expect(() {
        socket.add(true);
      }, throwsArgumentError);
      await socket.close();
    });
  });
}
