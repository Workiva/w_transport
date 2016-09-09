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
import 'dart:math';

import 'package:test/test.dart';

import 'package:w_transport/src/http/auto_retry.dart';
import 'package:w_transport/src/http/requests.dart';
import 'package:w_transport/src/http/common/backoff.dart';
import 'package:w_transport/mock.dart';

import '../../naming.dart';

void main() {
  configureWTransportForTest();

  final naming = new Naming()
    ..platform = platformBrowser
    ..testType = testTypeUnit
    ..topic = topicBackoff;

  group(naming.toString(), () {
    group('ExponentialBackOff : ', () {
      test('deprecated `duration` should be forwarded to `interval`', () {
        final interval = new Duration(seconds: 10);
        final backOff = new RetryBackOff.exponential(interval);
        expect(backOff.duration, equals(interval));
        expect(backOff.duration, equals(backOff.interval));
      });

      test('no jitter, maxInterval not exceeded', () async {
        final request = new Request();
        final interval = new Duration(milliseconds: 5);
        final maxInterval = new Duration(milliseconds: 400);
        final withJitter = false;
        request.autoRetry.backOff = new RetryBackOff.exponential(interval,
            withJitter: withJitter, maxInterval: maxInterval);

        for (int i = 0; i < 5; i++) {
          request.autoRetry.numAttempts = i;

          if (i == 0) {
            expect(Backoff.calculateBackOff(request.autoRetry).inMilliseconds,
                equals(interval.inMilliseconds));
          } else {
            expect(
                Backoff.calculateBackOff(request.autoRetry).inMilliseconds,
                equals(interval.inMilliseconds *
                    pow(Backoff.base, request.autoRetry.numAttempts)));
          }
        }
      });

      test('with jitter, maxInterval not exceeded', () async {
        final request = new Request();
        final interval = new Duration(milliseconds: 5);
        final maxInterval = new Duration(milliseconds: 400);
        final withJitter = true;
        request.autoRetry.backOff = new RetryBackOff.exponential(interval,
            withJitter: withJitter, maxInterval: maxInterval);

        for (int i = 0; i < 5; i++) {
          request.autoRetry.numAttempts = i;

          if (i == 0) {
            expect(Backoff.calculateBackOff(request.autoRetry).inMilliseconds,
                lessThanOrEqualTo(interval.inMilliseconds));
          } else {
            expect(
                Backoff.calculateBackOff(request.autoRetry).inMilliseconds,
                lessThanOrEqualTo(interval.inMilliseconds *
                    pow(Backoff.base, request.autoRetry.numAttempts)));
          }
        }
      });

      test('no jitter, maxInterval is exceeded', () async {
        final request = new Request();
        final interval = new Duration(milliseconds: 5);
        final maxInterval = new Duration(milliseconds: 20);
        final withJitter = false;
        request.autoRetry.backOff = new RetryBackOff.exponential(interval,
            withJitter: withJitter, maxInterval: maxInterval);

        for (int i = 0; i < 5; i++) {
          request.autoRetry.numAttempts = i;

          if (i == 0) {
            expect(Backoff.calculateBackOff(request.autoRetry).inMilliseconds,
                equals(interval.inMilliseconds));
          } else if (i == 1) {
            expect(Backoff.calculateBackOff(request.autoRetry).inMilliseconds,
                equals(10));
          } else {
            expect(Backoff.calculateBackOff(request.autoRetry).inMilliseconds,
                equals(request.autoRetry.backOff.maxInterval.inMilliseconds));
          }
        }
      });

      test('with jitter, maxInterval is exceeded', () async {
        final request = new Request();
        final interval = new Duration(milliseconds: 5);
        final maxInterval = new Duration(milliseconds: 20);
        final withJitter = true;
        request.autoRetry.backOff = new RetryBackOff.exponential(interval,
            withJitter: withJitter, maxInterval: maxInterval);

        for (int i = 0; i < 50; i++) {
          request.autoRetry.numAttempts = i;

          if (i == 0) {
            expect(Backoff.calculateBackOff(request.autoRetry).inMilliseconds,
                lessThanOrEqualTo(interval.inMilliseconds));
          } else if (i == 1) {
            expect(
                Backoff.calculateBackOff(request.autoRetry).inMilliseconds,
                lessThanOrEqualTo(
                    request.autoRetry.backOff.maxInterval.inMilliseconds));
          } else {
            expect(
                Backoff.calculateBackOff(request.autoRetry).inMilliseconds,
                lessThanOrEqualTo(
                    request.autoRetry.backOff.maxInterval.inMilliseconds));
          }
        }
      });
    });

    group('FixedBackOff : ', () {
      test('deprecated `duration` should be forwarded to `interval`', () {
        final interval = new Duration(seconds: 10);
        final backOff = new RetryBackOff.fixed(interval);
        expect(backOff.duration, equals(interval));
        expect(backOff.duration, equals(backOff.interval));
      });

      test('no jitter', () async {
        final request = new Request();
        final interval = new Duration(milliseconds: 5);
        final withJitter = false;
        request.autoRetry.backOff =
            new RetryBackOff.fixed(interval, withJitter: withJitter);

        for (int i = 0; i < 5; i++) {
          request.autoRetry.numAttempts = i;

          if (i == 0) {
            expect(Backoff.calculateBackOff(request.autoRetry).inMilliseconds,
                equals(interval.inMilliseconds));
          }
        }
      });

      test('with jitter', () async {
        final request = new Request();
        final interval = new Duration(milliseconds: 5);
        final withJitter = true;
        request.autoRetry.backOff =
            new RetryBackOff.fixed(interval, withJitter: withJitter);

        for (int i = 0; i < 5; i++) {
          final backoff =
              Backoff.calculateBackOff(request.autoRetry).inMilliseconds;
          expect(backoff, lessThanOrEqualTo(interval.inMilliseconds * 1.5));
          expect(backoff, greaterThanOrEqualTo(interval.inMilliseconds ~/ 2));
        }
      });
    });

    group('No Backoff', () {
      test('deprecated `duration` should be forwarded to `interval`', () {
        final backOff = new RetryBackOff.none();
        expect(backOff.duration, isNull);
        expect(backOff.duration, equals(backOff.interval));
      });
    });
  });
}
