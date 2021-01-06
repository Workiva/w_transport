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

@TestOn('vm')
import 'dart:async';

import 'package:pedantic/pedantic.dart';
import 'package:test/test.dart';
import 'package:w_transport/mock.dart';
import 'package:w_transport/vm.dart';
import 'package:w_transport/w_transport.dart' as transport;

import 'package:w_transport/src/http/vm/http_client.dart';
import 'package:w_transport/src/http/vm/requests.dart';
import 'package:w_transport/src/web_socket/vm/web_socket.dart';

import '../../naming.dart';
import '../integration_paths.dart';

void main() {
  final naming = Naming()
    ..platform = platformVM
    ..testType = testTypeIntegration
    ..topic = topicTransportPlatform;

  group(naming.toString(), () {
    tearDown(() {
      transport.resetGlobalTransportPlatform();
    });

    test('globalTransportPlatform = vmTransportPlatform', () async {
      transport.globalTransportPlatform = vmTransportPlatform;

      // Properly constructs VM implementations of HTTP classes
      expect(transport.HttpClient(), isA<VMHttpClient>());
      expect(transport.FormRequest(), isA<VMFormRequest>());
      expect(transport.JsonRequest(), isA<VMJsonRequest>());
      expect(transport.MultipartRequest(), isA<VMMultipartRequest>());
      expect(transport.Request(), isA<VMPlainTextRequest>());
      expect(transport.StreamedRequest(), isA<VMStreamedRequest>());

      // Properly constructs VM implementation of WebSocket
      final webSocket =
          await transport.WebSocket.connect(IntegrationPaths.pingUri);
      expect(webSocket, isA<VMWebSocket>());
      await webSocket.close();
      final wSocket =
          await transport.WebSocket.connect(IntegrationPaths.pingUri);
      expect(wSocket, isA<VMWebSocket>());
      await wSocket.close();
    });

    test('configureWTransportForVM()', () async {
      configureWTransportForVM();

      // Properly constructs VM implementations of HTTP classes
      expect(transport.HttpClient(), isA<VMHttpClient>());
      expect(transport.FormRequest(), isA<VMFormRequest>());
      expect(transport.JsonRequest(), isA<VMJsonRequest>());
      expect(transport.MultipartRequest(), isA<VMMultipartRequest>());
      expect(transport.Request(), isA<VMPlainTextRequest>());
      expect(transport.StreamedRequest(), isA<VMStreamedRequest>());

      // Properly constructs VM implementation of WebSocket
      final webSocket =
          await transport.WebSocket.connect(IntegrationPaths.pingUri);
      expect(webSocket, isA<VMWebSocket>());
      await webSocket.close();
      final wSocket =
          await transport.WebSocket.connect(IntegrationPaths.pingUri);
      expect(wSocket, isA<VMWebSocket>());
      await wSocket.close();
    });

    group('mock-aware', () {
      tearDown(() async {
        MockTransports.verifyNoOutstandingExceptions();
        await MockTransports.uninstall();
      });

      group('fallThrough: false', () {
        setUp(() {
          MockTransports.install(fallThrough: false);
        });

        test('requests with matching expectation should be handled', () async {
          final formRequest =
              transport.FormRequest(transportPlatform: vmTransportPlatform);
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await formRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final jsonRequest =
              transport.JsonRequest(transportPlatform: vmTransportPlatform);
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await jsonRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final multipartRequest =
              transport.MultipartRequest(transportPlatform: vmTransportPlatform)
                ..fields['foo'] = 'bar';
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await multipartRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final request =
              transport.Request(transportPlatform: vmTransportPlatform);
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await request.get(uri: IntegrationPaths.pingEndpointUri);

          final streamedRequest =
              transport.StreamedRequest(transportPlatform: vmTransportPlatform);
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await streamedRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final requestWithStreamedResponse =
              transport.Request(transportPlatform: vmTransportPlatform);
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await requestWithStreamedResponse.streamGet(
              uri: IntegrationPaths.pingEndpointUri);

          final httpClient =
              transport.HttpClient(transportPlatform: vmTransportPlatform);

          final clientFormRequest = httpClient.newFormRequest();
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await clientFormRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final clientJsonRequest = httpClient.newJsonRequest();
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await clientJsonRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final clientMultipartRequest = httpClient.newMultipartRequest()
            ..fields['foo'] = 'bar';
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await clientMultipartRequest.get(
              uri: IntegrationPaths.pingEndpointUri);

          final clientRequest = httpClient.newRequest();
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await clientRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final clientStreamedRequest = httpClient.newStreamedRequest();
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await clientStreamedRequest.get(
              uri: IntegrationPaths.pingEndpointUri);

          final clientRequestWithStreamedResponse = httpClient.newRequest();
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await clientRequestWithStreamedResponse.streamGet(
              uri: IntegrationPaths.pingEndpointUri);
        });

        test('requests with matching handler should be handled', () async {
          MockTransports.http.when(IntegrationPaths.pingEndpointUri,
              (request) async => MockResponse.ok());

          final formRequest =
              transport.FormRequest(transportPlatform: vmTransportPlatform);
          await formRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final jsonRequest =
              transport.JsonRequest(transportPlatform: vmTransportPlatform);
          await jsonRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final multipartRequest =
              transport.MultipartRequest(transportPlatform: vmTransportPlatform)
                ..fields['foo'] = 'bar';
          await multipartRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final request =
              transport.Request(transportPlatform: vmTransportPlatform);
          await request.get(uri: IntegrationPaths.pingEndpointUri);

          final streamedRequest =
              transport.StreamedRequest(transportPlatform: vmTransportPlatform);
          await streamedRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final requestWithStreamedResponse =
              transport.Request(transportPlatform: vmTransportPlatform);
          await requestWithStreamedResponse.streamGet(
              uri: IntegrationPaths.pingEndpointUri);

          final httpClient =
              transport.HttpClient(transportPlatform: vmTransportPlatform);

          final clientFormRequest = httpClient.newFormRequest();
          await clientFormRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final clientJsonRequest = httpClient.newJsonRequest();
          await clientJsonRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final clientMultipartRequest = httpClient.newMultipartRequest()
            ..fields['foo'] = 'bar';
          await clientMultipartRequest.get(
              uri: IntegrationPaths.pingEndpointUri);

          final clientRequest = httpClient.newRequest();
          await clientRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final clientStreamedRequest = httpClient.newStreamedRequest();
          await clientStreamedRequest.get(
              uri: IntegrationPaths.pingEndpointUri);

          final clientRequestWithStreamedResponse = httpClient.newRequest();
          await clientRequestWithStreamedResponse.streamGet(
              uri: IntegrationPaths.pingEndpointUri);
        });

        test('websockets with matching expectation should be handled',
            () async {
          final mockWebSocketServer = MockWebSocketServer();

          MockTransports.webSocket
              .expect(IntegrationPaths.pingUri, connectTo: mockWebSocketServer);
          final webSocket = await transport.WebSocket.connect(
              IntegrationPaths.pingUri,
              transportPlatform: vmTransportPlatform);
          await webSocket.close();

          await mockWebSocketServer.shutDown();
        });

        test('websockets with matching handler should be handled', () async {
          final mockWebSocketServer = MockWebSocketServer();

          MockTransports.webSocket.when(IntegrationPaths.pingUri,
              handler: (Uri uri,
                      {Map<String, dynamic> headers,
                      Iterable<String> protocols}) async =>
                  mockWebSocketServer);

          final webSocket = await transport.WebSocket.connect(
              IntegrationPaths.pingUri,
              transportPlatform: vmTransportPlatform);
          await webSocket.close();

          await mockWebSocketServer.shutDown();
        });

        test('requests without expectation or handler should be pending',
            () async {
          final formRequest =
              transport.FormRequest(transportPlatform: vmTransportPlatform);
          unawaited(formRequest.get(uri: IntegrationPaths.pingEndpointUri));

          final jsonRequest =
              transport.JsonRequest(transportPlatform: vmTransportPlatform);
          unawaited(jsonRequest.get(uri: IntegrationPaths.pingEndpointUri));

          final multipartRequest =
              transport.MultipartRequest(transportPlatform: vmTransportPlatform)
                ..fields['foo'] = 'bar';
          unawaited(
              multipartRequest.get(uri: IntegrationPaths.pingEndpointUri));

          final request =
              transport.Request(transportPlatform: vmTransportPlatform);
          unawaited(request.get(uri: IntegrationPaths.pingEndpointUri));

          final streamedRequest =
              transport.StreamedRequest(transportPlatform: vmTransportPlatform);
          unawaited(streamedRequest.get(uri: IntegrationPaths.pingEndpointUri));

          final requestWithStreamedResponse =
              transport.Request(transportPlatform: vmTransportPlatform);
          unawaited(requestWithStreamedResponse.streamGet(
              uri: IntegrationPaths.pingEndpointUri));

          final httpClient =
              transport.HttpClient(transportPlatform: vmTransportPlatform);

          final clientFormRequest = httpClient.newFormRequest();
          unawaited(
              clientFormRequest.get(uri: IntegrationPaths.pingEndpointUri));

          final clientJsonRequest = httpClient.newJsonRequest();
          unawaited(
              clientJsonRequest.get(uri: IntegrationPaths.pingEndpointUri));

          final clientMultipartRequest = httpClient.newMultipartRequest()
            ..fields['foo'] = 'bar';
          unawaited(clientMultipartRequest.get(
              uri: IntegrationPaths.pingEndpointUri));

          final clientRequest = httpClient.newRequest();
          unawaited(clientRequest.get(uri: IntegrationPaths.pingEndpointUri));

          final clientStreamedRequest = httpClient.newStreamedRequest();
          unawaited(
              clientStreamedRequest.get(uri: IntegrationPaths.pingEndpointUri));

          final clientRequestWithStreamedResponse = httpClient.newRequest();
          unawaited(clientRequestWithStreamedResponse.streamGet(
              uri: IntegrationPaths.pingEndpointUri));

          await Future.delayed(const Duration(milliseconds: 50));
          expect(MockTransports.http.numPendingRequests, equals(12));
          await MockTransports.reset();
        });

        test(
            'websockets without expectation or handler should throw StateError',
            () async {
          expect(
              transport.WebSocket.connect(IntegrationPaths.pingUri,
                  transportPlatform: vmTransportPlatform),
              throwsStateError);
        });
      });

      group('fallThrough: true', () {
        setUp(() {
          MockTransports.install(fallThrough: true);
        });

        test('requests with matching expectation should be handled', () async {
          final formRequest =
              transport.FormRequest(transportPlatform: vmTransportPlatform);
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await formRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final jsonRequest =
              transport.JsonRequest(transportPlatform: vmTransportPlatform);
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await jsonRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final multipartRequest =
              transport.MultipartRequest(transportPlatform: vmTransportPlatform)
                ..fields['foo'] = 'bar';
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await multipartRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final request =
              transport.Request(transportPlatform: vmTransportPlatform);
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await request.get(uri: IntegrationPaths.pingEndpointUri);

          final streamedRequest =
              transport.StreamedRequest(transportPlatform: vmTransportPlatform);
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await streamedRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final requestWithStreamedResponse =
              transport.Request(transportPlatform: vmTransportPlatform);
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await requestWithStreamedResponse.streamGet(
              uri: IntegrationPaths.pingEndpointUri);

          final httpClient =
              transport.HttpClient(transportPlatform: vmTransportPlatform);

          final clientFormRequest = httpClient.newFormRequest();
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await clientFormRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final clientJsonRequest = httpClient.newJsonRequest();
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await clientJsonRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final clientMultipartRequest = httpClient.newMultipartRequest()
            ..fields['foo'] = 'bar';
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await clientMultipartRequest.get(
              uri: IntegrationPaths.pingEndpointUri);

          final clientRequest = httpClient.newRequest();
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await clientRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final clientStreamedRequest = httpClient.newStreamedRequest();
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await clientStreamedRequest.get(
              uri: IntegrationPaths.pingEndpointUri);

          final clientRequestWithStreamedResponse = httpClient.newRequest();
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await clientRequestWithStreamedResponse.streamGet(
              uri: IntegrationPaths.pingEndpointUri);
        });

        test('requests with matching handler should be handled', () async {
          MockTransports.http.when(IntegrationPaths.pingEndpointUri,
              (request) async => MockResponse.ok());

          final formRequest =
              transport.FormRequest(transportPlatform: vmTransportPlatform);
          await formRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final jsonRequest =
              transport.JsonRequest(transportPlatform: vmTransportPlatform);
          await jsonRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final multipartRequest =
              transport.MultipartRequest(transportPlatform: vmTransportPlatform)
                ..fields['foo'] = 'bar';
          await multipartRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final request =
              transport.Request(transportPlatform: vmTransportPlatform);
          await request.get(uri: IntegrationPaths.pingEndpointUri);

          final streamedRequest =
              transport.StreamedRequest(transportPlatform: vmTransportPlatform);
          await streamedRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final requestWithStreamedResponse =
              transport.Request(transportPlatform: vmTransportPlatform);
          await requestWithStreamedResponse.streamGet(
              uri: IntegrationPaths.pingEndpointUri);

          final httpClient =
              transport.HttpClient(transportPlatform: vmTransportPlatform);

          final clientFormRequest = httpClient.newFormRequest();
          await clientFormRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final clientJsonRequest = httpClient.newJsonRequest();
          await clientJsonRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final clientMultipartRequest = httpClient.newMultipartRequest()
            ..fields['foo'] = 'bar';
          await clientMultipartRequest.get(
              uri: IntegrationPaths.pingEndpointUri);

          final clientRequest = httpClient.newRequest();
          await clientRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final clientStreamedRequest = httpClient.newStreamedRequest();
          await clientStreamedRequest.get(
              uri: IntegrationPaths.pingEndpointUri);

          final clientRequestWithStreamedResponse = httpClient.newRequest();
          await clientRequestWithStreamedResponse.streamGet(
              uri: IntegrationPaths.pingEndpointUri);
        });

        test('websockets with matching expectation should be handled',
            () async {
          final mockWebSocketServer = MockWebSocketServer();

          MockTransports.webSocket
              .expect(IntegrationPaths.pingUri, connectTo: mockWebSocketServer);
          final webSocket = await transport.WebSocket.connect(
              IntegrationPaths.pingUri,
              transportPlatform: vmTransportPlatform);
          await webSocket.close();

          await mockWebSocketServer.shutDown();
        });

        test('websockets with matching handler should be handled', () async {
          final mockWebSocketServer = MockWebSocketServer();

          MockTransports.webSocket.when(IntegrationPaths.pingUri,
              handler: (Uri uri,
                      {Map<String, dynamic> headers,
                      Iterable<String> protocols}) async =>
                  mockWebSocketServer);

          final webSocket = await transport.WebSocket.connect(
              IntegrationPaths.pingUri,
              transportPlatform: vmTransportPlatform);
          await webSocket.close();

          await mockWebSocketServer.shutDown();
        });

        test(
            'requests without expectation or handler should switch to real request',
            () async {
          final formRequest =
              transport.FormRequest(transportPlatform: vmTransportPlatform);
          await formRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final jsonRequest =
              transport.JsonRequest(transportPlatform: vmTransportPlatform);
          await jsonRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final multipartRequest =
              transport.MultipartRequest(transportPlatform: vmTransportPlatform)
                ..fields['foo'] = 'bar';
          await multipartRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final request =
              transport.Request(transportPlatform: vmTransportPlatform);
          await request.get(uri: IntegrationPaths.pingEndpointUri);

          final streamedRequest =
              transport.StreamedRequest(transportPlatform: vmTransportPlatform);
          await streamedRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final requestWithStreamedResponse =
              transport.Request(transportPlatform: vmTransportPlatform);
          await requestWithStreamedResponse.streamGet(
              uri: IntegrationPaths.pingEndpointUri);

          final httpClient =
              transport.HttpClient(transportPlatform: vmTransportPlatform);

          final clientFormRequest = httpClient.newFormRequest();
          await clientFormRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final clientJsonRequest = httpClient.newJsonRequest();
          await clientJsonRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final clientMultipartRequest = httpClient.newMultipartRequest()
            ..fields['foo'] = 'bar';
          await clientMultipartRequest.get(
              uri: IntegrationPaths.pingEndpointUri);

          final clientRequest = httpClient.newRequest();
          await clientRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final clientStreamedRequest = httpClient.newStreamedRequest();
          await clientStreamedRequest.get(
              uri: IntegrationPaths.pingEndpointUri);

          final clientRequestWithStreamedResponse = httpClient.newRequest();
          await clientRequestWithStreamedResponse.streamGet(
              uri: IntegrationPaths.pingEndpointUri);
        });

        test(
            'websockets without expectation or handler should switch to real websocket',
            () async {
          final webSocket = await transport.WebSocket.connect(
              IntegrationPaths.pingUri,
              transportPlatform: vmTransportPlatform);
          await webSocket.close();
        });
      });
    });
  });
}
