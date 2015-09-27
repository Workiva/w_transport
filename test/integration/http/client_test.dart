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

@TestOn('browser')
library w_transport.test.integration.http.client_test;

import 'dart:html';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_browser.dart';

import 'common.dart';

void main() {
  configureWTransportForBrowser();

  HttpIntegrationConfig config =
      new HttpIntegrationConfig('Client', Uri.parse('http://localhost:8024'));
  group(config.title, () {
    runCommonHttpIntegrationTests(config);

    // When sending an HTTP request within a client app, the response will always
    // be a string. As such, the HttpRequest response data will be an empty string
    // if the response body is empty, as is the case with a HEAD request.
    test('should support HEAD request', () async {
      // HEAD requests cannot return a body, but we can use that to
      // verify that this was actually a HEAD request
      Response response = await Http.head(config.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asString(), equals(''));
    });

    test('should support a FormData payload', () async {
      MultipartRequest request = new MultipartRequest()
        ..uri = config.reflectEndpointUri
        ..fields['text'] = 'text'
        ..files['blob'] = new Blob(['blob']);
      await request.post();
    });

//    test('should throw if data type is invalid', () async {
//      Request request = new Request()
//        ..uri = config.reflectEndpointUri
//        ..body = true;
//      expect(request.post(), throwsArgumentError);
//    });

    test('should have an upload progress stream', () async {
      bool uploadProgressListenedTo = false;
      MultipartRequest request = new MultipartRequest()
        ..uri = config.reflectEndpointUri
        ..fields['file1'] = 'file1'
        ..fields['file2'] = 'file2'
        ..fields['file3'] = 'file3';
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
      Request request = new Request()
        ..uri = config.downloadEndpointUri
        ..path = '/test/http/download';
      request.downloadProgress.listen((RequestProgress progress) {
        if (progress.percent > 0) {
          downloadProgressListenedTo = true;
        }
      });
      await request.get();
      expect(downloadProgressListenedTo, isTrue);
    });

    test('should be able to configure the HttpRequest', () async {
      Request request = new Request()..uri = config.reflectEndpointUri;
      request.configure((HttpRequest xhr) async {
        xhr.setRequestHeader('x-configured', 'true');
      });
      Response response = await request.get();
      expect(response.body.asJson()['headers']['x-configured'], equals('true'));
    });

    group('should set the withCredentials flag', () {
      test('to true', () async {
        Request request = new Request()
          ..uri = config.pingEndpointUri
          ..withCredentials = true;
        request.configure((HttpRequest xhr) async {
          expect(xhr.withCredentials, isTrue);
        });
        await request.get();
      });

      test('to false', () async {
        Request request = new Request()
          ..uri = config.pingEndpointUri
          ..withCredentials = false;
        request.configure((HttpRequest xhr) async {
          expect(xhr.withCredentials, isFalse);
        });
        await request.get();
      });
    });
  });
}
