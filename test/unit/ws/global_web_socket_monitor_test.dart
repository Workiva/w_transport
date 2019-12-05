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

@TestOn('vm || browser')
import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart' as transport;

import '../../naming.dart';

void main() {
  final naming = Naming()
    ..testType = testTypeUnit
    ..topic = topicGlobalWebSocketMonitor;

  group(naming.toString(), () {
    test(
        'getGlobalWebSocketMonitor() returns correctly from WSocket & WebSocket',
        () async {
      // ignore: deprecated_member_use
      final wSocketMonitor = transport.WSocket.getGlobalEventMonitor();
      final webSocketMonitor = transport.WebSocket.getGlobalEventMonitor();

      expect(wSocketMonitor, isInstanceOf<transport.GlobalWebSocketMonitor>());
      expect(
          webSocketMonitor, isInstanceOf<transport.GlobalWebSocketMonitor>());

      await wSocketMonitor.close();
      await webSocketMonitor.close();
    });
  });
}
