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
library w_transport.test.unit.ws.w_socket_subscription_test;

import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:w_transport/src/web_socket/w_socket_subscription.dart';

import '../../naming.dart';

void main() {
  Naming naming = new Naming()
    ..testType = testTypeUnit
    ..topic = topicWebSocket;

  group(naming.toString(), () {
    group('WSocketSubscription', () {
      test('cancel() should cancel underlying subscription and call callback',
          () async {
        var onCancelCalled = new Completer();

        var sc = new StreamController();
        var sub = sc.stream.listen((_) {});
        var wsub = new WSocketSubscription(sub, () {},
            onCancel: onCancelCalled.complete);

        await Future.wait([wsub.cancel(), onCancelCalled.future,]);
      });

      test('isPaused should return the status of the underlying subscription',
          () {
        var sc = new StreamController();
        var sub = sc.stream.listen((_) {});
        var wsub = new WSocketSubscription(sub, () {});

        expect(sub.isPaused, isFalse);
        expect(wsub.isPaused, isFalse);

        sub.pause();
        expect(sub.isPaused, isTrue);
        expect(wsub.isPaused, isTrue);
      });

      test('onDone() should update the done handler', () {
        var sub = new MockStreamSubscription();
        var wsub = new WSocketSubscription(sub, () {});
        var doneHandler = () {};

        wsub.onDone(doneHandler);
        expect(wsub.doneHandler, equals(doneHandler));
      });

      test('onError() should call onError() on the underlying subscription',
          () {
        var sub = new MockStreamSubscription();
        var wsub = new WSocketSubscription(sub, () {});
        var errorHandler = (_) {};

        wsub.onError(errorHandler);
        verify(sub.onError(errorHandler));
      });

      test('onData() should call onData() on the underlying subscription', () {
        var sub = new MockStreamSubscription();
        var wsub = new WSocketSubscription(sub, () {});
        var dataHandler = (_) {};

        wsub.onData(dataHandler);
        verify(sub.onData(dataHandler));
      });
    });
  });
}

class MockStreamSubscription<T> extends Mock implements StreamSubscription<T> {}
