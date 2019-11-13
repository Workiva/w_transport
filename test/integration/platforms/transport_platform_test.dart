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
import 'package:w_transport/w_transport.dart' as transport;

import '../../naming.dart';

void main() {
  final naming = new Naming()
    ..testType = testTypeIntegration
    ..topic = topicTransportPlatform;

  group(naming.toString(), () {
    tearDown(() {
      transport.resetGlobalTransportPlatform();
    });

    test('no global TP by default', () {
      expect(transport.globalTransportPlatform, isNull);
    });

    test('global TP can be set', () {
      transport.globalTransportPlatform = stubTransportPlatform;
      expect(transport.globalTransportPlatform, equals(stubTransportPlatform));
    });

    test('global TP cannot be set to null', () {
      expect(() {
        transport.globalTransportPlatform = null;
      }, throwsArgumentError);
    });

    test(
        'constructing any HTTP class without a TP throws a TransportPlatformMissing',
        () {
      expect(() {
        new transport.FormRequest();
      }, throwsA(predicate((exception) {
        return exception is transport.TransportPlatformMissing &&
            exception.toString().contains(
                'Cannot send FormRequest - Missing Transport Platform');
      })));

      expect(() {
        new transport.HttpClient();
      }, throwsA(predicate((exception) {
        return exception is transport.TransportPlatformMissing &&
            exception.toString().contains(
                'Cannot construct an HTTP Client - Missing Transport Platform');
      })));

      expect(() {
        new transport.JsonRequest();
      }, throwsA(predicate((exception) {
        return exception is transport.TransportPlatformMissing &&
            exception.toString().contains(
                'Cannot send JsonRequest - Missing Transport Platform');
      })));

      expect(() {
        new transport.MultipartRequest();
      }, throwsA(predicate((exception) {
        return exception is transport.TransportPlatformMissing &&
            exception.toString().contains(
                'Cannot send MultipartRequest - Missing Transport Platform');
      })));

      expect(() {
        new transport.Request();
      }, throwsA(predicate((exception) {
        return exception is transport.TransportPlatformMissing &&
            exception
                .toString()
                .contains('Cannot send Request - Missing Transport Platform');
      })));

      expect(() {
        new transport.StreamedRequest();
      }, throwsA(predicate((exception) {
        return exception is transport.TransportPlatformMissing &&
            exception.toString().contains(
                'Cannot send StreamedRequest - Missing Transport Platform');
      })));
    });

    test(
        'establishing a WS connection without a TP throws a TransportPlatformMissing',
        () {
      expect(transport.WebSocket.connect(Uri.parse('/')),
          throwsA(new isInstanceOf<transport.TransportPlatformMissing>()));
    });

    test('constructing any HTTP class without a TP will inherit the global',
        () {
      transport.globalTransportPlatform = stubTransportPlatform;

      // All of these should be null because the stub TP only returns null.
      expect(new transport.FormRequest(), isNull);
      expect(new transport.HttpClient(), isNull);
      expect(new transport.JsonRequest(), isNull);
      expect(new transport.MultipartRequest(), isNull);
      expect(new transport.Request(), isNull);
      expect(new transport.StreamedRequest(), isNull);
    });

    test('establishing a WS connection without a TP will inherit the global',
        () async {
      transport.globalTransportPlatform = stubTransportPlatform;

      // The connected WS should be null because the stub TP returns null.
      expect(await transport.WebSocket.connect(Uri.parse('/')), isNull);
    });

    test('constructing any HTTP class with a TP does not throw', () {
      // All of these should be null because the stub TP only returns null.
      expect(
          new transport.FormRequest(transportPlatform: stubTransportPlatform),
          isNull);
      expect(new transport.HttpClient(transportPlatform: stubTransportPlatform),
          isNull);
      expect(
          new transport.JsonRequest(transportPlatform: stubTransportPlatform),
          isNull);
      expect(
          new transport.MultipartRequest(
              transportPlatform: stubTransportPlatform),
          isNull);
      expect(new transport.Request(transportPlatform: stubTransportPlatform),
          isNull);
      expect(
          new transport.StreamedRequest(
              transportPlatform: stubTransportPlatform),
          isNull);
    });

    test('establishing a WS connection with a TP does not throw', () async {
      // The connected WS should be null because the stub TP returns null.
      expect(
          await transport.WebSocket.connect(Uri.parse('/'),
              transportPlatform: stubTransportPlatform),
          isNull);
    });
  });
}

const StubTransportPlatform stubTransportPlatform = StubTransportPlatform();

class StubTransportPlatform implements transport.TransportPlatform {
  const StubTransportPlatform();

  @override
  transport.HttpClient newHttpClient() => null;

  @override
  Future<transport.WebSocket> newWebSocket(Uri uri,
          {Map<String, dynamic> headers,
          Iterable<String> protocols,
          bool sockJSDebug,
          bool sockJSNoCredentials,
          List<String> sockJSProtocolsWhitelist,
          Duration sockJSTimeout,
          bool useSockJS}) async =>
      null;

  @override
  transport.StreamedRequest newStreamedRequest() => null;

  @override
  transport.Request newRequest() => null;

  @override
  transport.MultipartRequest newMultipartRequest() => null;

  @override
  transport.JsonRequest newJsonRequest() => null;

  @override
  transport.FormRequest newFormRequest() => null;
}
