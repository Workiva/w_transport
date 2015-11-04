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
library w_transport.test.unit.http.browser_utils_test;

import 'dart:async';
import 'dart:html';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart' show RequestProgress;

import 'package:w_transport/src/http/browser/utils.dart'
    show transformProgressEvents;

import '../../naming.dart';

void main() {
  Naming naming = new Naming()
    ..platform = platformBrowser
    ..testType = testTypeUnit
    ..topic = topicHttp;

  group(naming.toString(), () {
    group('utils transformProgressEvents', () {
      test(
          'should convert computable ProgressEvents to WProgress instances with correct values',
          () async {
        Stream eventStream = new Stream.fromIterable([
          new MockProgressEvent.computable(0, 100),
          new MockProgressEvent.computable(10, 100),
          new MockProgressEvent.computable(50, 100),
          new MockProgressEvent.computable(73, 100),
          new MockProgressEvent.computable(100, 100),
        ]);
        Stream<RequestProgress> requestProgressStream =
            eventStream.transform(transformProgressEvents);
        List<RequestProgress> wEvents = await requestProgressStream.toList();
        expect(wEvents[0].percent, equals(0.0));
        expect(wEvents[1].percent, equals(10.0));
        expect(wEvents[2].percent, equals(50.0));
        expect(wEvents[3].percent, equals(73.0));
        expect(wEvents[4].percent, equals(100.0));
      });

      test(
          'should convert non-computable ProgressEvents to WProgress instances with 0% values',
          () async {
        Stream events = new Stream.fromIterable([
          new MockProgressEvent.nonComputable(),
          new MockProgressEvent.nonComputable(),
        ]);
        Stream wEventStream = events.transform(transformProgressEvents);
        List<RequestProgress> wEvents = await wEventStream.toList();
        expect(wEvents[0].percent, equals(0.0));
        expect(wEvents[1].percent, equals(0.0));
      });

      test('should support pausing and resuming a subscription', () async {
        StreamController<ProgressEvent> eventController =
            new StreamController();
        Stream<RequestProgress> wEventStream =
            eventController.stream.transform(transformProgressEvents);

        Completer c = new Completer();
        int eventCount = 0;
        StreamSubscription subscription = wEventStream.listen((_) {
          eventCount++;
        }, onDone: c.complete);

        eventController.add(new MockProgressEvent.nonComputable());
        subscription.pause();
        eventController.add(new MockProgressEvent.nonComputable());
        eventController.add(new MockProgressEvent.nonComputable());
        subscription.resume();
        eventController.add(new MockProgressEvent.nonComputable());

        eventController.close();
        await c.future;
        expect(eventCount, equals(4));
      });
    });
  });
}

class MockProgressEvent implements ProgressEvent {
  bool lengthComputable;
  int loaded;
  int total;

  MockProgressEvent.computable(int this.loaded, int this.total)
      : lengthComputable = true;
  MockProgressEvent.nonComputable() : lengthComputable = false;

  // Silence dart analyzer warnings.
  noSuchMethod(i) => super.noSuchMethod(i);
}
