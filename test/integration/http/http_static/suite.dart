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

library w_transport.test.integration.http.http_static.suite;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';

import '../../integration_paths.dart';

void runHttpStaticSuite() {
  group('Http static methods', () {
    var headers = {
      'authorization': 'test',
      'x-custom': 'value',
      'x-tokens': 'token1, token2'
    };

    test('DELETE request', () async {
      Response response =
          await Http.delete(IntegrationPaths.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('DELETE'));
    });

    test('DELETE request with headers', () async {
      Response response = await Http.delete(IntegrationPaths.reflectEndpointUri,
          headers: new Map.from(headers));
      expect(response.status, equals(200));

      var json = response.body.asJson();
      expect(json['method'], equals('DELETE'));
      expect(json['headers'],
          containsPair('authorization', headers['authorization']));
      expect(json['headers'], containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('GET request', () async {
      Response response = await Http.get(IntegrationPaths.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('GET'));
    });

    test('GET request with headers', () async {
      Response response = await Http.get(IntegrationPaths.reflectEndpointUri,
          headers: new Map.from(headers));
      expect(response.status, equals(200));

      var json = response.body.asJson();
      expect(json['method'], equals('GET'));
      expect(json['headers'],
          containsPair('authorization', headers['authorization']));
      expect(json['headers'], containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('HEAD request', () async {
      Response response = await Http.head(IntegrationPaths.reflectEndpointUri);
      expect(response.status, equals(200));
    });

    test('HEAD request with headers', () async {
      Response response = await Http.head(IntegrationPaths.reflectEndpointUri,
          headers: new Map.from(headers));
      expect(response.status, equals(200));
    });

    test('OPTIONS request', () async {
      Response response =
          await Http.options(IntegrationPaths.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('OPTIONS'));
    });

    test('OPTIONS request with headers', () async {
      Response response = await Http.options(
          IntegrationPaths.reflectEndpointUri,
          headers: new Map.from(headers));
      expect(response.status, equals(200));

      var json = response.body.asJson();
      expect(json['method'], equals('OPTIONS'));
      expect(json['headers'],
          containsPair('authorization', headers['authorization']));
      expect(json['headers'], containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('PATCH request', () async {
      Response response = await Http.patch(IntegrationPaths.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('PATCH'));
    });

    test('PATCH request with headers', () async {
      Response response = await Http.patch(IntegrationPaths.reflectEndpointUri,
          headers: new Map.from(headers));
      expect(response.status, equals(200));

      var json = response.body.asJson();
      expect(json['method'], equals('PATCH'));
      expect(json['headers'],
          containsPair('authorization', headers['authorization']));
      expect(json['headers'], containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('PATCH request with body', () async {
      Response response =
          await Http.patch(IntegrationPaths.echoEndpointUri, body: 'body');
      expect(response.body.asString(), equals('body'));
    });

    test('POST request', () async {
      Response response = await Http.post(IntegrationPaths.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('POST'));
    });

    test('POST request with headers', () async {
      Response response = await Http.post(IntegrationPaths.reflectEndpointUri,
          headers: new Map.from(headers));
      expect(response.status, equals(200));

      var json = response.body.asJson();
      expect(json['method'], equals('POST'));
      expect(json['headers'],
          containsPair('authorization', headers['authorization']));
      expect(json['headers'], containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('POST request with body', () async {
      Response response =
          await Http.post(IntegrationPaths.echoEndpointUri, body: 'body');
      expect(response.body.asString(), equals('body'));
    });

    test('PUT request', () async {
      Response response = await Http.put(IntegrationPaths.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('PUT'));
    });

    test('PUT request with headers', () async {
      Response response = await Http.put(IntegrationPaths.reflectEndpointUri,
          headers: new Map.from(headers));
      expect(response.status, equals(200));

      var json = response.body.asJson();
      expect(json['method'], equals('PUT'));
      expect(json['headers'],
          containsPair('authorization', headers['authorization']));
      expect(json['headers'], containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('PUT request with body', () async {
      Response response =
          await Http.put(IntegrationPaths.echoEndpointUri, body: 'body');
      expect(response.body.asString(), equals('body'));
    });

    test('custom HTTP method request', () async {
      Response response =
          await Http.send('COPY', IntegrationPaths.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('COPY'));
    });

    test('custom HTTP method request with headers', () async {
      Response response = await Http.send(
          'COPY', IntegrationPaths.reflectEndpointUri,
          headers: new Map.from(headers));
      expect(response.status, equals(200));

      var json = response.body.asJson();
      expect(json['method'], equals('COPY'));
      expect(json['headers'],
          containsPair('authorization', headers['authorization']));
      expect(json['headers'], containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('custom HTTP method request with body', () async {
      Response response = await Http
          .send('COPY', IntegrationPaths.echoEndpointUri, body: 'body');
      expect(response.body.asString(), equals('body'));
    });

    Future<String> _decodeStreamedResponseToString(
        StreamedResponse response) async {
      Uint8List bytes = await response.body.toBytes();
      return response.encoding.decode(bytes.toList());
    }

    Future<Map> _decodeStreamedResponseToJson(StreamedResponse response) async {
      return JSON.decode(await _decodeStreamedResponseToString(response));
    }

    test('streamed DELETE request', () async {
      StreamedResponse response =
          await Http.streamDelete(IntegrationPaths.reflectEndpointUri);
      expect(response.status, equals(200));
      Map json = await _decodeStreamedResponseToJson(response);
      expect(json['method'], equals('DELETE'));
    });

    test('streamed DELETE request with headers', () async {
      StreamedResponse response = await Http.streamDelete(
          IntegrationPaths.reflectEndpointUri,
          headers: new Map.from(headers));
      expect(response.status, equals(200));

      Map json = await _decodeStreamedResponseToJson(response);
      expect(json['method'], equals('DELETE'));
      expect(json['headers'],
          containsPair('authorization', headers['authorization']));
      expect(json['headers'], containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('streamed GET request', () async {
      StreamedResponse response =
          await Http.streamGet(IntegrationPaths.reflectEndpointUri);
      expect(response.status, equals(200));
      Map json = await _decodeStreamedResponseToJson(response);
      expect(json['method'], equals('GET'));
    });

    test('streamed GET request with headers', () async {
      StreamedResponse response = await Http.streamGet(
          IntegrationPaths.reflectEndpointUri,
          headers: new Map.from(headers));
      expect(response.status, equals(200));

      Map json = await _decodeStreamedResponseToJson(response);
      expect(json['method'], equals('GET'));
      expect(json['headers'],
          containsPair('authorization', headers['authorization']));
      expect(json['headers'], containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('streamed HEAD request', () async {
      StreamedResponse response =
          await Http.streamHead(IntegrationPaths.reflectEndpointUri);
      expect(response.status, equals(200));
    });

    test('streamed HEAD request with headers', () async {
      StreamedResponse response = await Http.streamHead(
          IntegrationPaths.reflectEndpointUri,
          headers: new Map.from(headers));
      expect(response.status, equals(200));
    });

    test('streamed OPTIONS request', () async {
      StreamedResponse response =
          await Http.streamOptions(IntegrationPaths.reflectEndpointUri);
      expect(response.status, equals(200));
      Map json = await _decodeStreamedResponseToJson(response);
      expect(json['method'], equals('OPTIONS'));
    });

    test('streamed OPTIONS request with headers', () async {
      StreamedResponse response = await Http.streamOptions(
          IntegrationPaths.reflectEndpointUri,
          headers: new Map.from(headers));
      expect(response.status, equals(200));

      Map json = await _decodeStreamedResponseToJson(response);
      expect(json['method'], equals('OPTIONS'));
      expect(json['headers'],
          containsPair('authorization', headers['authorization']));
      expect(json['headers'], containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('streamed PATCH request', () async {
      StreamedResponse response =
          await Http.streamPatch(IntegrationPaths.reflectEndpointUri);
      expect(response.status, equals(200));
      Map json = await _decodeStreamedResponseToJson(response);
      expect(json['method'], equals('PATCH'));
    });

    test('streamed PATCH request with headers', () async {
      StreamedResponse response = await Http.streamPatch(
          IntegrationPaths.reflectEndpointUri,
          headers: new Map.from(headers));
      expect(response.status, equals(200));

      Map json = await _decodeStreamedResponseToJson(response);
      expect(json['method'], equals('PATCH'));
      expect(json['headers'],
          containsPair('authorization', headers['authorization']));
      expect(json['headers'], containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('streamed PATCH request with body', () async {
      StreamedResponse response = await Http
          .streamPatch(IntegrationPaths.echoEndpointUri, body: 'body');
      String body = await _decodeStreamedResponseToString(response);
      expect(body, equals('body'));
    });

    test('streamed POST request', () async {
      StreamedResponse response =
          await Http.streamPost(IntegrationPaths.reflectEndpointUri);
      expect(response.status, equals(200));
      Map json = await _decodeStreamedResponseToJson(response);
      expect(json['method'], equals('POST'));
    });

    test('streamed POST request with headers', () async {
      StreamedResponse response = await Http.streamPost(
          IntegrationPaths.reflectEndpointUri,
          headers: new Map.from(headers));
      expect(response.status, equals(200));

      Map json = await _decodeStreamedResponseToJson(response);
      expect(json['method'], equals('POST'));
      expect(json['headers'],
          containsPair('authorization', headers['authorization']));
      expect(json['headers'], containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('streamed POST request with body', () async {
      StreamedResponse response =
          await Http.streamPost(IntegrationPaths.echoEndpointUri, body: 'body');
      String body = await _decodeStreamedResponseToString(response);
      expect(body, equals('body'));
    });

    test('streamed PUT request', () async {
      StreamedResponse response =
          await Http.streamPut(IntegrationPaths.reflectEndpointUri);
      expect(response.status, equals(200));
      Map json = await _decodeStreamedResponseToJson(response);
      expect(json['method'], equals('PUT'));
    });

    test('streamed PUT request with headers', () async {
      StreamedResponse response = await Http.streamPut(
          IntegrationPaths.reflectEndpointUri,
          headers: new Map.from(headers));
      expect(response.status, equals(200));

      Map json = await _decodeStreamedResponseToJson(response);
      expect(json['method'], equals('PUT'));
      expect(json['headers'],
          containsPair('authorization', headers['authorization']));
      expect(json['headers'], containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('streamed PUT request with body', () async {
      StreamedResponse response =
          await Http.streamPut(IntegrationPaths.echoEndpointUri, body: 'body');
      String body = await _decodeStreamedResponseToString(response);
      expect(body, equals('body'));
    });

    test('streamed custom HTTP method request', () async {
      StreamedResponse response =
          await Http.streamSend('COPY', IntegrationPaths.reflectEndpointUri);
      expect(response.status, equals(200));
      Map json = await _decodeStreamedResponseToJson(response);
      expect(json['method'], equals('COPY'));
    });

    test('streamed custom HTTP method request with headers', () async {
      StreamedResponse response = await Http.streamSend(
          'COPY', IntegrationPaths.reflectEndpointUri,
          headers: new Map.from(headers));
      expect(response.status, equals(200));

      Map json = await _decodeStreamedResponseToJson(response);
      expect(json['method'], equals('COPY'));
      expect(json['headers'],
          containsPair('authorization', headers['authorization']));
      expect(json['headers'], containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('streamed custom HTTP method request with body', () async {
      StreamedResponse response = await Http
          .streamSend('COPY', IntegrationPaths.echoEndpointUri, body: 'body');
      String body = await _decodeStreamedResponseToString(response);
      expect(body, equals('body'));
    });
  });
}
