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
library w_transport.test.unit.http.w_response_test;

import 'dart:async';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_mock.dart';

void main() {
  configureWTransportForTest();

  group('WResponse', () {
    test(
        'internally cached source stream should handling pausing and resuming a subscription',
        () async {
      StreamController controller = new StreamController();
      MockWResponse response = new MockWResponse.ok(body: controller.stream);

      int count = 0;
      Completer c = new Completer();
      StreamSubscription subscription = response.asStream().listen((_) {
        count++;
      }, onDone: c.complete);

      controller.add(1);
      subscription.pause();
      controller.add(2);
      controller.add(3);
      subscription.resume();
      controller.add(4);

      controller.close();
      await c.future;
      expect(count, equals(4));
    });
  });
}
