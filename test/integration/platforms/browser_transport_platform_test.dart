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

@TestOn('browser')
import 'dart:async';
import 'dart:html' as html;

import 'package:pedantic/pedantic.dart';
import 'package:test/test.dart';
import 'package:w_transport/browser.dart';
import 'package:w_transport/mock.dart';
import 'package:w_transport/w_transport.dart' as transport;

import 'package:w_transport/src/http/browser/http_client.dart';
import 'package:w_transport/src/http/browser/requests.dart';
import 'package:w_transport/src/web_socket/browser/sockjs_wrapper.dart';
import 'package:w_transport/src/web_socket/browser/web_socket.dart';

import '../../naming.dart';
import '../integration_paths.dart';

const int sockjsPort = 8026;

void main() {
  final naming = Naming()
    ..platform = platformBrowser
    ..testType = testTypeIntegration
    ..topic = topicTransportPlatform;

  group(naming.toString(), () {
    tearDown(() {
      transport.resetGlobalTransportPlatform();
    });

    test('globalTransportPlatform = browserTransportPlatform', () async {
      transport.globalTransportPlatform = browserTransportPlatform;

      // Properly constructs browser implementations of HTTP classes
      expect(transport.HttpClient(), isA<BrowserHttpClient>());
      expect(transport.FormRequest(), isA<BrowserFormRequest>());
      expect(transport.JsonRequest(), isA<BrowserJsonRequest>());
      expect(transport.MultipartRequest(), isA<BrowserMultipartRequest>());
      expect(transport.Request(), isA<BrowserPlainTextRequest>());
      expect(transport.StreamedRequest(), isA<BrowserStreamedRequest>());

      // Properly constructs browser implementation of WebSocket
      final webSocket =
          await transport.WebSocket.connect(IntegrationPaths.pingUri);
      expect(webSocket, isA<BrowserWebSocket>());
      await webSocket.close();
      final wSocket =
          await transport.WebSocket.connect(IntegrationPaths.pingUri);
      expect(wSocket, isA<BrowserWebSocket>());
      await wSocket.close();
    });

    test('globalTransportPlatform = browserTransportPlatformWithSockJS',
        () async {
      transport.globalTransportPlatform = browserTransportPlatformWithSockJS;

      BrowserTransportPlatformWithSockJS btpwsj =
          transport.globalTransportPlatform;
      expect(btpwsj.sockJSDebug, isFalse);
      expect(btpwsj.sockJSNoCredentials, isFalse);
      expect(btpwsj.sockJSProtocolsWhitelist, isNull);
      expect(btpwsj.sockJSTimeout, isNull);

      final pingUri = IntegrationPaths.pingUri.replace(port: sockjsPort);

      // Properly constructs SockJS implementation of WebSocket
      final webSocket = await transport.WebSocket.connect(pingUri);
      expect(webSocket, isA<SockJSWrapperWebSocket>());
      await webSocket.close();
      final wSocket = await transport.WebSocket.connect(pingUri);
      expect(wSocket, isA<SockJSWrapperWebSocket>());
      await wSocket.close();
    });

    test('globalTransportPlatform = custom BrowserTransportPlatformWithSockJS',
        () async {
      transport.globalTransportPlatform = BrowserTransportPlatformWithSockJS(
          sockJSDebug: true,
          sockJSNoCredentials: false,
          sockJSProtocolsWhitelist: ['websocket', 'xhr-streaming'],
          sockJSTimeout: Duration(seconds: 1));

      BrowserTransportPlatformWithSockJS btpwsj =
          transport.globalTransportPlatform;
      expect(btpwsj.sockJSDebug, isTrue);
      expect(btpwsj.sockJSNoCredentials, isFalse);
      expect(btpwsj.sockJSProtocolsWhitelist,
          unorderedEquals(['websocket', 'xhr-streaming']));
      expect(btpwsj.sockJSTimeout?.inSeconds, equals(1));

      final pingUri = IntegrationPaths.pingUri.replace(port: sockjsPort);

      // Properly constructs SockJS implementation of WebSocket
      final webSocket = await transport.WebSocket.connect(pingUri);
      expect(webSocket, isA<SockJSWrapperWebSocket>());
      await webSocket.close();
      final wSocket = await transport.WebSocket.connect(pingUri);
      expect(wSocket, isA<SockJSWrapperWebSocket>());
      await wSocket.close();
    });

    test(
        'globalTransportPlatform = BrowserTransportPlatformWithSockJS, connect with override',
        () async {
      transport.globalTransportPlatform = browserTransportPlatformWithSockJS;

      // Properly constructs Browser implementation of WebSocket
      final webSocket = await transport.WebSocket.connect(
          IntegrationPaths.pingUri,
          transportPlatform: browserTransportPlatform);
      expect(webSocket, isA<BrowserWebSocket>());
      await webSocket.close();
      final wSocket = await transport.WebSocket.connect(
          IntegrationPaths.pingUri,
          transportPlatform: browserTransportPlatform);
      expect(wSocket, isA<BrowserWebSocket>());
      await wSocket.close();
    });

    test('configureWTransportForBrowser()', () async {
      configureWTransportForBrowser();

      // Properly constructs browser implementations of HTTP classes
      expect(transport.HttpClient(), isA<BrowserHttpClient>());
      expect(transport.FormRequest(), isA<BrowserFormRequest>());
      expect(transport.JsonRequest(), isA<BrowserJsonRequest>());
      expect(transport.MultipartRequest(), isA<BrowserMultipartRequest>());
      expect(transport.Request(), isA<BrowserPlainTextRequest>());
      expect(transport.StreamedRequest(), isA<BrowserStreamedRequest>());

      // Properly constructs browser implementation of WebSocket
      final webSocket =
          await transport.WebSocket.connect(IntegrationPaths.pingUri);
      expect(webSocket, isA<BrowserWebSocket>());
      await webSocket.close();
      final wSocket =
          await transport.WebSocket.connect(IntegrationPaths.pingUri);
      expect(wSocket, isA<BrowserWebSocket>());
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
          final formRequest = transport.FormRequest(
              transportPlatform: browserTransportPlatform);
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await formRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final jsonRequest = transport.JsonRequest(
              transportPlatform: browserTransportPlatform);
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await jsonRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final multipartRequest = transport.MultipartRequest(
              transportPlatform: browserTransportPlatform)
            ..fields['foo'] = 'bar';
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await multipartRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final request =
              transport.Request(transportPlatform: browserTransportPlatform);
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await request.get(uri: IntegrationPaths.pingEndpointUri);

          final streamedRequest = transport.StreamedRequest(
              transportPlatform: browserTransportPlatform);
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await streamedRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final requestWithStreamedResponse =
              transport.Request(transportPlatform: browserTransportPlatform);
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await requestWithStreamedResponse.streamGet(
              uri: IntegrationPaths.pingEndpointUri);

          final httpClient =
              transport.HttpClient(transportPlatform: browserTransportPlatform);

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

          final formRequest = transport.FormRequest(
              transportPlatform: browserTransportPlatform);
          await formRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final jsonRequest = transport.JsonRequest(
              transportPlatform: browserTransportPlatform);
          await jsonRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final multipartRequest = transport.MultipartRequest(
              transportPlatform: browserTransportPlatform)
            ..fields['foo'] = 'bar';
          await multipartRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final request =
              transport.Request(transportPlatform: browserTransportPlatform);
          await request.get(uri: IntegrationPaths.pingEndpointUri);

          final streamedRequest = transport.StreamedRequest(
              transportPlatform: browserTransportPlatform);
          await streamedRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final requestWithStreamedResponse =
              transport.Request(transportPlatform: browserTransportPlatform);
          await requestWithStreamedResponse.streamGet(
              uri: IntegrationPaths.pingEndpointUri);

          final httpClient =
              transport.HttpClient(transportPlatform: browserTransportPlatform);

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
              transportPlatform: browserTransportPlatform);
          await webSocket.close();

          MockTransports.webSocket
              .expect(IntegrationPaths.pingUri, connectTo: mockWebSocketServer);
          final sockJS = await transport.WebSocket.connect(
              IntegrationPaths.pingUri,
              transportPlatform: browserTransportPlatformWithSockJS);
          await sockJS.close();

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
              transportPlatform: browserTransportPlatform);
          await webSocket.close();

          final sockJS = await transport.WebSocket.connect(
              IntegrationPaths.pingUri,
              transportPlatform: browserTransportPlatformWithSockJS);
          await sockJS.close();

          await mockWebSocketServer.shutDown();
        });

        test('requests without expectation or handler should be pending',
            () async {
          final formRequest = transport.FormRequest(
              transportPlatform: browserTransportPlatform);
          unawaited(formRequest.get(uri: IntegrationPaths.pingEndpointUri));

          final jsonRequest = transport.JsonRequest(
              transportPlatform: browserTransportPlatform);
          unawaited(jsonRequest.get(uri: IntegrationPaths.pingEndpointUri));

          final multipartRequest = transport.MultipartRequest(
              transportPlatform: browserTransportPlatform)
            ..fields['foo'] = 'bar';
          unawaited(
              multipartRequest.get(uri: IntegrationPaths.pingEndpointUri));

          final request =
              transport.Request(transportPlatform: browserTransportPlatform);
          unawaited(request.get(uri: IntegrationPaths.pingEndpointUri));

          final streamedRequest = transport.StreamedRequest(
              transportPlatform: browserTransportPlatform);
          unawaited(streamedRequest.get(uri: IntegrationPaths.pingEndpointUri));

          final requestWithStreamedResponse =
              transport.Request(transportPlatform: browserTransportPlatform);
          unawaited(requestWithStreamedResponse.streamGet(
              uri: IntegrationPaths.pingEndpointUri));

          final httpClient =
              transport.HttpClient(transportPlatform: browserTransportPlatform);

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
                  transportPlatform: browserTransportPlatform),
              throwsStateError);

          final pingUri = IntegrationPaths.pingUri.replace(port: sockjsPort);
          expect(
              transport.WebSocket.connect(pingUri,
                  transportPlatform: browserTransportPlatformWithSockJS),
              throwsStateError);
        });
      });

      group('fallThrough: true', () {
        setUp(() {
          MockTransports.install(fallThrough: true);
        });

        test('requests with matching expectation should be handled', () async {
          final formRequest = transport.FormRequest(
              transportPlatform: browserTransportPlatform);
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await formRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final jsonRequest = transport.JsonRequest(
              transportPlatform: browserTransportPlatform);
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await jsonRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final multipartRequest = transport.MultipartRequest(
              transportPlatform: browserTransportPlatform)
            ..fields['foo'] = 'bar';
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await multipartRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final request =
              transport.Request(transportPlatform: browserTransportPlatform);
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await request.get(uri: IntegrationPaths.pingEndpointUri);

          final streamedRequest = transport.StreamedRequest(
              transportPlatform: browserTransportPlatform);
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await streamedRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final requestWithStreamedResponse =
              transport.Request(transportPlatform: browserTransportPlatform);
          MockTransports.http.expect('GET', IntegrationPaths.pingEndpointUri);
          await requestWithStreamedResponse.streamGet(
              uri: IntegrationPaths.pingEndpointUri);

          final httpClient =
              transport.HttpClient(transportPlatform: browserTransportPlatform);

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

          final formRequest = transport.FormRequest(
              transportPlatform: browserTransportPlatform);
          await formRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final jsonRequest = transport.JsonRequest(
              transportPlatform: browserTransportPlatform);
          await jsonRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final multipartRequest = transport.MultipartRequest(
              transportPlatform: browserTransportPlatform)
            ..fields['foo'] = 'bar';
          await multipartRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final request =
              transport.Request(transportPlatform: browserTransportPlatform);
          await request.get(uri: IntegrationPaths.pingEndpointUri);

          final streamedRequest = transport.StreamedRequest(
              transportPlatform: browserTransportPlatform);
          await streamedRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final requestWithStreamedResponse =
              transport.Request(transportPlatform: browserTransportPlatform);
          await requestWithStreamedResponse.streamGet(
              uri: IntegrationPaths.pingEndpointUri);

          final httpClient =
              transport.HttpClient(transportPlatform: browserTransportPlatform);

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
              transportPlatform: browserTransportPlatform);
          await webSocket.close();

          MockTransports.webSocket
              .expect(IntegrationPaths.pingUri, connectTo: mockWebSocketServer);
          final sockJS = await transport.WebSocket.connect(
              IntegrationPaths.pingUri,
              transportPlatform: browserTransportPlatformWithSockJS);
          await sockJS.close();

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
              transportPlatform: browserTransportPlatform);
          await webSocket.close();

          final sockJS = await transport.WebSocket.connect(
              IntegrationPaths.pingUri,
              transportPlatform: browserTransportPlatformWithSockJS);
          await sockJS.close();

          await mockWebSocketServer.shutDown();
        });

        test(
            'requests without expectation or handler should switch to real request',
            () async {
          final formRequest = transport.FormRequest(
              transportPlatform: browserTransportPlatform);
          await formRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final jsonRequest = transport.JsonRequest(
              transportPlatform: browserTransportPlatform);
          await jsonRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final multipartRequest = transport.MultipartRequest(
              transportPlatform: browserTransportPlatform)
            ..fields['foo'] = 'bar'
            ..files['blob'] = html.Blob([]);
          await multipartRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final request =
              transport.Request(transportPlatform: browserTransportPlatform);
          await request.get(uri: IntegrationPaths.pingEndpointUri);

          final streamedRequest = transport.StreamedRequest(
              transportPlatform: browserTransportPlatform);
          await streamedRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final requestWithStreamedResponse =
              transport.Request(transportPlatform: browserTransportPlatform);
          await requestWithStreamedResponse.streamGet(
              uri: IntegrationPaths.pingEndpointUri);

          final httpClient =
              transport.HttpClient(transportPlatform: browserTransportPlatform);

          final clientFormRequest = httpClient.newFormRequest();
          await clientFormRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final clientJsonRequest = httpClient.newJsonRequest();
          await clientJsonRequest.get(uri: IntegrationPaths.pingEndpointUri);

          final clientMultipartRequest = httpClient.newMultipartRequest()
            ..fields['foo'] = 'bar'
            ..files['blob'] = html.Blob([]);
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
              transportPlatform: browserTransportPlatform);
          expect(webSocket, isA<BrowserWebSocket>());
          await webSocket.close();

          final pingUri = IntegrationPaths.pingUri.replace(port: sockjsPort);
          final sockJS = await transport.WebSocket.connect(pingUri,
              transportPlatform: browserTransportPlatformWithSockJS);
          expect(sockJS, isA<SockJSWrapperWebSocket>());
          await sockJS.close();
        });
      });
    });
  });
}
