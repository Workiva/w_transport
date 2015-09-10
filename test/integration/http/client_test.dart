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

import 'dart:convert';
import 'dart:html';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_client.dart';

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
      WResponse response = await WHttp.head(config.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(await response.asText(), equals(''));
    });

    test('should support a FormData payload', () async {
      WRequest request = new WRequest()..uri = config.reflectEndpointUri;
      FormData data = new FormData();
      Blob blob = new Blob(['blob']);
      data.appendBlob('blob', blob);
      data.append('text', 'text');
      request.data = data;
      await request.post();
    });

    test('should throw if data type is invalid', () async {
      WRequest request = new WRequest()
        ..uri = config.reflectEndpointUri
        ..data = true;
      expect(request.post(), throwsArgumentError);
    });

    test('should have an upload progress stream', () async {
      bool uploadProgressListenedTo = false;
      WRequest request = new WRequest()..uri = config.reflectEndpointUri;
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
      WRequest request = new WRequest()..uri = config.downloadEndpointUri;
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
      WRequest request = new WRequest()..uri = config.reflectEndpointUri;
      request.configure((HttpRequest xhr) async {
        xhr.setRequestHeader('x-configured', 'true');
      });
      WResponse response = await request.get();
      Map data = JSON.decode(await response.asText());
      expect(data['headers']['x-configured'], equals('true'));
    });

    group('should set the withCredentials flag', () {
      test('to true', () async {
        WRequest request = new WRequest()..uri = config.pingEndpointUri;
        request.withCredentials = true;
        request.configure((HttpRequest xhr) async {
          expect(xhr.withCredentials, isTrue);
        });
        var response = await request.get();
        await response.asText();
      });

      test('to false', () async {
        WRequest request = new WRequest()..uri = config.pingEndpointUri;
        request.withCredentials = false;
        request.configure((HttpRequest xhr) async {
          expect(xhr.withCredentials, isFalse);
        });
        var response = await request.get();
        await response.asText();
      });
    });
  });
}
