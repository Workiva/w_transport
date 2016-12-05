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
        final onCancelCalled = new Completer<Null>();

        final sc = new StreamController<dynamic>();
        final sub = sc.stream.listen((_) {});
        final wsub = new WSocketSubscription(sub, () {},
            onCancel: onCancelCalled.complete);

        await Future.wait([
          wsub.cancel(),
          onCancelCalled.future,
        ]);
      });

      test('isPaused should return the status of the underlying subscription',
          () {
        final sc = new StreamController<dynamic>();
        final sub = sc.stream.listen((_) {});
        final wsub = new WSocketSubscription(sub, () {});

        expect(sub.isPaused, isFalse);
        expect(wsub.isPaused, isFalse);

        sub.pause();
        expect(sub.isPaused, isTrue);
        expect(wsub.isPaused, isTrue);
      });

      test('onDone() should update the done handler', () {
        final sub = new MockStreamSubscription();
        final wsub = new WSocketSubscription(sub, () {});
        final doneHandler = () {};

        wsub.onDone(doneHandler);
        expect(wsub.doneHandler, equals(doneHandler));
      });

      test('onError() should call onError() on the underlying subscription',
          () {
        final sub = new MockStreamSubscription();
        final wsub = new WSocketSubscription(sub, () {});
        final errorHandler = (_) {};

        wsub.onError(errorHandler);
        verify(sub.onError(errorHandler));
      });

      test('onData() should call onData() on the underlying subscription', () {
        final sub = new MockStreamSubscription();
        final wsub = new WSocketSubscription(sub, () {});
        final dataHandler = (_) {};

        wsub.onData(dataHandler);
        verify(sub.onData(dataHandler));
      });
    });
  });
}

class MockStreamSubscription<T> extends Mock implements StreamSubscription<T> {}
