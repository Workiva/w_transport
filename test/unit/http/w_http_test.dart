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
      await WHttp.delete(requestUri);
    });

    test('GET', () async {
      MockTransports.http.expect('GET', requestUri);
      await WHttp.get(requestUri);
    });

    test('HEAD', () async {
      MockTransports.http.expect('HEAD', requestUri);
      await WHttp.head(requestUri);
    });

    test('OPTIONS', () async {
      MockTransports.http.expect('OPTIONS', requestUri);
      await WHttp.options(requestUri);
    });

    test('PATCH', () async {
      MockTransports.http.expect('PATCH', requestUri);
      await WHttp.patch(requestUri);
    });

    test('POST', () async {
      MockTransports.http.expect('POST', requestUri);
      await WHttp.post(requestUri);
    });

    test('PUT', () async {
      MockTransports.http.expect('PUT', requestUri);
      await WHttp.put(requestUri);
    });

    test('TRACE', () async {
      MockTransports.http.expect('TRACE', requestUri);
      await WHttp.trace(requestUri);
    });

    test('newRequest() should create a new request', () async {
      WHttp http = new WHttp();
      expect(http.newRequest(), new isInstanceOf<WRequest>());
    });

    test('newRequest() should throw if closed', () async {
      WHttp http = new WHttp();
      http.close();
      expect(http.newRequest, throwsStateError);
    });

    group('with headers', () {
      test('DELETE', () async {
        MockTransports.http
            .expect('DELETE', requestUri, headers: {'content-type': 'json'});
        await WHttp.delete(requestUri, headers: {'content-type': 'json'});
      });

      test('GET', () async {
        MockTransports.http
            .expect('GET', requestUri, headers: {'content-type': 'json'});
        await WHttp.get(requestUri, headers: {'content-type': 'json'});
      });

      test('HEAD', () async {
        MockTransports.http
            .expect('HEAD', requestUri, headers: {'content-type': 'json'});
        await WHttp.head(requestUri, headers: {'content-type': 'json'});
      });

      test('OPTIONS', () async {
        MockTransports.http
            .expect('OPTIONS', requestUri, headers: {'content-type': 'json'});
        await WHttp.options(requestUri, headers: {'content-type': 'json'});
      });

      test('PATCH', () async {
        MockTransports.http
            .expect('PATCH', requestUri, headers: {'content-type': 'json'});
        await WHttp.patch(requestUri, headers: {'content-type': 'json'});
      });

      test('POST', () async {
        MockTransports.http
            .expect('POST', requestUri, headers: {'content-type': 'json'});
        await WHttp.post(requestUri, headers: {'content-type': 'json'});
      });

      test('PUT', () async {
        MockTransports.http
            .expect('PUT', requestUri, headers: {'content-type': 'json'});
        await WHttp.put(requestUri, headers: {'content-type': 'json'});
      });

      test('TRACE', () async {
        MockTransports.http
            .expect('TRACE', requestUri, headers: {'content-type': 'json'});
        await WHttp.trace(requestUri, headers: {'content-type': 'json'});
      });
    });
  });
}
