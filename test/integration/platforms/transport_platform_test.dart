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
import 'package:w_transport/w_transport.dart';

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
        // All of these should throw a TransportPlatformMissing exception.
        expect(() => transport.FormRequest(), throwsA(isA<transport.TransportPlatformMissing>()));
        expect(() => transport.HttpClient(), throwsA(isA<transport.TransportPlatformMissing>()));
        expect(() => transport.JsonRequest(), throwsA(isA<transport.TransportPlatformMissing>()));
        expect(() => transport.MultipartRequest(), throwsA(isA<transport.TransportPlatformMissing>()));
        expect(() => transport.Request(), throwsA(isA<transport.TransportPlatformMissing>()));
        expect(() => transport.StreamedRequest(), throwsA(isA<transport.TransportPlatformMissing>()));
    });

    test('establishing a WS connection without a TP will inherit the global',
        () async {
      transport.globalTransportPlatform = stubTransportPlatform;

      // The connected WS should be null because the stub TP returns null.
      expect(await transport.WebSocket.connect(Uri.parse('/')), isNull);
    });

    test('constructing any HTTP class with a TP does not throw', () {
      expect(
          () => transport.FormRequest(transportPlatform: stubTransportPlatform),
          throwsA(isA<TransportPlatformMissing>()));
      expect(
          () => transport.HttpClient(transportPlatform: stubTransportPlatform),
          throwsA(isA<TransportPlatformMissing>()));
      expect(
          () => transport.JsonRequest(transportPlatform: stubTransportPlatform),
          throwsA(isA<TransportPlatformMissing>()));
      expect(
          () => transport.MultipartRequest(
              transportPlatform: stubTransportPlatform),
          throwsA(isA<TransportPlatformMissing>()));
      expect(() => transport.Request(transportPlatform: stubTransportPlatform),
          throwsA(isA<TransportPlatformMissing>()));
      expect(
          () => transport.StreamedRequest(
              transportPlatform: stubTransportPlatform),
          throwsA(isA<TransportPlatformMissing>()));
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
  transport.HttpClient? newHttpClient() => null;

  @override
  Future<transport.WebSocket?> newWebSocket(Uri uri,
          {Map<String, dynamic>? headers,
          Iterable<String>? protocols,
          bool? sockJSDebug,
          bool? sockJSNoCredentials,
          List<String>? sockJSProtocolsWhitelist,
          Duration? sockJSTimeout,
          bool? useSockJS}) async =>
      null;

  @override
  transport.StreamedRequest? newStreamedRequest() => null;

  @override
  transport.Request? newRequest() => null;

  @override
  transport.MultipartRequest? newMultipartRequest() => null;

  @override
  transport.JsonRequest? newJsonRequest() => null;

  @override
  transport.FormRequest? newFormRequest() => null;
}
