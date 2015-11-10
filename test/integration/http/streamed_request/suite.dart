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

library w_transport.test.integration.http.streamed_request.suite;

import 'dart:async';
import 'dart:convert';

import 'package:http_parser/http_parser.dart';
import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';

import '../../integration_paths.dart';

void runStreamedRequestSuite() {
  group('StreamedRequest', () {
    test('contentLength should NOT be set automatically', () async {
      StreamedRequest emptyRequest = new StreamedRequest()
        ..uri = IntegrationPaths.reflectEndpointUri
        ..contentLength = 0;
      Response response =
          await emptyRequest.post(uri: IntegrationPaths.reflectEndpointUri);
      var contentLength =
          int.parse(response.body.asJson()['headers']['content-length']);
      expect(contentLength, equals(0),
          reason:
              'Empty streamed plain-text request\'s content-length should be 0.');

      List<List<int>> chunks = [
        UTF8.encode('chunk1'),
        UTF8.encode('chunk2'),
        UTF8.encode('chunk3')
      ];
      int size = 0;
      chunks.forEach((chunk) {
        size += chunk.length;
      });
      StreamedRequest nonEmptyRequest = new StreamedRequest()
        ..uri = IntegrationPaths.reflectEndpointUri
        ..body = new Stream.fromIterable(chunks)
        ..contentLength = size;
      response = await nonEmptyRequest.post();
      contentLength =
          int.parse(response.body.asJson()['headers']['content-length']);
      expect(contentLength, equals(size),
          reason:
              'Non-empty streamed plain-text request\'s content-length should be greater than 0.');
    });

    test('content-type should be set automatically', () async {
      StreamedRequest request = new StreamedRequest()
        ..uri = IntegrationPaths.reflectEndpointUri
        ..body = new Stream.fromIterable([])
        ..contentLength = 0;
      Response response = await request.post();
      MediaType contentType = new MediaType.parse(
          response.body.asJson()['headers']['content-type']);
      expect(contentType.mimeType, equals('text/plain'));
    });

    test('UTF8', () async {
      StreamedRequest request = new StreamedRequest()
        ..uri = IntegrationPaths.echoEndpointUri
        ..encoding = UTF8
        ..body = new Stream.fromIterable([UTF8.encode('dataç®å')]);
      Response response = await request.post();
      expect(response.encoding.name, equals(UTF8.name));
      expect(response.body.asString(), equals('dataç®å'));
    });

    test('LATIN1', () async {
      StreamedRequest request = new StreamedRequest()
        ..uri = IntegrationPaths.echoEndpointUri
        ..encoding = LATIN1
        ..body = new Stream.fromIterable([LATIN1.encode('dataç®å')]);
      Response response = await request.post();
      expect(response.encoding.name, equals(LATIN1.name));
      expect(response.body.asString(), equals('dataç®å'));
    });

    test('ASCII', () async {
      StreamedRequest request = new StreamedRequest()
        ..uri = IntegrationPaths.echoEndpointUri
        ..encoding = ASCII
        ..body = new Stream.fromIterable([ASCII.encode('data')]);
      Response response = await request.post();
      expect(response.encoding.name, equals(ASCII.name));
      expect(response.body.asString(), equals('data'));
    });
  });
}
