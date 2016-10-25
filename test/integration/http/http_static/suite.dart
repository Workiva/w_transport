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

import 'dart:async';
import 'dart:convert';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart' as transport;

import '../../integration_paths.dart';

void runHttpStaticSuite([transport.TransportPlatform transportPlatform]) {
  group('Http static methods', () {
    final headers = <String, String>{
      'authorization': 'test',
      'x-custom': 'value',
      'x-tokens': 'token1, token2'
    };

    test('DELETE request', () async {
      final response = await transport.Http.delete(
          IntegrationPaths.reflectEndpointUri,
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('DELETE'));
    });

    test('DELETE request with headers', () async {
      final response = await transport.Http.delete(
          IntegrationPaths.reflectEndpointUri,
          headers: new Map<String, String>.from(headers),
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));

      final json = response.body.asJson();
      expect(json['method'], equals('DELETE'));
      expect(json['headers'],
          containsPair('authorization', headers['authorization']));
      expect(json['headers'], containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('GET request', () async {
      final response = await transport.Http.get(
          IntegrationPaths.reflectEndpointUri,
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('GET'));
    });

    test('GET request with headers', () async {
      final response = await transport.Http.get(
          IntegrationPaths.reflectEndpointUri,
          headers: new Map<String, String>.from(headers),
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));

      final json = response.body.asJson();
      expect(json['method'], equals('GET'));
      expect(json['headers'],
          containsPair('authorization', headers['authorization']));
      expect(json['headers'], containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('HEAD request', () async {
      final response = await transport.Http.head(
          IntegrationPaths.reflectEndpointUri,
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));
    });

    test('HEAD request with headers', () async {
      final response = await transport.Http.head(
          IntegrationPaths.reflectEndpointUri,
          headers: new Map<String, String>.from(headers),
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));
    });

    test('OPTIONS request', () async {
      final response = await transport.Http.options(
          IntegrationPaths.reflectEndpointUri,
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('OPTIONS'));
    });

    test('OPTIONS request with headers', () async {
      final response = await transport.Http.options(
          IntegrationPaths.reflectEndpointUri,
          headers: new Map<String, String>.from(headers),
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));

      final json = response.body.asJson();
      expect(json['method'], equals('OPTIONS'));
      expect(json['headers'],
          containsPair('authorization', headers['authorization']));
      expect(json['headers'], containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('PATCH request', () async {
      final response = await transport.Http.patch(
          IntegrationPaths.reflectEndpointUri,
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('PATCH'));
    });

    test('PATCH request with headers', () async {
      final response = await transport.Http.patch(
          IntegrationPaths.reflectEndpointUri,
          headers: new Map<String, String>.from(headers),
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));

      final json = response.body.asJson();
      expect(json['method'], equals('PATCH'));
      expect(json['headers'],
          containsPair('authorization', headers['authorization']));
      expect(json['headers'], containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('PATCH request with body', () async {
      final response = await transport.Http.patch(
          IntegrationPaths.echoEndpointUri,
          body: 'body',
          transportPlatform: transportPlatform);
      expect(response.body.asString(), equals('body'));
    });

    test('POST request', () async {
      final response = await transport.Http.post(
          IntegrationPaths.reflectEndpointUri,
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('POST'));
    });

    test('POST request with headers', () async {
      final response = await transport.Http.post(
          IntegrationPaths.reflectEndpointUri,
          headers: new Map<String, String>.from(headers),
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));

      final json = response.body.asJson();
      expect(json['method'], equals('POST'));
      expect(json['headers'],
          containsPair('authorization', headers['authorization']));
      expect(json['headers'], containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('POST request with body', () async {
      final response = await transport.Http.post(
          IntegrationPaths.echoEndpointUri,
          body: 'body',
          transportPlatform: transportPlatform);
      expect(response.body.asString(), equals('body'));
    });

    test('PUT request', () async {
      final response = await transport.Http.put(
          IntegrationPaths.reflectEndpointUri,
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('PUT'));
    });

    test('PUT request with headers', () async {
      final response = await transport.Http.put(
          IntegrationPaths.reflectEndpointUri,
          headers: new Map<String, String>.from(headers),
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));

      final json = response.body.asJson();
      expect(json['method'], equals('PUT'));
      expect(json['headers'],
          containsPair('authorization', headers['authorization']));
      expect(json['headers'], containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('PUT request with body', () async {
      final response = await transport.Http.put(
          IntegrationPaths.echoEndpointUri,
          body: 'body',
          transportPlatform: transportPlatform);
      expect(response.body.asString(), equals('body'));
    });

    test('custom HTTP method request', () async {
      final response = await transport.Http.send(
          'COPY', IntegrationPaths.reflectEndpointUri,
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('COPY'));
    });

    test('custom HTTP method request with headers', () async {
      final response = await transport.Http.send(
          'COPY', IntegrationPaths.reflectEndpointUri,
          headers: new Map<String, String>.from(headers),
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));

      final json = response.body.asJson();
      expect(json['method'], equals('COPY'));
      expect(json['headers'],
          containsPair('authorization', headers['authorization']));
      expect(json['headers'], containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('custom HTTP method request with body', () async {
      final response = await transport.Http.send(
          'COPY', IntegrationPaths.echoEndpointUri,
          body: 'body', transportPlatform: transportPlatform);
      expect(response.body.asString(), equals('body'));
    });

    Future<String> _decodeStreamedResponseToString(
        transport.StreamedResponse response) async {
      final bytes = await response.body.toBytes();
      return response.encoding.decode(bytes.toList());
    }

    Future<Map> _decodeStreamedResponseToJson(
        transport.StreamedResponse response) async {
      return JSON.decode(await _decodeStreamedResponseToString(response));
    }

    test('streamed DELETE request', () async {
      final response = await transport.Http.streamDelete(
          IntegrationPaths.reflectEndpointUri,
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));
      final json = await _decodeStreamedResponseToJson(response);
      expect(json['method'], equals('DELETE'));
    });

    test('streamed DELETE request with headers', () async {
      final response = await transport.Http.streamDelete(
          IntegrationPaths.reflectEndpointUri,
          headers: new Map<String, String>.from(headers),
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));

      final json = await _decodeStreamedResponseToJson(response);
      expect(json['method'], equals('DELETE'));
      expect(json['headers'],
          containsPair('authorization', headers['authorization']));
      expect(json['headers'], containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('streamed GET request', () async {
      final response = await transport.Http.streamGet(
          IntegrationPaths.reflectEndpointUri,
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));
      final json = await _decodeStreamedResponseToJson(response);
      expect(json['method'], equals('GET'));
    });

    test('streamed GET request with headers', () async {
      final response = await transport.Http.streamGet(
          IntegrationPaths.reflectEndpointUri,
          headers: new Map<String, String>.from(headers),
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));

      final json = await _decodeStreamedResponseToJson(response);
      expect(json['method'], equals('GET'));
      expect(json['headers'],
          containsPair('authorization', headers['authorization']));
      expect(json['headers'], containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('streamed HEAD request', () async {
      final response = await transport.Http.streamHead(
          IntegrationPaths.reflectEndpointUri,
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));
    });

    test('streamed HEAD request with headers', () async {
      final response = await transport.Http.streamHead(
          IntegrationPaths.reflectEndpointUri,
          headers: new Map<String, String>.from(headers),
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));
    });

    test('streamed OPTIONS request', () async {
      final response = await transport.Http.streamOptions(
          IntegrationPaths.reflectEndpointUri,
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));
      final json = await _decodeStreamedResponseToJson(response);
      expect(json['method'], equals('OPTIONS'));
    });

    test('streamed OPTIONS request with headers', () async {
      final response = await transport.Http.streamOptions(
          IntegrationPaths.reflectEndpointUri,
          headers: new Map<String, String>.from(headers),
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));

      final json = await _decodeStreamedResponseToJson(response);
      expect(json['method'], equals('OPTIONS'));
      expect(json['headers'],
          containsPair('authorization', headers['authorization']));
      expect(json['headers'], containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('streamed PATCH request', () async {
      final response = await transport.Http.streamPatch(
          IntegrationPaths.reflectEndpointUri,
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));
      final json = await _decodeStreamedResponseToJson(response);
      expect(json['method'], equals('PATCH'));
    });

    test('streamed PATCH request with headers', () async {
      final response = await transport.Http.streamPatch(
          IntegrationPaths.reflectEndpointUri,
          headers: new Map<String, String>.from(headers),
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));

      final json = await _decodeStreamedResponseToJson(response);
      expect(json['method'], equals('PATCH'));
      expect(json['headers'],
          containsPair('authorization', headers['authorization']));
      expect(json['headers'], containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('streamed PATCH request with body', () async {
      final response = await transport.Http.streamPatch(
          IntegrationPaths.echoEndpointUri,
          body: 'body',
          transportPlatform: transportPlatform);
      final body = await _decodeStreamedResponseToString(response);
      expect(body, equals('body'));
    });

    test('streamed POST request', () async {
      final response = await transport.Http.streamPost(
          IntegrationPaths.reflectEndpointUri,
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));
      final json = await _decodeStreamedResponseToJson(response);
      expect(json['method'], equals('POST'));
    });

    test('streamed POST request with headers', () async {
      final response = await transport.Http.streamPost(
          IntegrationPaths.reflectEndpointUri,
          headers: new Map<String, String>.from(headers),
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));

      final json = await _decodeStreamedResponseToJson(response);
      expect(json['method'], equals('POST'));
      expect(json['headers'],
          containsPair('authorization', headers['authorization']));
      expect(json['headers'], containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('streamed POST request with body', () async {
      final response = await transport.Http.streamPost(
          IntegrationPaths.echoEndpointUri,
          body: 'body',
          transportPlatform: transportPlatform);
      final body = await _decodeStreamedResponseToString(response);
      expect(body, equals('body'));
    });

    test('streamed PUT request', () async {
      final response = await transport.Http.streamPut(
          IntegrationPaths.reflectEndpointUri,
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));
      final json = await _decodeStreamedResponseToJson(response);
      expect(json['method'], equals('PUT'));
    });

    test('streamed PUT request with headers', () async {
      final response = await transport.Http.streamPut(
          IntegrationPaths.reflectEndpointUri,
          headers: new Map<String, String>.from(headers),
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));

      final json = await _decodeStreamedResponseToJson(response);
      expect(json['method'], equals('PUT'));
      expect(json['headers'],
          containsPair('authorization', headers['authorization']));
      expect(json['headers'], containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('streamed PUT request with body', () async {
      final response = await transport.Http.streamPut(
          IntegrationPaths.echoEndpointUri,
          body: 'body',
          transportPlatform: transportPlatform);
      final body = await _decodeStreamedResponseToString(response);
      expect(body, equals('body'));
    });

    test('streamed custom HTTP method request', () async {
      final response = await transport.Http.streamSend(
          'COPY', IntegrationPaths.reflectEndpointUri,
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));
      final json = await _decodeStreamedResponseToJson(response);
      expect(json['method'], equals('COPY'));
    });

    test('streamed custom HTTP method request with headers', () async {
      final response = await transport.Http.streamSend(
          'COPY', IntegrationPaths.reflectEndpointUri,
          headers: new Map<String, String>.from(headers),
          transportPlatform: transportPlatform);
      expect(response.status, equals(200));

      final json = await _decodeStreamedResponseToJson(response);
      expect(json['method'], equals('COPY'));
      expect(json['headers'],
          containsPair('authorization', headers['authorization']));
      expect(json['headers'], containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('streamed custom HTTP method request with body', () async {
      final response = await transport.Http.streamSend(
          'COPY', IntegrationPaths.echoEndpointUri,
          body: 'body', transportPlatform: transportPlatform);
      final body = await _decodeStreamedResponseToString(response);
      expect(body, equals('body'));
    });
  });
}
