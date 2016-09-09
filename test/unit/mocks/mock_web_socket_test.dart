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
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/mock.dart';

import 'package:w_transport/src/web_socket/mock/web_socket.dart';

import '../../naming.dart';

void main() {
  Naming naming = new Naming()
    ..testType = testTypeUnit
    ..topic = topicMocks;

  group(naming.toString(), () {
    test('MockWebSocket extends MockWSocket', () {
      expect(new MockWebSocket(), new isInstanceOf<MockWSocket>());
    });

    group('TransportMocks.webSocket', () {
      Uri webSocketUri = Uri.parse('/mock/ws');

      setUp(() {
        configureWTransportForTest();
        MockTransports.reset();
      });

      group('expect()', () {
        test('expected web socket connection completes automatically',
            () async {
          WSocket webSocket = new MockWSocket();
          MockTransports.webSocket.expect(webSocketUri, connectTo: webSocket);
          expect(await WSocket.connect(webSocketUri), equals(webSocket));
        });

        test('expected web socket connection rejected', () async {
          MockTransports.webSocket.expect(webSocketUri, reject: true);
          expect(WSocket.connect(webSocketUri), throwsA(predicate((error) {
            return error.toString().contains('rejected');
          })));
        });

        test('unexpected web socket connection throws', () async {
          expect(WSocket.connect(webSocketUri), throwsA(predicate((error) {
            return error.toString().contains('Unexpected');
          })));
        });

        test('supports connectTo OR reject, but not both', () {
          expect(() {
            MockTransports.webSocket.expect(webSocketUri,
                connectTo: new MockWSocket(), reject: true);
          }, throwsArgumentError);
        });

        test('requires connectTo OR reject', () {
          expect(() {
            MockTransports.webSocket.expect(webSocketUri);
          }, throwsArgumentError);
        });
      });

      group('expectPattern()', () {
        test('expected web socket connection completes automatically',
            () async {
          WSocket webSocket = new MockWSocket();
          MockTransports.webSocket
              .expectPattern(webSocketUri.toString(), connectTo: webSocket);
          expect(await WSocket.connect(webSocketUri), equals(webSocket));
        });

        test('expected web socket connection rejected', () async {
          MockTransports.webSocket
              .expectPattern(webSocketUri.toString(), reject: true);
          expect(WSocket.connect(webSocketUri), throwsA(predicate((error) {
            return error.toString().contains('rejected');
          })));
        });

        test('supports connectTo OR reject, but not both', () {
          expect(() {
            MockTransports.webSocket.expectPattern(webSocketUri.toString(),
                connectTo: new MockWSocket(), reject: true);
          }, throwsArgumentError);
        });

        test('requires connectTo OR reject', () {
          expect(() {
            MockTransports.webSocket.expectPattern(webSocketUri.toString());
          }, throwsArgumentError);
        });
      });

      test('reset() should clear all expectations and handlers', () async {
        Future<WSocket> handler(Uri uri,
                {Iterable<String> protocols,
                Map<String, dynamic> headers}) async =>
            new MockWSocket();
        Future<WSocket> patternHandler(Uri uri,
                {Iterable<String> protocols,
                Map<String, dynamic> headers,
                Match match}) async =>
            new MockWSocket();
        MockTransports.webSocket.when(webSocketUri, handler: handler);
        MockTransports.webSocket
            .whenPattern(webSocketUri.toString(), handler: patternHandler);
        MockTransports.webSocket
            .expect(webSocketUri, connectTo: new MockWSocket());
        MockTransports.webSocket.expectPattern(webSocketUri.toString(),
            connectTo: new MockWSocket());

        MockTransports.webSocket.reset();

        expect(WSocket.connect(webSocketUri), throws);
      });

      group('when()', () {
        test(
            'registers a handler for all web socket connections with matching URI',
            () async {
          WSocket webSocket = new MockWSocket();
          Future<WSocket> handler(Uri uri,
                  {Iterable<String> protocols,
                  Map<String, dynamic> headers}) async =>
              webSocket;
          MockTransports.webSocket.when(webSocketUri, handler: handler);

          // Multiple matching connections succeed.
          expect(await WSocket.connect(webSocketUri), equals(webSocket));
          expect(await WSocket.connect(webSocketUri), equals(webSocket));

          // Non-matching connection fails.
          expect(WSocket.connect(Uri.parse('/other')), throws);
        });

        test('registers a rejection for all requests with matching URI',
            () async {
          MockTransports.webSocket.when(webSocketUri, reject: true);

          // Multiple matching connections work as expected.
          expect(WSocket.connect(webSocketUri), throwsA(predicate((error) {
            return error.toString().contains('rejected');
          })));
          expect(WSocket.connect(webSocketUri), throwsA(predicate((error) {
            return error.toString().contains('rejected');
          })));

          // Non-matching connection fails correctly.
          expect(WSocket.connect(Uri.parse('/other')),
              throwsA(predicate((error) {
            return error.toString().contains('Unexpected');
          })));
        });

        test('supports handler OR reject, but not both', () {
          expect(() {
            MockTransports.webSocket.when(webSocketUri,
                handler: (uri, {protocols, headers}) async => new MockWSocket(),
                reject: true);
          }, throwsArgumentError);
        });

        test('requires handler OR reject', () {
          expect(() {
            MockTransports.webSocket.when(webSocketUri);
          }, throwsArgumentError);
        });

        test('registers a handler that can be canceled', () async {
          var webSocket = new MockWSocket();
          var handler = MockTransports.webSocket.when(webSocketUri,
              handler: (uri, {protocols, headers}) async => webSocket);

          expect(await WSocket.connect(webSocketUri), equals(webSocket));
          handler.cancel();
          expect(WSocket.connect(webSocketUri), throwsStateError);
        });

        test('canceling a handler does nothing if handler no longer exists',
            () async {
          var webSocket = new MockWSocket();
          var oldHandler =
              MockTransports.webSocket.when(webSocketUri, reject: true);
          MockTransports.webSocket.when(webSocketUri,
              handler: (uri, {protocols, headers}) async => webSocket);

          expect(() {
            oldHandler.cancel();
          }, returnsNormally);
          expect(await WSocket.connect(webSocketUri), equals(webSocket));
        });

        test('canceling a handler does nothing if handler was reset', () async {
          var webSocket = new MockWSocket();
          var oldHandler = MockTransports.webSocket.when(webSocketUri,
              handler: (uri, {protocols, headers}) async => webSocket);
          MockTransports.reset();

          expect(() {
            oldHandler.cancel();
          }, returnsNormally);

          expect(WSocket.connect(webSocketUri), throwsStateError);
        });
      });

      group('whenPattern()', () {
        test(
            'registers a handler for all web socket connections with matching URI',
            () async {
          WSocket webSocket = new MockWSocket();
          Future<WSocket> handler(Uri uri,
                  {Iterable<String> protocols,
                  Map<String, dynamic> headers,
                  Match match}) async =>
              webSocket;
          MockTransports.webSocket
              .whenPattern(webSocketUri.toString(), handler: handler);

          // Multiple matching connections succeed.
          expect(await WSocket.connect(webSocketUri), equals(webSocket));
          expect(await WSocket.connect(webSocketUri), equals(webSocket));

          // Non-matching connection fails.
          expect(WSocket.connect(Uri.parse('/other')), throws);
        });

        test('registers a rejection for all requests with matching URI',
            () async {
          MockTransports.webSocket
              .whenPattern(webSocketUri.toString(), reject: true);

          // Multiple matching connections work as expected.
          expect(WSocket.connect(webSocketUri), throwsA(predicate((error) {
            return error.toString().contains('rejected');
          })));
          expect(WSocket.connect(webSocketUri), throwsA(predicate((error) {
            return error.toString().contains('rejected');
          })));

          // Non-matching connection fails correctly.
          expect(WSocket.connect(Uri.parse('/other')),
              throwsA(predicate((error) {
            return error.toString().contains('Unexpected');
          })));
        });

        test('supports handler OR reject, but not both', () {
          expect(() {
            MockTransports.webSocket.whenPattern(webSocketUri.toString(),
                handler: (uri, {protocols, headers, match}) async =>
                    new MockWSocket(),
                reject: true);
          }, throwsArgumentError);
        });

        test('requires handler OR reject', () {
          expect(() {
            MockTransports.webSocket.whenPattern(webSocketUri.toString());
          }, throwsArgumentError);
        });

        test(
            'registers a handler with a pattern that catches any connection with a matching URI',
            () async {
          var uriPattern = new RegExp('ws:\/\/(google|github)\.com\/ws.*');
          WSocket webSocket = new MockWSocket();
          Future<WSocket> handler(Uri uri,
                  {Iterable<String> protocols,
                  Map<String, dynamic> headers,
                  Match match}) async =>
              webSocket;
          MockTransports.webSocket.whenPattern(uriPattern, handler: handler);

          // Multiple matching connections succeed.
          expect(await WSocket.connect(Uri.parse('ws://google.com/ws')),
              equals(webSocket));
          expect(await WSocket.connect(Uri.parse('ws://github.com/ws/listen')),
              equals(webSocket));

          // Non-matching connection fails.
          expect(WSocket.connect(Uri.parse('/other')), throws);
        });

        test(
            'registers a handler that will receive the uri Match on connection',
            () async {
          var uriPattern = new RegExp('ws:\/\/(google|github)\.com\/ws.*');
          Match uriMatch;
          Future<WSocket> handler(Uri uri,
              {Iterable<String> protocols,
              Map<String, dynamic> headers,
              Match match}) async {
            uriMatch = match;
            return new MockWSocket();
          }

          MockTransports.webSocket.whenPattern(uriPattern, handler: handler);

          await WSocket.connect(Uri.parse('ws://github.com/ws/listen'));
          expect(uriMatch.group(0), equals('ws://github.com/ws/listen'));
          expect(uriMatch.group(1), equals('github'));
        });

        test('registers a handler that can be canceled', () async {
          var webSocket = new MockWSocket();
          var handler = MockTransports.webSocket.whenPattern(
              webSocketUri.toString(),
              handler: (uri, {protocols, headers, match}) async => webSocket);

          expect(await WSocket.connect(webSocketUri), equals(webSocket));
          handler.cancel();
          expect(WSocket.connect(webSocketUri), throwsStateError);
        });

        test('canceling a handler does nothing if handler no longer exists',
            () async {
          var webSocket = new MockWSocket();
          var oldHandler = MockTransports.webSocket
              .whenPattern(webSocketUri.toString(), reject: true);
          MockTransports.webSocket.whenPattern(webSocketUri.toString(),
              handler: (uri, {protocols, headers, match}) async => webSocket);

          expect(() {
            oldHandler.cancel();
          }, returnsNormally);
          expect(await WSocket.connect(webSocketUri), equals(webSocket));
        });

        test('canceling a handler does nothing if handler was reset', () async {
          var webSocket = new MockWSocket();
          var oldHandler = MockTransports.webSocket.whenPattern(
              webSocketUri.toString(),
              handler: (uri, {protocols, headers, match}) async => webSocket);
          MockTransports.reset();

          expect(() {
            oldHandler.cancel();
          }, returnsNormally);

          expect(WSocket.connect(webSocketUri), throwsStateError);
        });
      });
    });
  });
}
