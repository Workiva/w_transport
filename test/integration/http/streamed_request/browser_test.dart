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
import 'dart:html';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/browser.dart';

import '../../../naming.dart';
import '../../integration_paths.dart';
import 'suite.dart';

void main() {
  Naming naming = new Naming()
    ..platform = platformBrowser
    ..testType = testTypeIntegration
    ..topic = topicHttp;

  group(naming.toString(), () {
    setUp(() {
      configureWTransportForBrowser();
    });

    runStreamedRequestSuite();

    test('underlying HttpRequest configuration', () async {
      StreamedRequest request = new StreamedRequest()
        ..uri = IntegrationPaths.reflectEndpointUri;
      request.configure((request) async {
        HttpRequest xhr = request;
        xhr.setRequestHeader('x-configured', 'true');
      });
      Response response = await request.get();
      expect(response.body.asJson()['headers']['x-configured'], equals('true'));
    });

    group('withCredentials', () {
      test('set to true (StreamedRequest)', () async {
        StreamedRequest request = new StreamedRequest()
          ..uri = IntegrationPaths.pingEndpointUri
          ..withCredentials = true;
        request.configure((request) async {
          HttpRequest xhr = request;
          expect(xhr.withCredentials, isTrue);
        });
        await request.get();
      });

      test('set to false (StreamedRequest)', () async {
        StreamedRequest request = new StreamedRequest()
          ..uri = IntegrationPaths.pingEndpointUri
          ..withCredentials = false;
        request.configure((request) async {
          HttpRequest xhr = request;
          expect(xhr.withCredentials, isFalse);
        });
        await request.get();
      });
    });
  });
}
