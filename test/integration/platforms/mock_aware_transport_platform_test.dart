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
  final naming = Naming()
    ..platform = platformMock
    ..testType = testTypeIntegration
    ..topic = topicTransportPlatform;

  group(naming.toString(), () {
    test('MockTransports.install()', () async {
      MockTransports.install();

      // Properly constructs mock-aware implementations of HTTP classes
      // ignore: deprecated_member_use_from_same_package
      expect(transport.Client(), isA<MockHttpClient>());
      expect(transport.HttpClient(), isA<MockHttpClient>());
      // ignore: deprecated_member_use_from_same_package
      expect(transport.FormRequest(), isA<MockFormRequest>());
      // ignore: deprecated_member_use_from_same_package
      expect(transport.JsonRequest(), isA<MockJsonRequest>());
      expect(
          transport.MultipartRequest(),
          // ignore: deprecated_member_use_from_same_package
          isA<MockMultipartRequest>());
      // ignore: deprecated_member_use_from_same_package
      expect(transport.Request(), isA<MockPlainTextRequest>());
      expect(
          transport.StreamedRequest(),
          // ignore: deprecated_member_use_from_same_package
          isA<MockStreamedRequest>());

      // Properly constructs a mock-aware implementation of WebSocket
      final mockWebSocketServer = MockWebSocketServer();
      MockTransports.webSocket
          .expect(IntegrationPaths.pingUri, connectTo: mockWebSocketServer);
      final webSocket =
          await transport.WebSocket.connect(IntegrationPaths.pingUri);
      expect(webSocket, isA<MockWebSocket>());
      await webSocket.close();
      MockTransports.webSocket
          .expect(IntegrationPaths.pingUri, connectTo: mockWebSocketServer);
      // ignore: deprecated_member_use_from_same_package
      final wSocket = await transport.WSocket.connect(IntegrationPaths.pingUri);
      expect(webSocket, isA<MockWebSocket>());
      await wSocket.close();
      await mockWebSocketServer.shutDown();

      MockTransports.verifyNoOutstandingExceptions();
      await MockTransports.uninstall();
    });

    test('configureWTransportForTest()', () async {
      configureWTransportForTest();

      // Properly constructs mock-aware implementations of HTTP classes
      // ignore: deprecated_member_use_from_same_package
      expect(transport.Client(), isA<MockHttpClient>());
      expect(transport.HttpClient(), isA<MockHttpClient>());
      // ignore: deprecated_member_use_from_same_package
      expect(transport.FormRequest(), isA<MockFormRequest>());
      // ignore: deprecated_member_use_from_same_package
      expect(transport.JsonRequest(), isA<MockJsonRequest>());
      expect(
          transport.MultipartRequest(),
          // ignore: deprecated_member_use_from_same_package
          isA<MockMultipartRequest>());
      // ignore: deprecated_member_use_from_same_package
      expect(transport.Request(), isA<MockPlainTextRequest>());
      expect(
          transport.StreamedRequest(),
          // ignore: deprecated_member_use_from_same_package
          isA<MockStreamedRequest>());

      // Properly constructs a mock-aware implementation of WebSocket
      final mockWebSocketServer = MockWebSocketServer();
      MockTransports.webSocket
          .expect(IntegrationPaths.pingUri, connectTo: mockWebSocketServer);
      final webSocket =
          await transport.WebSocket.connect(IntegrationPaths.pingUri);
      expect(webSocket, isA<MockWebSocket>());
      await webSocket.close();
      MockTransports.webSocket
          .expect(IntegrationPaths.pingUri, connectTo: mockWebSocketServer);
      // ignore: deprecated_member_use_from_same_package
      final wSocket = await transport.WSocket.connect(IntegrationPaths.pingUri);
      expect(webSocket, isA<MockWebSocket>());
      await wSocket.close();
      await mockWebSocketServer.shutDown();

      MockTransports.verifyNoOutstandingExceptions();
      await MockTransports.uninstall();
    });

    test('switching to real requests should fail if no real TP is given',
        () async {
      MockTransports.install(fallThrough: true);

      final formRequest = transport.FormRequest();
      expect(formRequest.get(uri: IntegrationPaths.pingEndpointUri),
          throwsA(isA<transport.TransportPlatformMissing>()));

      final jsonRequest = transport.JsonRequest();
      expect(jsonRequest.get(uri: IntegrationPaths.pingEndpointUri),
          throwsA(isA<transport.TransportPlatformMissing>()));

      final multipartRequest = transport.MultipartRequest()
        ..fields['foo'] = 'bar';
      expect(multipartRequest.get(uri: IntegrationPaths.pingEndpointUri),
          throwsA(isA<transport.TransportPlatformMissing>()));

      final request = transport.Request();
      expect(request.get(uri: IntegrationPaths.pingEndpointUri),
          throwsA(isA<transport.TransportPlatformMissing>()));

      final streamedRequest = transport.StreamedRequest();
      expect(streamedRequest.get(uri: IntegrationPaths.pingEndpointUri),
          throwsA(isA<transport.TransportPlatformMissing>()));

      final requestWithStreamedResponse = transport.Request();
      expect(
          requestWithStreamedResponse.streamGet(
              uri: IntegrationPaths.pingEndpointUri),
          throwsA(isA<transport.TransportPlatformMissing>()));

      final httpClient = transport.HttpClient();

      final clientFormRequest = httpClient.newFormRequest();
      expect(clientFormRequest.get(uri: IntegrationPaths.pingEndpointUri),
          throwsA(isA<transport.TransportPlatformMissing>()));

      final clientJsonRequest = httpClient.newJsonRequest();
      expect(clientJsonRequest.get(uri: IntegrationPaths.pingEndpointUri),
          throwsA(isA<transport.TransportPlatformMissing>()));

      final clientMultipartRequest = httpClient.newMultipartRequest()
        ..fields['foo'] = 'bar';
      expect(clientMultipartRequest.get(uri: IntegrationPaths.pingEndpointUri),
          throwsA(isA<transport.TransportPlatformMissing>()));

      final clientRequest = httpClient.newRequest();
      expect(clientRequest.get(uri: IntegrationPaths.pingEndpointUri),
          throwsA(isA<transport.TransportPlatformMissing>()));

      final clientStreamedRequest = httpClient.newStreamedRequest();
      expect(clientStreamedRequest.get(uri: IntegrationPaths.pingEndpointUri),
          throwsA(isA<transport.TransportPlatformMissing>()));

      final clientRequestWithStreamedResponse = httpClient.newRequest();
      expect(
          clientRequestWithStreamedResponse.streamGet(
              uri: IntegrationPaths.pingEndpointUri),
          throwsA(isA<transport.TransportPlatformMissing>()));

      await MockTransports.uninstall();
    });

    test('switching to a real request should copy over all properties',
        () async {
      MockTransports.install(fallThrough: true);

      Future<Null> requestInterceptor(transport.BaseRequest request) async =>
          null;
      Future<transport.BaseResponse> responseInterceptor(
              FinalizedRequest request, transport.BaseResponse response,
              [transport.RequestException error]) async =>
          null;
      final request = transport.Request(transportPlatform: vmTransportPlatform)
        ..autoRetry.enabled = true
        ..contentType = transport.MediaType('application', 'json')
        ..headers['x-custom'] = 'test'
        ..requestInterceptor = requestInterceptor
        ..responseInterceptor = responseInterceptor
        ..timeoutThreshold = Duration(seconds: 5)
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
          transport.StreamedRequest(transportPlatform: vmTransportPlatform)
            ..contentLength = 10;
      // ignore: avoid_as
      final realStreamedRequest =
          (streamedRequest as MockRequestMixin).switchToRealRequest();
      expect(realStreamedRequest.contentLength, equals(10));

      await MockTransports.uninstall();
    });
  });
}
