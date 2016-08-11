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

import 'dart:convert';

import 'package:http_parser/http_parser.dart';
import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';

import '../../integration_paths.dart';

void runJsonRequestSuite() {
  group('JsonRequest', () {
    test('contentLength should be set automatically', () async {
      JsonRequest emptyRequest = new JsonRequest();
      Response response =
          await emptyRequest.post(uri: IntegrationPaths.reflectEndpointUri);
      int contentLength =
          int.parse(response.body.asJson()['headers']['content-length']);
      expect(contentLength, equals(0),
          reason: 'Empty JSON request\'s content-length should be 0.');

      JsonRequest nonEmptyRequest = new JsonRequest()
        ..uri = IntegrationPaths.reflectEndpointUri
        ..body = {'field1': 'value1', 'field2': 'value2'};
      response = await nonEmptyRequest.post();
      contentLength =
          int.parse(response.body.asJson()['headers']['content-length']);
      expect(contentLength, greaterThan(0),
          reason:
              'Non-empty JSON request\'s content-length should be greater than 0.');
    });

    test('content-type should be set automatically', () async {
      JsonRequest request = new JsonRequest()
        ..uri = IntegrationPaths.reflectEndpointUri
        ..body = {'field1': 'value1', 'field2': 'value2'};
      Response response = await request.post();
      MediaType contentType = new MediaType.parse(
          response.body.asJson()['headers']['content-type']);
      expect(contentType.mimeType, equals('application/json'));
    });

    test('content-type should be overridable', () async {
      var contentType = new MediaType('application', 'x-custom');
      JsonRequest request = new JsonRequest()
        ..uri = IntegrationPaths.reflectEndpointUri
        ..body = {'field1': 'value1', 'field2': 'value2'}
        ..contentType = contentType;
      Response response = await request.post();
      var reflectedContentType = new MediaType.parse(
          response.body.asJson()['headers']['content-type']);
      expect(reflectedContentType.mimeType, equals(contentType.mimeType));
    });

    test('UTF8', () async {
      JsonRequest request = new JsonRequest()
        ..uri = IntegrationPaths.echoEndpointUri
        ..encoding = UTF8
        ..body = {'field1': 'value1', 'field2': 'ç®å'};
      Response response = await request.post();
      expect(response.encoding.name, equals(UTF8.name));
      expect(response.body.asJson(), containsPair('field1', 'value1'));
      expect(response.body.asJson(), containsPair('field2', 'ç®å'));
    });

    test('LATIN1', () async {
      JsonRequest request = new JsonRequest()
        ..uri = IntegrationPaths.echoEndpointUri
        ..encoding = LATIN1
        ..body = {'field1': 'value1', 'field2': 'ç®å'};
      Response response = await request.post();
      expect(response.encoding.name, equals(LATIN1.name));
      expect(response.body.asJson(), containsPair('field1', 'value1'));
      expect(response.body.asJson(), containsPair('field2', 'ç®å'));
    });

    test('ASCII', () async {
      JsonRequest request = new JsonRequest()
        ..uri = IntegrationPaths.echoEndpointUri
        ..encoding = ASCII
        ..body = {'field1': 'value1', 'field2': 'value2'};
      Response response = await request.post();
      expect(response.encoding.name, equals(ASCII.name));
      expect(response.body.asJson(), containsPair('field1', 'value1'));
      expect(response.body.asJson(), containsPair('field2', 'value2'));
    });
  });
}
