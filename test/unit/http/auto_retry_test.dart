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
import '../../naming.dart';
import 'package:w_transport/src/http/auto_retry.dart';
import 'dart:math';

void main() {
  Naming naming = new Naming()
    ..testType = testTypeUnit
    ..topic = topicHttp;

  Duration testDuration = new Duration(milliseconds: 5);
  int testMaxDurationInMs = 111;

  group(naming.toString(), () {
    group('AutoRetry calculateBackOff', () {
      test('without jitter', () {
        RetryBackOff autoRetry =
            new RetryBackOff.exponential(testDuration, enableJitter: false);

        for (int i = 0; i < 1000; i++) {
          int max = testDuration.inMilliseconds * pow(2, i);
          expect(
              autoRetry.calculate(i).inMilliseconds, inInclusiveRange(0, max));
        }
      });

      test('with jitter', () {
        RetryBackOff autoRetry =
            new RetryBackOff.exponential(testDuration, enableJitter: true);
        for (int i = 0; i < 100; i++) {
          int calculatedBackoff = autoRetry.calculate(i).inMilliseconds;
          int max = testDuration.inMilliseconds * pow(2, i);
          expect(calculatedBackoff, inClosedOpenRange(0, max));
          expect(calculatedBackoff,
              lessThanOrEqualTo(RetryBackOff.defaultMaxDurationInMs));
        }
      });

      test('with jitter and maxDuration', () {
        RetryBackOff autoRetry = new RetryBackOff.exponential(testDuration,
            enableJitter: true, maxDurationInMs: testMaxDurationInMs);
        for (int i = 0; i < 100; i++) {
          int calculatedBackoff = autoRetry.calculate(i).inMilliseconds;
          int max = testDuration.inMilliseconds * pow(2, i);
          expect(calculatedBackoff, inClosedOpenRange(0, max));
          expect(calculatedBackoff, lessThanOrEqualTo(testMaxDurationInMs));
        }
      });
    });
  });
}
