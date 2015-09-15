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
library w_transport.test.unit.http.http_util_common_test;

import 'dart:async';
import 'dart:convert';

import 'package:test/test.dart';

import 'package:w_transport/src/http/common/util.dart'
    show decodeAttempt, encodeAttempt;

void main() {
  test('decodeAttempt should successfully decode stream', () async {
    Stream stream = new Stream.fromIterable(
        [UTF8.encode('first'), UTF8.encode('second'), UTF8.encode('last'),]);
    List<String> decoded = await stream.transform(decodeAttempt(UTF8)).toList();
    expect(decoded, equals(['first', 'second', 'last']));
  });

  test('decodeAttempt should ignore stream values it can\'t decode', () async {
    Stream getStream() => new Stream.fromIterable([
          {'json': true},
          10,
          UTF8.encode('utf8'),
        ]);
    List decoded = await getStream().transform(decodeAttempt(UTF8)).toList();
    expect(
        decoded,
        equals([
          {'json': true},
          10,
          'utf8'
        ]));
  });

  test('encodeAttempt should successfully encode stream', () async {
    Stream stream = new Stream.fromIterable(['first', 'second', 'last',]);
    List<String> decoded = await stream.transform(encodeAttempt(UTF8)).toList();
    expect(
        decoded,
        equals([
          UTF8.encode('first'),
          UTF8.encode('second'),
          UTF8.encode('last'),
        ]));
  });

  test('encodeAttempt should ignore stream values it can\'t encode', () async {
    Stream getStream() => new Stream.fromIterable([
          {'json': true},
          10,
          'utf8',
        ]);
    List decoded = await getStream().transform(encodeAttempt(UTF8)).toList();
    expect(
        decoded,
        equals([
          {'json': true},
          10,
          UTF8.encode('utf8')
        ]));
  });

  test('should support pausing and resuming a subscription', () async {
    StreamController controller = new StreamController();
    Stream stream = controller.stream.transform(decodeAttempt(UTF8));

    Completer c = new Completer();
    int eventCount = 0;
    StreamSubscription subscription = stream.listen((_) {
      eventCount++;
    }, onDone: c.complete);

    controller.add(UTF8.encode('U'));
    subscription.pause();
    controller.add(UTF8.encode('T'));
    controller.add(UTF8.encode('F'));
    subscription.resume();
    controller.add(UTF8.encode('8'));

    controller.close();
    await c.future;
    expect(eventCount, equals(4));
  });
}
