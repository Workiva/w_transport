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
library w_transport.test.unit.http.request_exception_test;

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart' show RequestException, Response;
import 'package:w_transport/w_transport_mock.dart';

void main() {
  group('RequestException', () {
    test('should include the method and URi if given', () {
      RequestException exception =
          new RequestException('POST', Uri.parse('/path'), null, null);
      expect(exception.toString(), contains('POST'));
      expect(exception.toString(), contains('/path'));
    });

    test('should include the response status and text if given', () {
      Response response = new MockResponse.ok();
      RequestException exception =
          new RequestException('GET', null, null, response);
      expect(exception.toString(), contains('200 OK'));
    });

    test('should include the original error if given', () {
      RequestException exception = new RequestException(
          'GET', null, null, null, new Exception('original'));
      expect(exception.toString(), contains('original'));
    });
  });
}
