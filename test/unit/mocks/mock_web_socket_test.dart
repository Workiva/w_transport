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
library w_transport.test.unit.mocks.mock_web_socket_test;

import 'dart:async';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_mock.dart';

import '../../naming.dart';

void main() {
  Naming naming = new Naming()
    ..testType = testTypeUnit
    ..topic = topicMocks;

  group(naming.toString(), () {
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

      test('reset() should clear all expectations and handlers', () async {
        Future<WSocket> handler(uri, {protocols, headers}) async =>
            new MockWSocket();
        MockTransports.webSocket.when(webSocketUri, handler: handler);
        MockTransports.webSocket
            .expect(webSocketUri, connectTo: new MockWSocket());

        MockTransports.webSocket.reset();

        expect(WSocket.connect(webSocketUri), throws);
      });

      group('when()', () {
        test(
            'registers a handler for all web socket connections with matching URI',
            () async {
          WSocket webSocket = new MockWSocket();
          Future<WSocket> handler(uri, {protocols, headers}) async => webSocket;
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
      });
    });
  });
}
