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
library w_transport.test.unit.http.w_request_test;

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_mock.dart';

void main() {
  configureWTransportForTest();

  group('WHttp', () {
    Uri requestUri = Uri.parse('https://mock.com/resource?limit=10');

    setUp(() {
      MockTransports.reset();
    });

    tearDown(() {
      MockTransports.verifyNoOutstandingExceptions();
    });

    test('DELETE', () async {
      MockTransports.http.expect('DELETE', requestUri);
      await Http.delete(requestUri);
    });

    test('GET', () async {
      MockTransports.http.expect('GET', requestUri);
      await Http.get(requestUri);
    });

    test('HEAD', () async {
      MockTransports.http.expect('HEAD', requestUri);
      await Http.head(requestUri);
    });

    test('OPTIONS', () async {
      MockTransports.http.expect('OPTIONS', requestUri);
      await Http.options(requestUri);
    });

    test('PATCH', () async {
      MockTransports.http.expect('PATCH', requestUri);
      await Http.patch(requestUri);
    });

    test('POST', () async {
      MockTransports.http.expect('POST', requestUri);
      await Http.post(requestUri);
    });

    test('PUT', () async {
      MockTransports.http.expect('PUT', requestUri);
      await Http.put(requestUri);
    });

    test('TRACE', () async {
      MockTransports.http.expect('TRACE', requestUri);
      await Http.trace(requestUri);
    });
  });
}
