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
import 'package:w_transport/src/http/auto_retry.dart';

void main() {
  group('getRetryTimeoutThreshold', () {
    test('timeoutThreshold is less than 60', () {
      expect(getRetryTimeoutThreshold(Duration(seconds: 30), 0),
          Duration(seconds: 30));
      expect(getRetryTimeoutThreshold(Duration(seconds: 30), 1),
          Duration(seconds: 30));
      expect(getRetryTimeoutThreshold(Duration(seconds: 30), 2),
          Duration(seconds: 60));
      expect(getRetryTimeoutThreshold(Duration(seconds: 30), 3),
          Duration(seconds: 60));
    });
    test('timeoutThreshold is more than 60', () {
      expect(getRetryTimeoutThreshold(Duration(seconds: 90), 0),
          Duration(seconds: 90));
      expect(getRetryTimeoutThreshold(Duration(seconds: 90), 1),
          Duration(seconds: 90));
      expect(getRetryTimeoutThreshold(Duration(seconds: 90), 2),
          Duration(seconds: 90));
    });
  });
}
