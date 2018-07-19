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

import 'package:test/test.dart';
import 'package:w_transport/mock.dart';
import 'package:w_transport/vm.dart';
import 'package:w_transport/w_transport.dart' as transport;

import 'package:w_transport/src/http/mock/http_client.dart';
import 'package:w_transport/src/http/mock/request_mixin.dart';
import 'package:w_transport/src/http/mock/requests.dart';
import 'package:w_transport/src/web_socket/mock/web_socket.dart';

import '../../naming.dart';
import '../integration_paths.dart';

void main() {
  final naming = new Naming()
    ..platform = platformMock
    ..testType = testTypeIntegration
    ..topic = topicTransportPlatform;

  group(naming.toString(), () {
    test('MockTransports.install()', () async {
      MockTransports.install();

      // Properly constructs mock-aware implementations of HTTP classes
      // ignore: deprecated_member_use
      expect(new transport.Client(), new isInstanceOf<MockHttpClient>());
      expect(new transport.HttpClient(), new isInstanceOf<MockHttpClient>());
      // ignore: deprecated_member_use
      expect(new transport.FormRequest(), new isInstanceOf<MockFormRequest>());
      // ignore: deprecated_member_use
      expect(new transport.JsonRequest(), new isInstanceOf<MockJsonRequest>());
      expect(
          new transport.MultipartRequest(),
          // ignore: deprecated_member_use
          new isInstanceOf<MockMultipartRequest>());
      // ignore: deprecated_member_use
      expect(new transport.Request(), new isInstanceOf<MockPlainTextRequest>());
      expect(
          new transport.StreamedRequest(),
          // ignore: deprecated_member_use
          new isInstanceOf<MockStreamedRequest>());

      // Properly constructs a mock-aware implementation of WebSocket
      final mockWebSocketServer = new MockWebSocketServer();
      MockTransports.webSocket
          .expect(IntegrationPaths.pingUri, connectTo: mockWebSocketServer);
      final webSocket =
          await transport.WebSocket.connect(IntegrationPaths.pingUri);
      expect(webSocket, new isInstanceOf<MockWebSocket>());
      await webSocket.close();
      MockTransports.webSocket
          .expect(IntegrationPaths.pingUri, connectTo: mockWebSocketServer);
      // ignore: deprecated_member_use
      final wSocket = await transport.WSocket.connect(IntegrationPaths.pingUri);
      expect(webSocket, new isInstanceOf<MockWebSocket>());
      await wSocket.close();
      await mockWebSocketServer.shutDown();

      MockTransports.verifyNoOutstandingExceptions();
      await MockTransports.uninstall();
    });

    test('configureWTransportForTest()', () async {
      configureWTransportForTest();

      // Properly constructs mock-aware implementations of HTTP classes
      // ignore: deprecated_member_use
      expect(new transport.Client(), new isInstanceOf<MockHttpClient>());
      expect(new transport.HttpClient(), new isInstanceOf<MockHttpClient>());
      // ignore: deprecated_member_use
      expect(new transport.FormRequest(), new isInstanceOf<MockFormRequest>());
      // ignore: deprecated_member_use
      expect(new transport.JsonRequest(), new isInstanceOf<MockJsonRequest>());
      expect(
          new transport.MultipartRequest(),
          // ignore: deprecated_member_use
          new isInstanceOf<MockMultipartRequest>());
      // ignore: deprecated_member_use
      expect(new transport.Request(), new isInstanceOf<MockPlainTextRequest>());
      expect(
          new transport.StreamedRequest(),
          // ignore: deprecated_member_use
          new isInstanceOf<MockStreamedRequest>());

      // Properly constructs a mock-aware implementation of WebSocket
      final mockWebSocketServer = new MockWebSocketServer();
      MockTransports.webSocket
          .expect(IntegrationPaths.pingUri, connectTo: mockWebSocketServer);
      final webSocket =
          await transport.WebSocket.connect(IntegrationPaths.pingUri);
      expect(webSocket, new isInstanceOf<MockWebSocket>());
      await webSocket.close();
      MockTransports.webSocket
          .expect(IntegrationPaths.pingUri, connectTo: mockWebSocketServer);
      // ignore: deprecated_member_use
      final wSocket = await transport.WSocket.connect(IntegrationPaths.pingUri);
      expect(webSocket, new isInstanceOf<MockWebSocket>());
      await wSocket.close();
      await mockWebSocketServer.shutDown();

      MockTransports.verifyNoOutstandingExceptions();
      await MockTransports.uninstall();
    });

    test('switching to real requests should fail if no real TP is given',
        () async {
      MockTransports.install(fallThrough: true);

      final formRequest = new transport.FormRequest();
      expect(formRequest.get(uri: IntegrationPaths.pingEndpointUri),
          throwsA(new isInstanceOf<transport.TransportPlatformMissing>()));

      final jsonRequest = new transport.JsonRequest();
      expect(jsonRequest.get(uri: IntegrationPaths.pingEndpointUri),
          throwsA(new isInstanceOf<transport.TransportPlatformMissing>()));

      final multipartRequest = new transport.MultipartRequest()
        ..fields['foo'] = 'bar';
      expect(multipartRequest.get(uri: IntegrationPaths.pingEndpointUri),
          throwsA(new isInstanceOf<transport.TransportPlatformMissing>()));

      final request = new transport.Request();
      expect(request.get(uri: IntegrationPaths.pingEndpointUri),
          throwsA(new isInstanceOf<transport.TransportPlatformMissing>()));

      final streamedRequest = new transport.StreamedRequest();
      expect(streamedRequest.get(uri: IntegrationPaths.pingEndpointUri),
          throwsA(new isInstanceOf<transport.TransportPlatformMissing>()));

      final requestWithStreamedResponse = new transport.Request();
      expect(
          requestWithStreamedResponse.streamGet(
              uri: IntegrationPaths.pingEndpointUri),
          throwsA(new isInstanceOf<transport.TransportPlatformMissing>()));

      final httpClient = new transport.HttpClient();

      final clientFormRequest = httpClient.newFormRequest();
      expect(clientFormRequest.get(uri: IntegrationPaths.pingEndpointUri),
          throwsA(new isInstanceOf<transport.TransportPlatformMissing>()));

      final clientJsonRequest = httpClient.newJsonRequest();
      expect(clientJsonRequest.get(uri: IntegrationPaths.pingEndpointUri),
          throwsA(new isInstanceOf<transport.TransportPlatformMissing>()));

      final clientMultipartRequest = httpClient.newMultipartRequest()
        ..fields['foo'] = 'bar';
      expect(clientMultipartRequest.get(uri: IntegrationPaths.pingEndpointUri),
          throwsA(new isInstanceOf<transport.TransportPlatformMissing>()));

      final clientRequest = httpClient.newRequest();
      expect(clientRequest.get(uri: IntegrationPaths.pingEndpointUri),
          throwsA(new isInstanceOf<transport.TransportPlatformMissing>()));

      final clientStreamedRequest = httpClient.newStreamedRequest();
      expect(clientStreamedRequest.get(uri: IntegrationPaths.pingEndpointUri),
          throwsA(new isInstanceOf<transport.TransportPlatformMissing>()));

      final clientRequestWithStreamedResponse = httpClient.newRequest();
      expect(
          clientRequestWithStreamedResponse.streamGet(
              uri: IntegrationPaths.pingEndpointUri),
          throwsA(new isInstanceOf<transport.TransportPlatformMissing>()));

      await MockTransports.uninstall();
    });

    test('switching to a real request should copy over all properties', () {
      MockTransports.install(fallThrough: true);

      Future<Null> requestInterceptor(transport.BaseRequest request) async =>
          null;
      Future<transport.BaseResponse> responseInterceptor(
              FinalizedRequest request, transport.BaseResponse response,
              [transport.RequestException error]) async =>
          null;
      final request =
          new transport.Request(transportPlatform: vmTransportPlatform)
            ..autoRetry.enabled = true
            ..contentType = new transport.MediaType('application', 'json')
            ..headers['x-custom'] = 'test'
            ..requestInterceptor = requestInterceptor
            ..responseInterceptor = responseInterceptor
            ..timeoutThreshold = const Duration(seconds: 5)
            ..uri = IntegrationPaths.reflectEndpointUri
            ..withCredentials = true;

      // ignore: avoid_as
      final realRequest = (request as MockRequestMixin).switchToRealRequest();

      expect(realRequest.autoRetry.enabled, isTrue);
      expect(realRequest.contentType.mimeType, equals('application/json'));
      expect(realRequest.headers, containsPair('x-custom', 'test'));
      expect(identical(realRequest.requestInterceptor, requestInterceptor),
          isTrue);
      expect(identical(realRequest.responseInterceptor, responseInterceptor),
          isTrue);
      expect(realRequest.timeoutThreshold.inSeconds, equals(5));
      expect(realRequest.uri, equals(IntegrationPaths.reflectEndpointUri));
      expect(realRequest.withCredentials, isTrue);

      // Content-length should be copied as well (only works with streamed).
      final streamedRequest =
          new transport.StreamedRequest(transportPlatform: vmTransportPlatform)
            ..contentLength = 10;
      // ignore: avoid_as
      final realStreamedRequest =
          (streamedRequest as MockRequestMixin).switchToRealRequest();
      expect(realStreamedRequest.contentLength, equals(10));
    });
  });
}
