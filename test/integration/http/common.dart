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

library w_transport.test.integration.http.common;

import 'dart:async';
import 'dart:convert';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';

class HttpIntegrationConfig {
  Uri hostUri;

  String platform;

  HttpIntegrationConfig(String this.platform, this.hostUri);

  Uri get downloadEndpointUri => hostUri.replace(path: '/test/http/download');

  Uri get fourOhFourEndpointUri => hostUri.replace(path: '/test/http/404');

  Uri get pingEndpointUri => hostUri.replace(path: '/test/http/ping');

  Uri get reflectEndpointUri => hostUri.replace(path: '/test/http/reflect');

  Uri get timeoutEndpointUri => hostUri.replace(path: '/test/http/timeout');

  String get title => 'HTTP ($platform):';
}

void runCommonHttpIntegrationTests(HttpIntegrationConfig config) {
  test('should support DELETE request', () async {
    WResponse response = await WHttp.delete(config.reflectEndpointUri);
    expect(response.status, equals(200));
    Map data = JSON.decode(await response.asText());
    expect(data['method'], equals('DELETE'));
  });

  test('should support DELETE request with headers', () async {
    WRequest request = _createRequestWithHeaders(config.reflectEndpointUri);
    WResponse response = await request.delete();
    expect(response.status, equals(200));
    Map data = JSON.decode(await response.asText());
    expect(data['method'], equals('DELETE'));
    expect(data['headers'],
        containsPair('authorization', request.headers['authorization']));
    expect(data['headers'],
        containsPair('content-type', request.headers['content-type']));
    expect(
        data['headers'], containsPair('x-tokens', request.headers['x-tokens']));
  });

  test('should support GET request', () async {
    WResponse response = await WHttp.get(config.reflectEndpointUri);
    expect(response.status, equals(200));
    Map data = JSON.decode(await response.asText());
    expect(data['method'], equals('GET'));
  });

  test('should support GET request with headers', () async {
    WRequest request = _createRequestWithHeaders(config.reflectEndpointUri);
    WResponse response = await request.get();
    expect(response.status, equals(200));
    Map data = JSON.decode(await response.asText());
    expect(data['method'], equals('GET'));
    expect(data['headers'],
        containsPair('authorization', request.headers['authorization']));
    expect(data['headers'],
        containsPair('content-type', request.headers['content-type']));
    expect(
        data['headers'], containsPair('x-tokens', request.headers['x-tokens']));
  });

  test('should support HEAD request', () async {
    WResponse response = await WHttp.head(config.reflectEndpointUri);
    expect(response.status, equals(200));
  });

  test('should support HEAD request with headers', () async {
    WRequest request = _createRequestWithHeaders(config.reflectEndpointUri);
    WResponse response = await request.head();
    expect(response.status, equals(200));
  });

  test('should support OPTIONS request', () async {
    WResponse response = await WHttp.options(config.reflectEndpointUri);
    expect(response.status, equals(200));
    Map data = JSON.decode(await response.asText());
    expect(data['method'], equals('OPTIONS'));
  });

  test('should support OPTIONS request with headers', () async {
    WRequest request = _createRequestWithHeaders(config.reflectEndpointUri);
    WResponse response = await request.options();
    expect(response.status, equals(200));
    Map data = JSON.decode(await response.asText());
    expect(data['method'], equals('OPTIONS'));
    expect(data['headers'],
        containsPair('authorization', request.headers['authorization']));
    expect(data['headers'],
        containsPair('content-type', request.headers['content-type']));
    expect(
        data['headers'], containsPair('x-tokens', request.headers['x-tokens']));
  });

  test('should support PATCH request', () async {
    WResponse response = await WHttp.patch(config.reflectEndpointUri);
    expect(response.status, equals(200));
    Map data = JSON.decode(await response.asText());
    expect(data['method'], equals('PATCH'));
  });

  test('should support PATCH request with headers', () async {
    WRequest request = _createRequestWithHeaders(config.reflectEndpointUri);
    WResponse response = await request.patch();
    expect(response.status, equals(200));
    Map data = JSON.decode(await response.asText());
    expect(data['method'], equals('PATCH'));
    expect(data['headers'],
        containsPair('authorization', request.headers['authorization']));
    expect(data['headers'],
        containsPair('content-type', request.headers['content-type']));
    expect(
        data['headers'], containsPair('x-tokens', request.headers['x-tokens']));
  });

  test('should support PATCH request with data', () async {
    WRequest request = _createRequestWithData(config.reflectEndpointUri);
    WResponse response = await request.patch();
    expect(response.status, equals(200));
    Map data = JSON.decode(await response.asText());
    expect(data['method'], equals('PATCH'));
    expect(data['body'], equals(request.data));
  });

  test('should support POST request', () async {
    WResponse response = await WHttp.post(config.reflectEndpointUri);
    expect(response.status, equals(200));
    Map data = JSON.decode(await response.asText());
    expect(data['method'], equals('POST'));
  });

  test('should support POST request with headers', () async {
    WRequest request = _createRequestWithHeaders(config.reflectEndpointUri);
    WResponse response = await request.post();
    expect(response.status, equals(200));
    Map data = JSON.decode(await response.asText());
    expect(data['method'], equals('POST'));
    expect(data['headers'],
        containsPair('authorization', request.headers['authorization']));
    expect(data['headers'],
        containsPair('content-type', request.headers['content-type']));
    expect(
        data['headers'], containsPair('x-tokens', request.headers['x-tokens']));
  });

  test('should support POST request with data', () async {
    WRequest request = _createRequestWithData(config.reflectEndpointUri);
    WResponse response = await request.post();
    expect(response.status, equals(200));
    Map data = JSON.decode(await response.asText());
    expect(data['method'], equals('POST'));
    expect(data['body'], equals(request.data));
  });

  test('should support PUT request', () async {
    WResponse response = await WHttp.put(config.reflectEndpointUri);
    expect(response.status, equals(200));
    Map data = JSON.decode(await response.asText());
    expect(data['method'], equals('PUT'));
  });

  test('should support PUT request with headers', () async {
    WRequest request = _createRequestWithHeaders(config.reflectEndpointUri);
    WResponse response = await request.put();
    expect(response.status, equals(200));
    Map data = JSON.decode(await response.asText());
    expect(data['method'], equals('PUT'));
    expect(data['headers'],
        containsPair('authorization', request.headers['authorization']));
    expect(data['headers'],
        containsPair('content-type', request.headers['content-type']));
    expect(
        data['headers'], containsPair('x-tokens', request.headers['x-tokens']));
  });

  test('should support PUT request with data', () async {
    WRequest request = _createRequestWithData(config.reflectEndpointUri);
    WResponse response = await request.put();
    expect(response.status, equals(200));
    Map data = JSON.decode(await response.asText());
    expect(data['method'], equals('PUT'));
    expect(data['body'], equals(request.data));
  });

  test('should support multiple requests from a single WHttp client', () async {
    WHttp http = new WHttp();
    List<Future<WResponse>> requests = [
      http.newRequest().delete(uri: config.reflectEndpointUri),
      http.newRequest().get(uri: config.reflectEndpointUri),
      http.newRequest().head(uri: config.reflectEndpointUri),
      http.newRequest().options(uri: config.reflectEndpointUri),
      http.newRequest().patch(uri: config.reflectEndpointUri),
      http.newRequest().post(uri: config.reflectEndpointUri),
      http.newRequest().put(uri: config.reflectEndpointUri),
    ];
    await Future.wait(requests);
    for (int i = 0; i < requests.length; i++) {
      expect((await requests[i]).status, equals(200));
    }
  });

  test(
      'should support closing a WHttp client, at which point new requests should throw',
      () async {
    WHttp http = new WHttp();
    http.close();
    expect(http.newRequest, throwsStateError);
  });

  test('should make response data available as a Future', () async {
    WResponse response = await WHttp.get(config.reflectEndpointUri);
    Object data = await response.asFuture();
    expect(data is List<int> || data is String, isTrue);
  });

  test('should make response data available decoded to text', () async {
    WResponse response = await WHttp.get(config.reflectEndpointUri);
    String text = await response.asText();
    expect(text.isNotEmpty, isTrue);
  });

  test('should make response data available as a Stream', () async {
    WResponse response = await WHttp.get(config.reflectEndpointUri);
    expect(await response.asStream().isEmpty, isFalse);
  });

  test('should cache data to allow multiple accesses', () async {
    WResponse response = await WHttp.get(config.reflectEndpointUri);
    Object data = await response.asFuture();
    expect(data is List<int> || data is String, isTrue);
    String text = await response.asText();
    expect(text.isNotEmpty, isTrue);
    expect(await response.asStream().isEmpty, isFalse);
  });

  test('should be able to update the data source', () async {
    WResponse response = await WHttp.get(config.reflectEndpointUri);
    response.update(new Stream.fromIterable([UTF8.encode('updated1')]));
    expect(await response.asText(), equals('updated1'));
    response.update('updated2');
    expect(await response.asText(), equals('updated2'));
  });

  test('should throw WHttpException on failed requests', () async {
    expect(
        WHttp.get(config.fourOhFourEndpointUri),
        throwsA(predicate((exception) {
          return exception != null &&
              exception is WHttpException &&
              exception.method == 'GET' &&
              exception.uri == config.fourOhFourEndpointUri;
        }, 'throws a WHttpException')));
  });

  test('request cancellation prior to dispatch should cause request to fail',
      () async {
    WRequest request = new WRequest()..uri = config.hostUri;
    request.abort();
    expect(request.get(), throwsA(predicate((exception) {
      return exception is WHttpException &&
          exception.toString().contains('canceled');
    })));
  });

  test(
      'request cancellation after dispatch but prior to resolution should cause request to fail',
      () async {
    WRequest request = new WRequest()..uri = config.timeoutEndpointUri;
    Future future = request.get();

    // Wait a sufficient amount of time to allow the request to open.
    // Since we're hitting a timeout endpoint, it shouldn't complete.
    await new Future.delayed(new Duration(seconds: 1));

    // Abort the request now that it is in flight.
    request.abort();
    expect(future, throwsA(new isInstanceOf<WHttpException>()));
  });
}

WRequest _createRequestWithData(Uri uri) => new WRequest()
  ..uri = uri
  ..data = 'data';

WRequest _createRequestWithHeaders(Uri uri) => new WRequest()
  ..uri = uri
  ..headers = {
    'authorization': 'test',
    'content-type': 'application/json',
    'x-tokens': 'token1, token2'
  };
