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

import 'package:test/test.dart';

import 'package:w_transport/src/http/browser/utils.dart'
    show transformProgressEvents;

import '../../naming.dart';

void main() {
  final naming = Naming()
    ..platform = platformBrowser
    ..testType = testTypeUnit
    ..topic = topicHttp;

  group(naming.toString(), () {
    group('utils transformProgressEvents', () {
      test(
          'should convert computable ProgressEvents to WProgress instances with correct values',
          () async {
        final eventStream = Stream<ProgressEvent>.fromIterable([
          MockProgressEvent.computable(0, 100),
          MockProgressEvent.computable(10, 100),
          MockProgressEvent.computable(50, 100),
          MockProgressEvent.computable(73, 100),
          MockProgressEvent.computable(100, 100),
        ]);
        final requestProgressStream =
            eventStream.transform(transformProgressEvents);
        final wEvents = await requestProgressStream.toList();
        expect(wEvents[0].percent, equals(0.0));
        expect(wEvents[1].percent, equals(10.0));
        expect(wEvents[2].percent, equals(50.0));
        expect(wEvents[3].percent, equals(73.0));
        expect(wEvents[4].percent, equals(100.0));
      });

      test(
          'should convert non-computable ProgressEvents to WProgress instances with 0% values',
          () async {
        final events = Stream<ProgressEvent>.fromIterable([
          MockProgressEvent.nonComputable(),
          MockProgressEvent.nonComputable(),
        ]);
        final wEventStream = events.transform(transformProgressEvents);
        final wEvents = await wEventStream.toList();
        expect(wEvents[0].percent, equals(0.0));
        expect(wEvents[1].percent, equals(0.0));
      });

      test('should support pausing and resuming a subscription', () async {
        final eventController = StreamController<ProgressEvent>();
        final wEventStream =
            eventController.stream.transform(transformProgressEvents);

        final c = Completer<void>();
        int eventCount = 0;
        final subscription = wEventStream.listen((_) {
          eventCount++;
        }, onDone: c.complete);

        eventController.add(MockProgressEvent.nonComputable());
        subscription.pause();
        eventController.add(MockProgressEvent.nonComputable());
        eventController.add(MockProgressEvent.nonComputable());
        subscription.resume();
        eventController.add(MockProgressEvent.nonComputable());

        await eventController.close();
        await c.future;
        expect(eventCount, equals(4));
        await subscription.cancel();
      });
    });
  });
}

class MockProgressEvent implements ProgressEvent {
  @override
  bool lengthComputable;

  @override
  int loaded;

  @override
  int total;

  MockProgressEvent.computable(this.loaded, this.total)
      : lengthComputable = true;
  MockProgressEvent.nonComputable() : lengthComputable = false;

  // Silence dart analyzer warnings.
  @override
  dynamic noSuchMethod(Invocation i) =>
      super.noSuchMethod(i); // ignore: unnecessary_overrides
}
