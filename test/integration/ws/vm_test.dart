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
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/vm.dart';

import '../../naming.dart';
import '../integration_paths.dart';
import 'common.dart';

void main() {
  Naming naming = new Naming()
    ..platform = platformVM
    ..testType = testTypeIntegration
    ..topic = topicWebSocket;

  group(naming.toString(), () {
    setUp(() {
      configureWTransportForVM();
    });

    runCommonWebSocketIntegrationTests();

    test('should support List<int>', () async {
      List<int> data = [1, 2, 3];
      WSocket socket = await WSocket.connect(IntegrationPaths.echoUri);
      socket.add(data);
      socket.close();
    });

    test('should support String', () async {
      String data = 'data';
      WSocket socket = await WSocket.connect(IntegrationPaths.echoUri);
      socket.add(data);
      socket.close();
    });

    test('should throw when attempting to send invalid data', () async {
      WSocket socket = await WSocket.connect(IntegrationPaths.pingUri);
      expect(() {
        socket.add(true);
      }, throwsArgumentError);
      socket.close();
    });
  });
}
