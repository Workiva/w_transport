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
library w_transport.test.unit.http.w_http_exception_test;

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart' show WHttpException, WResponse;
import 'package:w_transport/w_transport_mock.dart';

void main() {
  group('WHttpException', () {
    test('should include the method and URi if given', () {
      WHttpException exception =
          new WHttpException('POST', Uri.parse('/path'), null, null);
      expect(exception.toString(), contains('POST'));
      expect(exception.toString(), contains('/path'));
    });

    test('should include the response status and text if given', () {
      WResponse response = new MockWResponse.ok();
      WHttpException exception =
          new WHttpException('GET', null, null, response);
      expect(exception.toString(), contains('200 OK'));
    });

    test('should include the original error if given', () {
      WHttpException exception = new WHttpException(
          'GET', null, null, null, new Exception('original'));
      expect(exception.toString(), contains('original'));
    });
  });
}
