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

@TestOn('vm || browser')
import 'dart:async';

import 'package:test/test.dart';
import 'package:w_transport/mock.dart';
import 'package:w_transport/w_transport.dart' as transport;

import 'package:w_transport/src/mocks/mock_transports.dart'
    show MockWebSocketInternal;
import 'package:w_transport/src/web_socket/mock/web_socket.dart';

import '../../naming.dart';

void main() {
  final naming = Naming()
    ..testType = testTypeUnit
    ..topic = topicMocks;

  group(naming.toString(), () {
    final webSocketUri = Uri.parse('/mock/ws');

    setUp(() {
      MockTransports.install();
    });

    tearDown(() async {
      MockTransports.verifyNoOutstandingExceptions();
      await MockTransports.uninstall();
    });

    test('MockWebSocket extends MockWSocket', () {
      // ignore: deprecated_member_use_from_same_package
      expect(MockWebSocket(), isA<MockWSocket>());
    });

    group('TransportMocks.webSocket', () {
      group('expect()', () {
        test('expected web socket connection completes automatically',
            () async {
          // ignore: deprecated_member_use_from_same_package
          final webSocket = MockWSocket();
          MockTransports.webSocket.expect(webSocketUri, connectTo: webSocket);
          expect(await transport.WebSocket.connect(webSocketUri),
              equals(webSocket));
        });

        test('expected web socket connection rejected', () async {
          MockTransports.webSocket.expect(webSocketUri, reject: true);
          expect(transport.WebSocket.connect(webSocketUri),
              throwsA(predicate((dynamic error) {
            return error.toString().contains('rejected');
          })));
        });

        test('unexpected web socket connection throws', () async {
          expect(transport.WebSocket.connect(webSocketUri),
              throwsA(isA<transport.TransportPlatformMissing>()));
        });

        test('supports connectTo OR reject, but not both', () {
          expect(() {
            MockTransports.webSocket.expect(webSocketUri,
                // ignore: deprecated_member_use_from_same_package
                connectTo: MockWSocket(),
                reject: true);
          }, throwsArgumentError);
        });

        test('requires connectTo OR reject', () {
          expect(() {
            MockTransports.webSocket.expect(webSocketUri);
          }, throwsArgumentError);
        });

        test('requires that connectTo is a MockWSocket or MockWebSocketServer',
            () {
          expect(() {
            MockTransports.webSocket.expect(webSocketUri, connectTo: 'invalid');
          }, throwsArgumentError);
        });
      });

      group('expectPattern()', () {
        test('expected web socket connection completes automatically',
            () async {
          // ignore: deprecated_member_use_from_same_package
          final webSocket = MockWSocket();
          MockTransports.webSocket
              .expectPattern(webSocketUri.toString(), connectTo: webSocket);
          expect(await transport.WebSocket.connect(webSocketUri),
              equals(webSocket));
        });

        test('expected web socket connection rejected', () async {
          MockTransports.webSocket
              .expectPattern(webSocketUri.toString(), reject: true);
          expect(transport.WebSocket.connect(webSocketUri),
              throwsA(predicate((dynamic error) {
            return error.toString().contains('rejected');
          })));
        });

        test('supports connectTo OR reject, but not both', () {
          expect(() {
            MockTransports.webSocket.expectPattern(webSocketUri.toString(),
                // ignore: deprecated_member_use_from_same_package
                connectTo: MockWSocket(),
                reject: true);
          }, throwsArgumentError);
        });

        test('requires connectTo OR reject', () {
          expect(() {
            MockTransports.webSocket.expectPattern(webSocketUri.toString());
          }, throwsArgumentError);
        });

        test('requires that connectTo is a MockWSocket or MockWebSocketServer',
            () {
          expect(() {
            MockTransports.webSocket
                .expectPattern(webSocketUri.toString(), connectTo: 'invalid');
          }, throwsArgumentError);
        });
      });

      test('reset() should clear all expectations and handlers', () async {
        Future<transport.WebSocket> handler(Uri uri,
                {Map<String, dynamic>? headers,
                Iterable<String>? protocols}) async =>
            // ignore: deprecated_member_use_from_same_package
            MockWSocket();
        Future<transport.WebSocket> patternHandler(Uri uri,
                {Map<String, dynamic>? headers,
                Match? match,
                Iterable<String>? protocols}) async =>
            // ignore: deprecated_member_use_from_same_package
            MockWSocket();
        MockTransports.webSocket.when(webSocketUri, handler: handler);
        MockTransports.webSocket
            .whenPattern(webSocketUri.toString(), handler: patternHandler);
        MockTransports.webSocket
            // ignore: deprecated_member_use_from_same_package
            .expect(webSocketUri, connectTo: MockWSocket());
        MockTransports.webSocket.expectPattern(webSocketUri.toString(),
            // ignore: deprecated_member_use_from_same_package
            connectTo: MockWSocket());

        MockTransports.webSocket.reset();

        expect(transport.WebSocket.connect(webSocketUri), throwsA(anything));
      });

      group('when()', () {
        test(
            'registers a handler for all web socket connections with matching URI',
            () async {
          // ignore: deprecated_member_use_from_same_package
          final webSocket = MockWSocket();
          Future<transport.WebSocket> handler(Uri uri,
                  {Map<String, dynamic>? headers,
                  Iterable<String>? protocols}) async =>
              webSocket;
          MockTransports.webSocket.when(webSocketUri, handler: handler);

          // Multiple matching connections succeed.
          expect(await transport.WebSocket.connect(webSocketUri),
              equals(webSocket));
          expect(await transport.WebSocket.connect(webSocketUri),
              equals(webSocket));

          // Non-matching connection fails.
          expect(transport.WebSocket.connect(Uri.parse('/other')),
              throwsA(anything));
        });

        test('registers a rejection for all requests with matching URI',
            () async {
          MockTransports.webSocket.when(webSocketUri, reject: true);

          // Multiple matching connections work as expected.
          expect(transport.WebSocket.connect(webSocketUri),
              throwsA(predicate((dynamic error) {
            return error.toString().contains('rejected');
          })));
          expect(transport.WebSocket.connect(webSocketUri),
              throwsA(predicate((dynamic error) {
            return error.toString().contains('rejected');
          })));

          // Non-matching connection fails correctly.
          expect(transport.WebSocket.connect(Uri.parse('/other')),
              throwsA(isA<transport.TransportPlatformMissing>()));
        });

        test('supports handler OR reject, but not both', () {
          expect(() {
            MockTransports.webSocket.when(webSocketUri,
                // ignore: deprecated_member_use_from_same_package
                handler: (uri, {protocols, headers}) async => MockWSocket(),
                reject: true);
          }, throwsArgumentError);
        });

        test('requires handler OR reject', () {
          expect(() {
            MockTransports.webSocket.when(webSocketUri);
          }, throwsArgumentError);
        });

        test(
            'requires that the handler returns MockWSocket or MockWebSocketServer',
            () {
          MockTransports.webSocket.when(webSocketUri,
              handler: (Uri uri,
                      {Map<String, dynamic>? headers,
                      Iterable<String>? protocols}) async =>
                  'invalid');
          // ignore: deprecated_member_use_from_same_package
          expect(MockWSocket.connect(webSocketUri), throwsArgumentError);
        });

        test('registers a handler that can be canceled', () async {
          // ignore: deprecated_member_use_from_same_package
          final webSocket = MockWSocket();
          final handler = MockTransports.webSocket.when(webSocketUri,
              handler: (uri, {protocols, headers}) async => webSocket);

          expect(await transport.WebSocket.connect(webSocketUri),
              equals(webSocket));
          handler.cancel();
          // ignore: deprecated_member_use_from_same_package
          expect(transport.WebSocket.connect(webSocketUri), throwsStateError);
        });

        test('canceling a handler does nothing if handler no longer exists',
            () async {
          // ignore: deprecated_member_use_from_same_package
          final webSocket = MockWSocket();
          final oldHandler =
              MockTransports.webSocket.when(webSocketUri, reject: true);
          MockTransports.webSocket.when(webSocketUri,
              handler: (uri, {protocols, headers}) async => webSocket);

          expect(() {
            oldHandler.cancel();
          }, returnsNormally);
          expect(await transport.WebSocket.connect(webSocketUri),
              equals(webSocket));
        });

        test('canceling a handler does nothing if handler was reset', () async {
          // ignore: deprecated_member_use_from_same_package
          final webSocket = MockWSocket();
          final oldHandler = MockTransports.webSocket.when(webSocketUri,
              handler: (uri, {protocols, headers}) async => webSocket);
          await MockTransports.reset();

          expect(() {
            oldHandler.cancel();
          }, returnsNormally);

          expect(transport.WebSocket.connect(webSocketUri), throwsStateError);
          await webSocket.close();
        });
      });

      group('whenPattern()', () {
        test(
            'registers a handler for all web socket connections with matching URI',
            () async {
          // ignore: deprecated_member_use_from_same_package
          final webSocket = MockWSocket();
          Future<transport.WebSocket> handler(Uri uri,
                  {Map<String, dynamic>? headers,
                  Match? match,
                  Iterable<String>? protocols}) async =>
              webSocket;
          MockTransports.webSocket
              .whenPattern(webSocketUri.toString(), handler: handler);

          // Multiple matching connections succeed.
          expect(await transport.WebSocket.connect(webSocketUri),
              equals(webSocket));
          expect(await transport.WebSocket.connect(webSocketUri),
              equals(webSocket));

          // Non-matching connection fails.
          expect(transport.WebSocket.connect(Uri.parse('/other')),
              throwsA(anything));
        });

        test('registers a rejection for all requests with matching URI',
            () async {
          MockTransports.webSocket
              .whenPattern(webSocketUri.toString(), reject: true);

          // Multiple matching connections work as expected.
          expect(transport.WebSocket.connect(webSocketUri),
              throwsA(predicate((dynamic error) {
            return error.toString().contains('rejected');
          })));
          expect(transport.WebSocket.connect(webSocketUri),
              throwsA(predicate((dynamic error) {
            return error.toString().contains('rejected');
          })));

          // Non-matching connection fails correctly.
          expect(transport.WebSocket.connect(Uri.parse('/other')),
              throwsA(isA<transport.TransportPlatformMissing>()));
        });

        test('supports handler OR reject, but not both', () {
          expect(() {
            MockTransports.webSocket.whenPattern(webSocketUri.toString(),
                handler: (uri, {protocols, headers, match}) async =>
                    // ignore: deprecated_member_use_from_same_package
                    MockWSocket(),
                reject: true);
          }, throwsArgumentError);
        });

        test('requires handler OR reject', () {
          expect(() {
            MockTransports.webSocket.whenPattern(webSocketUri.toString());
          }, throwsArgumentError);
        });

        test(
            'requires that the handler returns MockWSocket or MockWebSocketServer',
            () {
          MockTransports.webSocket.whenPattern(webSocketUri.toString(),
              handler: (Uri uri,
                      {Map<String, dynamic>? headers,
                      Match? match,
                      Iterable<String>? protocols}) async =>
                  'invalid');
          // ignore:
          expect(
              transport.WebSocket.connect(webSocketUri), throwsArgumentError);
        });

        test(
            'registers a handler with a pattern that catches any connection with a matching URI',
            () async {
          final uriPattern = RegExp('ws:\/\/(google|github)\.com\/ws.*');
          // ignore: deprecated_member_use_from_same_package
          final webSocket = MockWSocket();
          Future<transport.WebSocket> handler(Uri uri,
                  {Map<String, dynamic>? headers,
                  Match? match,
                  Iterable<String>? protocols}) async =>
              webSocket;
          MockTransports.webSocket.whenPattern(uriPattern, handler: handler);

          // Multiple matching connections succeed.
          expect(
              await transport.WebSocket.connect(
                  Uri.parse('ws://google.com/ws')),
              equals(webSocket));
          expect(
              await transport.WebSocket.connect(
                  Uri.parse('ws://github.com/ws/listen')),
              equals(webSocket));

          // Non-matching connection fails.
          expect(transport.WebSocket.connect(Uri.parse('/other')),
              throwsA(anything));
        });

        test(
            'registers a handler that will receive the uri Match on connection',
            () async {
          final uriPattern = RegExp('ws:\/\/(google|github)\.com\/ws.*');
          Match? uriMatch;
          Future<transport.WebSocket> handler(Uri uri,
              {Map<String, dynamic>? headers,
              Match? match,
              Iterable<String>? protocols}) async {
            uriMatch = match;
            // ignore: deprecated_member_use_from_same_package
            return MockWSocket();
          }

          MockTransports.webSocket.whenPattern(uriPattern, handler: handler);

          await transport.WebSocket.connect(
              Uri.parse('ws://github.com/ws/listen'));
          expect(uriMatch!.group(0), equals('ws://github.com/ws/listen'));
          expect(uriMatch!.group(1), equals('github'));
        });

        test('registers a handler that can be canceled', () async {
          // ignore: deprecated_member_use_from_same_package
          final webSocket = MockWSocket();
          final handler = MockTransports.webSocket.whenPattern(
              webSocketUri.toString(),
              handler: (uri, {protocols, headers, match}) async => webSocket);

          expect(await transport.WebSocket.connect(webSocketUri),
              equals(webSocket));
          handler.cancel();
          expect(transport.WebSocket.connect(webSocketUri), throwsStateError);
        });

        test('canceling a handler does nothing if handler no longer exists',
            () async {
          // ignore: deprecated_member_use_from_same_package
          final webSocket = MockWSocket();
          final oldHandler = MockTransports.webSocket
              .whenPattern(webSocketUri.toString(), reject: true);
          MockTransports.webSocket.whenPattern(webSocketUri.toString(),
              handler: (uri, {protocols, headers, match}) async => webSocket);

          expect(() {
            oldHandler.cancel();
          }, returnsNormally);
          expect(await transport.WebSocket.connect(webSocketUri),
              equals(webSocket));
        });

        test('canceling a handler does nothing if handler was reset', () async {
          // ignore: deprecated_member_use_from_same_package
          final webSocket = MockWSocket();
          final oldHandler = MockTransports.webSocket.whenPattern(
              webSocketUri.toString(),
              handler: (uri, {protocols, headers, match}) async => webSocket);
          await MockTransports.reset();

          expect(() {
            oldHandler.cancel();
          }, returnsNormally);

          expect(transport.WebSocket.connect(webSocketUri), throwsStateError);
          await webSocket.close();
        });
      });
    });

    group('MockWebSocketInternal', () {
      group('hasHandlerForWebSocket()', () {
        test('returns true if there is a matching expectation', () async {
          MockTransports.webSocket
              .expect(webSocketUri, connectTo: MockWebSocketServer());
          expect(MockWebSocketInternal.hasHandlerForWebSocket(webSocketUri),
              isTrue);
          await MockTransports.reset();
        });

        test('returns true if there is a matching handler', () async {
          MockTransports.webSocket.when(webSocketUri, reject: true);
          expect(MockWebSocketInternal.hasHandlerForWebSocket(webSocketUri),
              isTrue);
          await MockTransports.reset();
        });

        test('returns false if there are no matching expectations nor handlers',
            () {
          expect(MockWebSocketInternal.hasHandlerForWebSocket(webSocketUri),
              isFalse);
        });
      });
    });

    group('MockWebSocketServer', () {
      test('should expose `done` for connected clients', () async {
        final c = Completer<Null>();
        final mockWebSocketServer = MockWebSocketServer();
        mockWebSocketServer.onClientConnected.listen((connection) {
          connection.done.then(((_) => c.complete()) as FutureOr<_> Function(Null));
        });

        MockTransports.webSocket
            .expect(webSocketUri, connectTo: mockWebSocketServer);
        final webSocket = await (transport.WebSocket.connect(webSocketUri) as FutureOr<WebSocket>);
        await webSocket.close();
        await c.future;
      });
    });
  });
}
