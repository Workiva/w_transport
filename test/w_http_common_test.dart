/*
 * Copyright 2015 Workiva Inc.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

library w_transport.test.w_http_common_test;

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:w_transport/w_http.dart';

class MockWRequest extends Mock implements WRequest {}

void main() {
  group('WHttp', () {
    test('should throw if configuration has not been set', () {
      expect(() {
        WHttp.get(Uri.parse('/'));
      }, throwsStateError);
    });
  });

  group('WRequest', () {
    test('should throw if configuration has not been set', () {
      expect(() {
        new WRequest();
      }, throwsStateError);
    });
  });

  group('WHttpException', () {
    test('should include the original error if given', () {
      WRequest request = new MockWRequest();
      WHttpException exception =
          new WHttpException('GET', request, null, new Exception('original'));
      expect(exception.toString().contains('origina'), isTrue);
    });
  });
}
