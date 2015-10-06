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
library w_transport.test.integration.http.form_request.browser_test;

import 'dart:html';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_browser.dart';

import '../../../naming.dart';
import '../integration_config.dart';
import 'suite.dart';

void main() {
  var config = new HttpIntegrationConfig.browser();
  group(integrationHttpBrowser, () {
    setUp(() {
      configureWTransportForBrowser();
    });

    runFormRequestSuite(config);

    test('underlying HttpRequest configuration', () async {
      FormRequest request = new FormRequest()..uri = config.reflectEndpointUri;
      request.configure((HttpRequest xhr) async {
        xhr.setRequestHeader('x-configured', 'true');
      });
      Response response = await request.get();
      expect(response.body.asJson()['headers']['x-configured'], equals('true'));
    });

    group('withCredentials', () {
      test('set to true', () async {
        FormRequest request = new FormRequest()
          ..uri = config.pingEndpointUri
          ..withCredentials = true;
        request.configure((HttpRequest xhr) async {
          expect(xhr.withCredentials, isTrue);
        });
        await request.get();
      });

      test('set to false', () async {
        FormRequest request = new FormRequest()
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
