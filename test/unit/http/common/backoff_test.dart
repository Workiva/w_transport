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
import 'package:w_transport/w_transport_mock.dart';

import '../../../naming.dart';

void main() {
  configureWTransportForTest();

  Naming naming = new Naming()
    ..platform = platformBrowser
    ..testType = testTypeUnit
    ..topic = topicBackoff;

  group(naming.toString(), () {
    group('ExponentialBackOff : ', () {
      test('no jitter, maxInterval not exceeded', () async {
        var request = new Request();
        Duration interval = new Duration(milliseconds: 5);
        Duration maxInterval = new Duration(milliseconds: 400);
        bool withJitter = false;
        request.autoRetry.backOff = new RetryBackOff.exponential(interval,
            withJitter: withJitter, maxInterval: maxInterval);

        for (var i = 0; i < 5; i++) {
          request.autoRetry.numAttempts = i;

          if (i == 0) {
            expect(Backoff.calculateBackOff(request.autoRetry).inMilliseconds,
                equals(interval.inMilliseconds));
          } else {
            expect(
                Backoff.calculateBackOff(request.autoRetry).inMilliseconds,
                equals(interval.inMilliseconds *
                    pow(Backoff.defaultExponentialMultiplier,
                        request.autoRetry.numAttempts)));
          }
        }
      });

      test('with jitter, maxInterval not exceeded', () async {
        var request = new Request();
        Duration interval = new Duration(milliseconds: 5);
        Duration maxInterval = new Duration(milliseconds: 400);
        bool withJitter = true;
        request.autoRetry.backOff = new RetryBackOff.exponential(interval,
            withJitter: withJitter, maxInterval: maxInterval);

        for (var i = 0; i < 5; i++) {
          request.autoRetry.numAttempts = i;

          if (i == 0) {
            expect(Backoff.calculateBackOff(request.autoRetry).inMilliseconds,
                lessThanOrEqualTo(interval.inMilliseconds));
          } else {
            expect(
                Backoff.calculateBackOff(request.autoRetry).inMilliseconds,
                lessThanOrEqualTo(interval.inMilliseconds *
                    pow(Backoff.defaultExponentialMultiplier,
                        request.autoRetry.numAttempts)));
          }
        }
      });

      test('no jitter, maxInterval is exceeded', () async {
        var request = new Request();
        Duration interval = new Duration(milliseconds: 5);
        Duration maxInterval = new Duration(milliseconds: 20);
        bool withJitter = false;
        request.autoRetry.backOff = new RetryBackOff.exponential(interval,
            withJitter: withJitter, maxInterval: maxInterval);

        for (var i = 0; i < 5; i++) {
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
        var request = new Request();
        Duration interval = new Duration(milliseconds: 5);
        Duration maxInterval = new Duration(milliseconds: 20);
        bool withJitter = true;
        request.autoRetry.backOff = new RetryBackOff.exponential(interval,
            withJitter: withJitter, maxInterval: maxInterval);

        for (var i = 0; i < 50; i++) {
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
      test('no jitter', () async {
        var request = new Request();
        Duration interval = new Duration(milliseconds: 5);
        bool withJitter = false;
        request.autoRetry.backOff =
            new RetryBackOff.fixed(interval, withJitter: withJitter);

        for (var i = 0; i < 5; i++) {
          request.autoRetry.numAttempts = i;

          if (i == 0) {
            expect(Backoff.calculateBackOff(request.autoRetry).inMilliseconds,
                equals(interval.inMilliseconds));
          }
        }
      });

      test('with jitter', () async {
        var request = new Request();
        Duration interval = new Duration(milliseconds: 5);
        bool withJitter = true;
        request.autoRetry.backOff =
            new RetryBackOff.fixed(interval, withJitter: withJitter);

        for (var i = 0; i < 5; i++) {
          int backoff =
              Backoff.calculateBackOff(request.autoRetry).inMilliseconds;
          expect(backoff, lessThanOrEqualTo(interval.inMilliseconds * 1.5));
          expect(backoff, greaterThanOrEqualTo(interval.inMilliseconds ~/ 2));
        }
      });
    });
  });
}
