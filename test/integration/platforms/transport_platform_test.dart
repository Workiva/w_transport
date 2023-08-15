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

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart' as transport;

import '../../naming.dart';

void main() {
  final naming = Naming()
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
        transport.FormRequest();
      }, throwsA(predicate((dynamic exception) {
        return exception is transport.TransportPlatformMissing &&
            exception.toString().contains(
                'Cannot send FormRequest - Missing Transport Platform');
      })));

      expect(() {
        transport.HttpClient();
      }, throwsA(predicate((dynamic exception) {
        return exception is transport.TransportPlatformMissing &&
            exception.toString().contains(
                'Cannot construct an HTTP Client - Missing Transport Platform');
      })));

      expect(() {
        transport.JsonRequest();
      }, throwsA(predicate((dynamic exception) {
        return exception is transport.TransportPlatformMissing &&
            exception.toString().contains(
                'Cannot send JsonRequest - Missing Transport Platform');
      })));

      expect(() {
        transport.MultipartRequest();
      }, throwsA(predicate((dynamic exception) {
        return exception is transport.TransportPlatformMissing &&
            exception.toString().contains(
                'Cannot send MultipartRequest - Missing Transport Platform');
      })));

      expect(() {
        transport.Request();
      }, throwsA(predicate((dynamic exception) {
        return exception is transport.TransportPlatformMissing &&
            exception
                .toString()
                .contains('Cannot send Request - Missing Transport Platform');
      })));

      expect(() {
        transport.StreamedRequest();
      }, throwsA(predicate((dynamic exception) {
        return exception is transport.TransportPlatformMissing &&
            exception.toString().contains(
                'Cannot send StreamedRequest - Missing Transport Platform');
      })));
    });

    test(
        'establishing a WS connection without a TP throws a TransportPlatformMissing',
        () {
      expect(transport.WebSocket.connect(Uri.parse('/')),
          throwsA(isA<transport.TransportPlatformMissing>()));
    });

    test('constructing any HTTP class without a TP will inherit the global',
        () {
      transport.globalTransportPlatform = stubTransportPlatform;
      expect(transport.FormRequest(), isA<StubFormRequest>());
      expect(transport.HttpClient(), isA<StubHttpClient>());
      expect(transport.JsonRequest(), isA<StubJsonRequest>());
      expect(transport.MultipartRequest(), isA<StubMultipartRequest>());
      expect(transport.Request(), isA<StubRequest>());
      expect(transport.StreamedRequest(), isA<StubStreamedRequest>());
    });

    test('establishing a WS connection without a TP will inherit the global',
        () async {
      transport.globalTransportPlatform = stubTransportPlatform;
      expect(await transport.WebSocket.connect(Uri.parse('/')),
          isA<StubWebSocket>());
    });

    test('constructing any HTTP class with a TP does not throw', () {
      expect(transport.FormRequest(transportPlatform: stubTransportPlatform),
          isA<StubFormRequest>());
      expect(transport.HttpClient(transportPlatform: stubTransportPlatform),
          isA<StubHttpClient>());
      expect(transport.JsonRequest(transportPlatform: stubTransportPlatform),
          isA<StubJsonRequest>());
      expect(
          transport.MultipartRequest(transportPlatform: stubTransportPlatform),
          isA<StubMultipartRequest>());
      expect(transport.Request(transportPlatform: stubTransportPlatform),
          isA<StubRequest>());
      expect(
          transport.StreamedRequest(transportPlatform: stubTransportPlatform),
          isA<StubStreamedRequest>());
    });

    test('establishing a WS connection with a TP does not throw', () async {
      expect(
          await transport.WebSocket.connect(Uri.parse('/'),
              transportPlatform: stubTransportPlatform),
          isA<StubWebSocket>());
    });
  });
}

const StubTransportPlatform stubTransportPlatform = StubTransportPlatform();

class StubTransportPlatform implements transport.TransportPlatform {
  const StubTransportPlatform();

  @override
  transport.HttpClient newHttpClient() => StubHttpClient();

  @override
  Future<transport.WebSocket> newWebSocket(Uri uri,
          {Map<String, dynamic>? headers,
          Iterable<String>? protocols,
          bool? sockJSDebug,
          bool? sockJSNoCredentials,
          List<String>? sockJSProtocolsWhitelist,
          Duration? sockJSTimeout,
          bool? useSockJS}) async =>
      StubWebSocket();

  @override
  transport.StreamedRequest newStreamedRequest() => StubStreamedRequest();

  @override
  transport.Request newRequest() => StubRequest();

  @override
  transport.MultipartRequest newMultipartRequest() => StubMultipartRequest();

  @override
  transport.JsonRequest newJsonRequest() => StubJsonRequest();

  @override
  transport.FormRequest newFormRequest() => StubFormRequest();
}

class StubHttpClient extends Mock implements transport.HttpClient {}

class StubWebSocket extends Mock implements transport.WebSocket {}

class StubStreamedRequest extends Mock implements transport.StreamedRequest {}

class StubRequest extends Mock implements transport.Request {}

class StubMultipartRequest extends Mock implements transport.MultipartRequest {}

class StubJsonRequest extends Mock implements transport.JsonRequest {}

class StubFormRequest extends Mock implements transport.FormRequest {}
