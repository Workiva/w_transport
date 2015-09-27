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
import 'dart:typed_data';

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
    Response response = await Http.delete(config.reflectEndpointUri);
    expect(response.status, equals(200));
    expect(response.body.asJson()['method'], equals('DELETE'));
  });

  test('should support DELETE request with headers', () async {
    Request request = _createRequestWithHeaders(config.reflectEndpointUri);
    Response response = await request.delete();
    expect(response.status, equals(200));
    expect(response.body.asJson()['method'], equals('DELETE'));
    expect(response.body.asJson()['headers'],
        containsPair('authorization', request.headers['authorization']));
    expect(response.body.asJson()['headers'],
        containsPair('content-type', request.headers['content-type']));
    expect(
        response.body.asJson()['headers'], containsPair('x-tokens', request.headers['x-tokens']));
  });

  test('should support GET request', () async {
    Response response = await Http.get(config.reflectEndpointUri);
    expect(response.status, equals(200));
    expect(response.body.asJson()['method'], equals('GET'));
  });

  test('should support GET request with headers', () async {
    Request request = _createRequestWithHeaders(config.reflectEndpointUri);
    Response response = await request.get();
    expect(response.status, equals(200));
    expect(response.body.asJson()['method'], equals('GET'));
    expect(response.body.asJson()['headers'],
        containsPair('authorization', request.headers['authorization']));
    expect(response.body.asJson()['headers'],
        containsPair('content-type', request.headers['content-type']));
    expect(
        response.body.asJson()['headers'], containsPair('x-tokens', request.headers['x-tokens']));
  });

  test('should support HEAD request', () async {
    Response response = await Http.head(config.reflectEndpointUri);
    expect(response.status, equals(200));
  });

  test('should support HEAD request with headers', () async {
    Request request = _createRequestWithHeaders(config.reflectEndpointUri);
    Response response = await request.head();
    expect(response.status, equals(200));
  });

  test('should support OPTIONS request', () async {
    Response response = await Http.options(config.reflectEndpointUri);
    expect(response.status, equals(200));
    expect(response.body.asJson()['method'], equals('OPTIONS'));
  });

  test('should support OPTIONS request with headers', () async {
    Request request = _createRequestWithHeaders(config.reflectEndpointUri);
    Response response = await request.options();
    expect(response.status, equals(200));
    expect(response.body.asJson()['method'], equals('OPTIONS'));
    expect(response.body.asJson()['headers'],
        containsPair('authorization', request.headers['authorization']));
    expect(response.body.asJson()['headers'],
        containsPair('content-type', request.headers['content-type']));
    expect(
        response.body.asJson()['headers'], containsPair('x-tokens', request.headers['x-tokens']));
  });

  test('should support PATCH request', () async {
    Response response = await Http.patch(config.reflectEndpointUri);
    expect(response.status, equals(200));
    expect(response.body.asJson()['method'], equals('PATCH'));
  });

  test('should support PATCH request with headers', () async {
    Request request = _createRequestWithHeaders(config.reflectEndpointUri);
    Response response = await request.patch();
    expect(response.status, equals(200));
    expect(response.body.asJson()['method'], equals('PATCH'));
    expect(response.body.asJson()['headers'],
        containsPair('authorization', request.headers['authorization']));
    expect(response.body.asJson()['headers'],
        containsPair('content-type', request.headers['content-type']));
    expect(
        response.body.asJson()['headers'], containsPair('x-tokens', request.headers['x-tokens']));
  });

  test('should support PATCH request with data', () async {
    Request request = _createRequestWithData(config.reflectEndpointUri);
    Response response = await request.patch();
    expect(response.status, equals(200));
    expect(response.body.asJson()['method'], equals('PATCH'));
    expect(response.body.asJson()['body'], equals(request.body));
  });

  test('should support POST request', () async {
    Response response = await Http.post(config.reflectEndpointUri);
    expect(response.status, equals(200));
    expect(response.body.asJson()['method'], equals('POST'));
  });

  test('should support POST request with headers', () async {
    Request request = _createRequestWithHeaders(config.reflectEndpointUri);
    Response response = await request.post();
    expect(response.status, equals(200));
    expect(response.body.asJson()['method'], equals('POST'));
    expect(response.body.asJson()['headers'],
        containsPair('authorization', request.headers['authorization']));
    expect(response.body.asJson()['headers'],
        containsPair('content-type', request.headers['content-type']));
    expect(
        response.body.asJson()['headers'], containsPair('x-tokens', request.headers['x-tokens']));
  });

  test('should support POST request with data', () async {
    Request request = _createRequestWithData(config.reflectEndpointUri);
    Response response = await request.post();
    expect(response.status, equals(200));
    expect(response.body.asJson()['method'], equals('POST'));
    expect(response.body.asJson()['body'], equals(request.body));
  });

  test('should support PUT request', () async {
    Response response = await Http.put(config.reflectEndpointUri);
    expect(response.status, equals(200));
    expect(response.body.asJson()['method'], equals('PUT'));
  });

  test('should support PUT request with headers', () async {
    Request request = _createRequestWithHeaders(config.reflectEndpointUri);
    Response response = await request.put();
    expect(response.status, equals(200));
    expect(response.body.asJson()['method'], equals('PUT'));
    expect(response.body.asJson()['headers'],
        containsPair('authorization', request.headers['authorization']));
    expect(response.body.asJson()['headers'],
        containsPair('content-type', request.headers['content-type']));
    expect(
        response.body.asJson()['headers'], containsPair('x-tokens', request.headers['x-tokens']));
  });

  test('should support PUT request with data', () async {
    Request request = _createRequestWithData(config.reflectEndpointUri);
    Response response = await request.put();
    expect(response.status, equals(200));
    expect(response.body.asJson()['method'], equals('PUT'));
    expect(response.body.asJson()['body'], equals(request.body));
  });

  test('should support multiple requests from a single Http client', () async {
    Client client = new Client();
    List<Future<Response>> requests = [
      client.newRequest().delete(uri: config.reflectEndpointUri),
      client.newRequest().get(uri: config.reflectEndpointUri),
      client.newRequest().head(uri: config.reflectEndpointUri),
      client.newRequest().options(uri: config.reflectEndpointUri),
      client.newRequest().patch(uri: config.reflectEndpointUri),
      client.newRequest().post(uri: config.reflectEndpointUri),
      client.newRequest().put(uri: config.reflectEndpointUri),
    ];
    await Future.wait(requests);
    for (int i = 0; i < requests.length; i++) {
      expect((await requests[i]).status, equals(200));
    }
  });

  test(
      'should support closing an HTTP client, at which point new requests should throw',
      () async {
    Client client = new Client();
    client.close();
    expect(client.newRequest, throwsStateError);
  });

  test('should make response data available as bytes', () async {
    Response response = await Http.get(config.reflectEndpointUri);
    expect(response.body.asBytes(), new isInstanceOf<Uint8List>());
    expect(response.body.asBytes(), isNotEmpty);
  });

  test('should make response body available decoded to text', () async {
    Response response = await Http.get(config.reflectEndpointUri);
    expect(response.body.asString().isNotEmpty, isTrue);
  });

  test('should make response data available as JSON', () async {
    Response response = await Http.get(config.reflectEndpointUri);
    expect(response.body.asJson(), new isInstanceOf<Map>());
  });

  test('should throw when trying to decode response body to JSON if not valid', () async {
    Response response = await Http.get(config.downloadEndpointUri);
    expect(response.body.asJson, throwsFormatException);
  });

  test('should allow multiple accesses', () async {
    Response response = await Http.get(config.reflectEndpointUri);
    expect(response.body.asBytes(), new isInstanceOf<Uint8List>());
    expect(response.body.asString(), new isInstanceOf<String>());
    expect(response.body.asJson(), new isInstanceOf<Map>());
  });

  test('should throw RequestException on failed requests', () async {
    expect(
        Http.get(config.fourOhFourEndpointUri),
        throwsA(predicate((exception) {
          return exception != null &&
              exception is RequestException &&
              exception.method == 'GET' &&
              exception.uri == config.fourOhFourEndpointUri;
        }, 'throws a RequestException')));
  });

  test('request cancellation prior to dispatch should cause request to fail',
      () async {
    Request request = new Request()..uri = config.hostUri;
    request.abort();
    expect(request.get(), throwsA(predicate((exception) {
      return exception is RequestException &&
          exception.toString().contains('canceled');
    })));
  });

  test(
      'request cancellation after dispatch but prior to resolution should cause request to fail',
      () async {
    Request request = new Request()..uri = config.timeoutEndpointUri;
    Future future = request.get();

    // Wait a sufficient amount of time to allow the request to open.
    // Since we're hitting a timeout endpoint, it shouldn't complete.
    await new Future.delayed(new Duration(seconds: 1));

    // Abort the request now that it is in flight.
    request.abort();
    expect(future, throwsA(new isInstanceOf<RequestException>()));
  });
}

Request _createRequestWithData(Uri uri) => new Request()
  ..uri = uri
  ..body = 'data';

Request _createRequestWithHeaders(Uri uri) => new Request()
  ..uri = uri
  ..headers = {
    'authorization': 'test',
    'content-type': 'application/json',
    'x-tokens': 'token1, token2'
  };
