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

library w_transport.test.integration.http.plain_text_request.suite;

import 'dart:convert';

import 'package:http_parser/http_parser.dart';
import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';

import '../integration_config.dart';

void runPlainTextRequestSuite(HttpIntegrationConfig config) {
  group('Request', () {
    test('contentLength should be set automatically', () async {
      Request emptyRequest = new Request();
      Response response =
          await emptyRequest.post(uri: config.reflectEndpointUri);
      var contentLength =
          int.parse(response.body.asJson()['headers']['content-length']);
      expect(contentLength, equals(0),
          reason: 'Empty plain-text request\'s content-length should be 0.');

      Request nonEmptyRequest = new Request()
        ..uri = config.reflectEndpointUri
        ..body = 'data';
      response = await nonEmptyRequest.post();
      contentLength =
          int.parse(response.body.asJson()['headers']['content-length']);
      expect(contentLength, greaterThan(0),
          reason:
              'Non-empty plain-text request\'s content-length should be greater than 0.');
    });

    test('content-type should be set automatically', () async {
      Request request = new Request()
        ..uri = config.reflectEndpointUri
        ..body = 'data';
      Response response = await request.post();
      MediaType contentType = new MediaType.parse(
          response.body.asJson()['headers']['content-type']);
      expect(contentType.mimeType, equals('text/plain'));
    });

    test('UTF8', () async {
      Request request = new Request()
        ..uri = config.echoEndpointUri
        ..encoding = UTF8
        ..body = 'dataç®å';
      Response response = await request.post();
      expect(response.encoding.name, equals(UTF8.name));
      expect(response.body.asString(), equals('dataç®å'));
    });

    test('LATIN1', () async {
      Request request = new Request()
        ..uri = config.echoEndpointUri
        ..encoding = LATIN1
        ..body = 'dataç®å';
      Response response = await request.post();
      expect(response.encoding.name, equals(LATIN1.name));
      expect(response.body.asString(), equals('dataç®å'));
    });

    test('ASCII', () async {
      Request request = new Request()
        ..uri = config.echoEndpointUri
        ..encoding = ASCII
        ..body = 'data';
      Response response = await request.post();
      expect(response.encoding.name, equals(ASCII.name));
      expect(response.body.asString(), equals('data'));
    });
  });
}
