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
library w_transport.test.integration.http.server_test;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_vm.dart';

import 'common.dart';

void main() {
  configureWTransportForVM();

  HttpIntegrationConfig config =
      new HttpIntegrationConfig('Server', Uri.parse('http://localhost:8024'));
  group(config.title, () {
    runCommonHttpIntegrationTests(config);

    // When sending an HTTP request within a server app, the response type
    // cannot be assumed to be a UTF8 string. As such, the HttpClientResponse
    // instance used internally returns an empty stream when the response body is empty,
    // which is the case with a HEAD request.
    test('should support a HEAD method', () async {
      // HEAD requests cannot return a body, but we can use that to
      // verify that this was actually a HEAD request
      Response response = await Http.head(config.reflectEndpointUri);
      expect(response.status, equals(200));
//      expect(response.body.asBytes(), isEmpty);
    });

    // Unlike the browser environment, a server app has fewer security restrictions
    // and can successfully send a TRACE request.
    test('should support a TRACE method', () async {
      Response response = await Http.trace(config.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('TRACE'));
    });

    test('should support a String request body', () async {
      Request request = new Request()
        ..uri = config.reflectEndpointUri
        ..body = 'body';
      expect(request.body, equals('body'));
      await request.post();
    });

    test('should support a byte list request body', () async {
      Request request = new Request()
        ..uri = config.reflectEndpointUri
        ..bodyBytes = UTF8.encode('data');
      await request.post();
    });

//    test('should throw if data type is invalid', () async {
//      WRequest request = new WRequest()
//        ..uri = config.reflectEndpointUri
//        ..data = true;
//      expect(request.post(), throwsArgumentError);
//    });

    test('should have an upload progress stream', () async {
      bool uploadProgressListenedTo = false;
      StreamedRequest request = new StreamedRequest()
        ..uri = config.reflectEndpointUri;
      List chunks = [
        request.encoding.encode('chunk1'),
        request.encoding.encode('chunk2'),
        request.encoding.encode('chunk3'),
      ];
      request.body = new Stream.fromIterable(chunks);
      request.contentLength = 0;
      chunks.forEach((List chunk) {
        request.contentLength += chunk.length;
      });
      request.uploadProgress.listen((RequestProgress progress) {
        if (progress.percent > 0) {
          uploadProgressListenedTo = true;
        }
      });
      await request.post();
      expect(uploadProgressListenedTo, isTrue);
    });

    test('should have a download progress stream', () async {
      bool downloadProgressListenedTo = false;
      Request request = new Request()..uri = config.downloadEndpointUri;
      request.downloadProgress.listen((RequestProgress progress) {
        if (progress.percent > 0) {
          downloadProgressListenedTo = true;
        }
      });
      await request.get();
      expect(downloadProgressListenedTo, isTrue);
    });

    test('should be able to configure the HttpClientRequest', () async {
      Request request = new Request()..uri = config.reflectEndpointUri;
      request.configure((HttpClientRequest req) async {
        req.headers.set('x-configured', 'true');
      });
      Response response = await request.get();
      expect(response.body.asJson()['headers']['x-configured'], equals('true'));
    });
  });
}
