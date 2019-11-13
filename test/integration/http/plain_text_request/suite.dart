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
import 'package:w_transport/w_transport.dart' as transport;

import '../../integration_paths.dart';

void runPlainTextRequestSuite([transport.TransportPlatform transportPlatform]) {
  group('Request', () {
    test('contentLength should be set automatically', () async {
      final emptyRequest =
          transport.Request(transportPlatform: transportPlatform);
      final response =
          await emptyRequest.post(uri: IntegrationPaths.reflectEndpointUri);
      final contentLength =
          int.parse(response.body.asJson()['headers']['content-length']);
      expect(contentLength, equals(0),
          reason: 'Empty plain-text request\'s content-length should be 0.');

      final nonEmptyRequest =
          transport.Request(transportPlatform: transportPlatform)
            ..uri = IntegrationPaths.reflectEndpointUri
            ..body = 'data';
      final response2 = await nonEmptyRequest.post();
      final contentLength2 =
          int.parse(response2.body.asJson()['headers']['content-length']);
      expect(contentLength2, greaterThan(0),
          reason:
              'Non-empty plain-text request\'s content-length should be greater than 0.');
    });

    test('content-type should be set automatically', () async {
      final request = transport.Request(transportPlatform: transportPlatform)
        ..uri = IntegrationPaths.reflectEndpointUri
        ..body = 'data';
      final response = await request.post();
      final contentType =
          MediaType.parse(response.body.asJson()['headers']['content-type']);
      expect(contentType.mimeType, equals('text/plain'));
    });

    test('content-type should be overridable', () async {
      final contentType = MediaType('application', 'x-custom');
      final request = transport.Request(transportPlatform: transportPlatform)
        ..uri = IntegrationPaths.reflectEndpointUri
        ..body = 'data'
        ..contentType = contentType;
      final response = await request.post();
      final reflectedContentType =
          MediaType.parse(response.body.asJson()['headers']['content-type']);
      expect(reflectedContentType.mimeType, equals(contentType.mimeType));
    });

    test('UTF8', () async {
      final request = transport.Request(transportPlatform: transportPlatform)
        ..uri = IntegrationPaths.echoEndpointUri
        ..encoding = utf8
        ..body = 'dataç®å';
      final response = await request.post();
      expect(response.encoding.name, equals(utf8.name));
      expect(response.body.asString(), equals('dataç®å'));
    });

    test('LATIN1', () async {
      final request = transport.Request(transportPlatform: transportPlatform)
        ..uri = IntegrationPaths.echoEndpointUri
        ..encoding = latin1
        ..body = 'dataç®å';
      final response = await request.post();
      expect(response.encoding.name, equals(latin1.name));
      expect(response.body.asString(), equals('dataç®å'));
    });

    test('ASCII', () async {
      final request = transport.Request(transportPlatform: transportPlatform)
        ..uri = IntegrationPaths.echoEndpointUri
        ..encoding = ascii
        ..body = 'data';
      final response = await request.post();
      expect(response.encoding.name, equals(ascii.name));
      expect(response.body.asString(), equals('data'));
    });
  });
}
