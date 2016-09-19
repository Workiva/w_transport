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
import 'dart:convert';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/browser.dart';

import '../../../naming.dart';
import '../../integration_paths.dart';
import 'suite.dart';

void main() {
  final naming = new Naming()
    ..platform = platformBrowser
    ..testType = testTypeIntegration
    ..topic = topicHttp;

  group(naming.toString(), () {
    setUp(() {
      configureWTransportForBrowser();
    });

    runMultipartRequestSuite();

    group('MultipartRequest', () {
      test('underlying HttpRequest configuration', () async {
        final request = new MultipartRequest()
          ..uri = IntegrationPaths.reflectEndpointUri
          ..fields['field'] = 'value';
        request.configure((request) async {
          HttpRequest xhr = request;
          xhr.setRequestHeader('x-configured', 'true');
        });
        final response = await request.get();
        expect(
            response.body.asJson()['headers']['x-configured'], equals('true'));
      });

      group('withCredentials', () {
        test('set to true (MultipartRequest)', () async {
          final request = new MultipartRequest()
            ..uri = IntegrationPaths.pingEndpointUri
            ..fields['field'] = 'value'
            ..withCredentials = true;
          request.configure((request) async {
            HttpRequest xhr = request;
            expect(xhr.withCredentials, isTrue);
          });
          await request.get();
        });

        test('set to false (MultipartRequest)', () async {
          final request = new MultipartRequest()
            ..uri = IntegrationPaths.pingEndpointUri
            ..fields['field'] = 'value'
            ..withCredentials = false;
          request.configure((request) async {
            HttpRequest xhr = request;
            expect(xhr.withCredentials, isFalse);
          });
          await request.get();
        });
      });

      test('setting content-length is unsupported', () {
        final request = new MultipartRequest();
        expect(() {
          request.contentLength = 10;
        }, throwsUnsupportedError);
      });

      test('setting body in request dispatcher is unsupported', () async {
        final request = new MultipartRequest()
          ..uri = IntegrationPaths.reflectEndpointUri;
        expect(request.post(body: 'invalid'), throwsUnsupportedError);
      });

      test('should support Blob file', () async {
        final blob = new Blob([UTF8.encode('file')]);
        final request = new MultipartRequest()
          ..uri = IntegrationPaths.reflectEndpointUri
          ..files['blob'] = blob;
        await request.post();
      });

      test('should support File', () async {
        // TODO: Write a functional test for this - not sure how to mock File/Blob class (or that it's possible)
      });

      test('clone()', () {
        final orig = new MultipartRequest()..fields = {'field1': 'value1'};
        final clone = orig.clone();
        expect(clone.fields, equals(orig.fields));
      });
    });
  });
}
