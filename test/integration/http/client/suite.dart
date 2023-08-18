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

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart' as transport;

import '../../integration_paths.dart';

void runHttpTransportClientSuite(
    [transport.TransportPlatform? transportPlatform]) {
  group('Client', () {
    _runHttpClientSuite(
        // ignore: deprecated_member_use_from_same_package
        () => transport.Client(transportPlatform: transportPlatform));
  });

  group('HttpClient', () {
    _runHttpClientSuite(
        () => transport.HttpClient(transportPlatform: transportPlatform));
  });
}

// ignore: deprecated_member_use_from_same_package
void _runHttpClientSuite(transport.Client getClient()) {
  // ignore: deprecated_member_use_from_same_package
  late transport.Client client;

  setUp(() {
    client = getClient();
  });

  test('newFormRequest()', () async {
    final request = client.newFormRequest();
    await _testRequest(request);
    client.close();
  });

  test('newJsonRequest()', () async {
    final request = client.newJsonRequest();
    await _testRequest(request);
    client.close();
  });

  test('newMultipartRequest()', () async {
    final request = client.newMultipartRequest();
    request.fields['key'] = 'value';
    await _testRequest(request);
    client.close();
  });

  test('newRequest()', () async {
    final request = client.newRequest();
    await _testRequest(request);
    client.close();
  });

  test('newStreamedRequest()', () async {
    final request = client.newStreamedRequest();
    await _testRequest(request);
    client.close();
  });

  test('should support multiple concurrent requests', () async {
    final requests = <Future>[
      client.newFormRequest().post(uri: IntegrationPaths.reflectEndpointUri),
      client.newJsonRequest().put(uri: IntegrationPaths.reflectEndpointUri),
      (client.newMultipartRequest()..fields['f'] = 'v')
          .patch(uri: IntegrationPaths.reflectEndpointUri),
      client.newRequest().get(uri: IntegrationPaths.reflectEndpointUri),
      client
          .newStreamedRequest()
          .delete(uri: IntegrationPaths.reflectEndpointUri),
      client
          .newRequest()
          .send('OPTIONS', uri: IntegrationPaths.reflectEndpointUri),
    ];
    await Future.wait(requests);
  });

  test('close() should prevent new requests from being created', () async {
    client.close();
    expect(() {
      client.newRequest();
    }, throwsStateError);
  });

  test('close() should abort all in-flight requests', () async {
    // We will let this request finish before closing the client.
    final willComplete = client.newRequest();
    await willComplete.get(uri: IntegrationPaths.pingEndpointUri);

    // This request should be canceled before it times out.
    final willNotComplete = client.newRequest();
    final willThrow =
        willNotComplete.get(uri: IntegrationPaths.timeoutEndpointUri);

    // Closing the client should not affect the completed request, but should
    // abort the pending request.
    client.close();

    expect(willThrow, throwsA(isA<transport.RequestException>()));
  });
}

Future<Null> _testRequest(transport.BaseRequest request) async {
  request.uri = IntegrationPaths.reflectEndpointUri;
  request.headers = {'x-custom': 'value', 'x-tokens': 'token1, token2'};
  final response = await request.get();
  expect(response.body.asJson()['method'], equals('GET'));
  expect(response.body.asJson()['headers'], containsPair('x-custom', 'value'));
  expect(response.body.asJson()['headers'],
      containsPair('x-tokens', 'token1, token2'));
}
