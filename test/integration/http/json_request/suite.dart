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
      final emptyRequest = new JsonRequest();
      final response =
          await emptyRequest.post(uri: IntegrationPaths.reflectEndpointUri);
      final contentLength =
          int.parse(response.body.asJson()['headers']['content-length']);
      expect(contentLength, equals(0),
          reason: 'Empty JSON request\'s content-length should be 0.');

      final nonEmptyRequest = new JsonRequest()
        ..uri = IntegrationPaths.reflectEndpointUri
        ..body = {'field1': 'value1', 'field2': 'value2'};
      final response2 = await nonEmptyRequest.post();
      final contentLength2 =
          int.parse(response2.body.asJson()['headers']['content-length']);
      expect(contentLength2, greaterThan(0),
          reason:
              'Non-empty JSON request\'s content-length should be greater than 0.');
    });

    test('content-type should be set automatically', () async {
      final request = new JsonRequest()
        ..uri = IntegrationPaths.reflectEndpointUri
        ..body = {'field1': 'value1', 'field2': 'value2'};
      final response = await request.post();
      final contentType = new MediaType.parse(
          response.body.asJson()['headers']['content-type']);
      expect(contentType.mimeType, equals('application/json'));
    });

    test('content-type should be overridable', () async {
      final contentType = new MediaType('application', 'x-custom');
      final request = new JsonRequest()
        ..uri = IntegrationPaths.reflectEndpointUri
        ..body = {'field1': 'value1', 'field2': 'value2'}
        ..contentType = contentType;
      final response = await request.post();
      final reflectedContentType = new MediaType.parse(
          response.body.asJson()['headers']['content-type']);
      expect(reflectedContentType.mimeType, equals(contentType.mimeType));
    });

    test('UTF8', () async {
      final request = new JsonRequest()
        ..uri = IntegrationPaths.echoEndpointUri
        ..encoding = UTF8
        ..body = {'field1': 'value1', 'field2': 'ç®å'};
      final response = await request.post();
      expect(response.encoding.name, equals(UTF8.name));
      expect(response.body.asJson(), containsPair('field1', 'value1'));
      expect(response.body.asJson(), containsPair('field2', 'ç®å'));
    });

    test('LATIN1', () async {
      final request = new JsonRequest()
        ..uri = IntegrationPaths.echoEndpointUri
        ..encoding = LATIN1
        ..body = {'field1': 'value1', 'field2': 'ç®å'};
      final response = await request.post();
      expect(response.encoding.name, equals(LATIN1.name));
      expect(response.body.asJson(), containsPair('field1', 'value1'));
      expect(response.body.asJson(), containsPair('field2', 'ç®å'));
    });

    test('ASCII', () async {
      final request = new JsonRequest()
        ..uri = IntegrationPaths.echoEndpointUri
        ..encoding = ASCII
        ..body = {'field1': 'value1', 'field2': 'value2'};
      final response = await request.post();
      expect(response.encoding.name, equals(ASCII.name));
      expect(response.body.asJson(), containsPair('field1', 'value1'));
      expect(response.body.asJson(), containsPair('field2', 'value2'));
    });
  });
}
