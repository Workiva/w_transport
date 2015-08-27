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

@TestOn('vm')
library w_transport.test.integration.http.w_http_server_integration_test;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_server.dart'
    show configureWTransportForServer;

import 'w_http_common_integration_tests.dart' as common_tests;
import '../../utils.dart';

void main() {
  configureWTransportForServer();

  // Almost all of the integration tests are identical regardless of client/server usage.
  // So, we run them from a common location.
  common_tests.run('Server');

  group('WHttp (Server) static methods', () {
    Uri uri;

    setUp(() {
      uri = Uri.parse('http://localhost:8024/test/http/reflect');
    });

    test('should be able to send a TRACE request', () async {
      WResponse response = await WHttp.trace(uri);
      expect(response.status, equals(200));
      Map data = JSON.decode(await response.asText());
      expect(data['method'], equals('TRACE'));
    });
  });

  group('WRequest (Server)', () {
    WRequest request;

    setUp(() {
      request = new WRequest()..uri = Uri.parse('http://localhost:8024');
    });

    // The following two tests are unique from a server consumer.

    // When sending an HTTP request within a server app, the response type
    // cannot be assumed to be a UTF8 string. As such, the HttpClientResponse
    // instance used internally returns an empty stream when the response body is empty,
    // which is the case with a HEAD request.
    test('should support a HEAD method', httpTest((store) async {
      // HEAD requests cannot return a body, but we can use that to
      // verify that this was actually a HEAD request
      request.path = '/test/http/reflect';
      WResponse response = store(await request.head());
      expect(response.status, equals(200));
      expect(await response.asStream().length, equals(0));
    }));

    // Unlike the browser environment, a server app has fewer security restrictions
    // and can successfully send a TRACE request.
    test('should support a TRACE method', httpTest((store) async {
      request.path = '/test/http/reflect';
      WResponse response = store(await request.trace());
      expect(response.status, equals(200));
      expect(JSON.decode(await response.asText())['method'], equals('TRACE'));
    }));

    test('should allow a String data payload', () {
      WRequest req = new WRequest();
      req.data = 'data';
      expect(req.data, equals('data'));
    });

    test('should allow a Stream data payload', () async {
      WRequest req = new WRequest();
      req.data = new Stream.fromIterable(['data']);
      expect(await (req.data as Stream).join(''), equals('data'));
    });

    test('should throw on invalid data payload', () async {
      WRequest req = new WRequest();
      req.data = 10;
      req.uri = Uri.parse('/');
      var error;
      try {
        await req.get();
      } catch (e) {
        error = e;
      }
      expect(error, isArgumentError);
    });

    test('should have an upload progress stream', () async {
      bool uploadProgressListenedTo = false;
      request.path = '/test/http/reflect';
      List chunks = [
        UTF8.encode('chunk1'),
        UTF8.encode('chunk2'),
        UTF8.encode('chunk3'),
      ];
      request.data = new Stream.fromIterable(chunks);
      request.contentLength = 0;
      chunks.forEach((List chunk) {
        request.contentLength += chunk.length;
      });
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

    test('should be able to configure the HttpClientRequest', () async {
      request.path = '/test/http/reflect';
      request.configure((HttpClientRequest req) async {
        req.headers.set('x-configured', 'true');
      });
      WResponse response = await request.get();
      Map data = JSON.decode(await response.asText());
      expect(data['headers']['x-configured'], equals('true'));
    });
  });
}
