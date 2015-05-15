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

import 'dart:convert';
import 'dart:html';

import 'package:test/test.dart';
import 'package:w_transport/w_http.dart';
import 'package:w_transport/w_transport_client.dart'
    show configureWTransportForBrowser;

import './w_http_common_integration_tests.dart' as common_tests;
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
      expect(await response.asText(), equals(''));
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

    test('should have an upload progress stream', () async {
      bool uploadProgressListenedTo = false;
      request.path = '/test/http/reflect';
      FormData data = new FormData();
      data.append('file1', 'file1');
      data.append('file2', 'file2');
      data.append('file3', 'file3');
      request.data = data;
      request.uploadProgress.listen((WProgress progress) {
        if (progress.percent > 0) {
          uploadProgressListenedTo = true;
        }
      });
      WResponse response = await request.post();
      await response.asStream().drain();
      expect(uploadProgressListenedTo, isTrue);
    });

    test('should have a download progress stream', () async {
      bool downloadProgressListenedTo = false;
      request.path = '/test/http/download';
      request.downloadProgress.listen((WProgress progress) {
        if (progress.percent > 0) {
          downloadProgressListenedTo = true;
        }
      });
      WResponse response = await request.get();
      await response.asStream().drain();
      expect(downloadProgressListenedTo, isTrue);
    });

    test('should be able to configure the HttpRequest', () async {
      request.path = '/test/http/reflect';
      request.configure((HttpRequest xhr) async {
        xhr.setRequestHeader('x-configured', 'true');
      });
      WResponse response = await request.get();
      Map data = JSON.decode(await response.asText());
      expect(data['headers']['x-configured'], equals('true'));
    });
  });
}
