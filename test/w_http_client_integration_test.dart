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

@TestOn('browser || content-shell')
library w_transport.test.w_http_client_integration_test;

import 'dart:html';

import 'package:test/test.dart';
import 'package:w_transport/w_http.dart';
import 'package:w_transport/w_transport_client.dart'
    show configureWTransportForBrowser;

import './w_http_common_tests.dart' as common_tests;
import './w_http_utils.dart';

void main() {
  configureWTransportForBrowser();

  // Almost all of the integration tests are identical regardless of client/server usage.
  // So, we run them from a common location.
  common_tests.run('Client');

  group('WRequest (Client)', () {
    WRequest request;

    setUp(() {
      request = new WRequest()..uri = Uri.parse('http://localhost:8024');
    });

    // The following two tests are unique from a client consumer.

    // When sending an HTTP request within a client app, the response will always
    // be a string. As such, the HttpRequest response data will be an empty string
    // if the response body is empty, as is the case with a HEAD request.
    test('should support a HEAD method', httpTest((store) async {
      // HEAD requests cannot return a body, but we can use that to
      // verify that this was actually a HEAD request
      request.path = '/test/http/reflect';
      WResponse response = store(await request.head());
      expect(response.status, equals(200));
      expect(await response.text, equals(''));
    }));

    test('should support a FormData payload', httpTest((store) async {
      request.path = '/test/http/reflect';
      FormData data = new FormData();
      Blob blob = new Blob(['blob']);
      data.appendBlob('blob', blob);
      data.append('text', 'text');
      request.data = data;
      store(await request.post());
    }));
  });
}
