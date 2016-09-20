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

import 'dart:math';
import 'package:w_transport/src/http/auto_retry.dart';

class Backoff {
  static const int base = 2;

  static Duration _createExponentialBackOff(RequestAutoRetry autoRetry) {
    int backOffInMs = autoRetry.backOff.interval.inMilliseconds *
        pow(base, autoRetry.numAttempts);
    backOffInMs =
        min(autoRetry.backOff.maxInterval.inMilliseconds, backOffInMs);

    if (autoRetry.backOff.withJitter == true) {
      final random = new Random();
      backOffInMs = random.nextInt(backOffInMs);
    }
    return new Duration(milliseconds: backOffInMs);
  }

  static Duration _createFixedBackOff(RequestAutoRetry autoRetry) {
    Duration backOff;

    if (autoRetry.backOff.withJitter == true) {
      final random = new Random();
      backOff = new Duration(
          milliseconds: autoRetry.backOff.interval.inMilliseconds ~/ 2 +
              random
                  .nextInt(autoRetry.backOff.interval.inMilliseconds)
                  .toInt());
    } else {
      backOff = autoRetry.backOff.interval;
    }

    return backOff;
  }

  /// Calculate the backoff duration based on [RequestAutoRetry] configuration.
  /// Returns [null] if backoff is not applicable.
  static Duration calculateBackOff(RequestAutoRetry autoRetry) {
    Duration backOff;
    switch (autoRetry.backOff.method) {
      case RetryBackOffMethod.exponential:
        backOff = _createExponentialBackOff(autoRetry);
        break;
      case RetryBackOffMethod.fixed:
        backOff = _createFixedBackOff(autoRetry);
        break;
      case RetryBackOffMethod.none:
      default:
        break;
    }
    return backOff;
  }
}
