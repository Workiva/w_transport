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

@TestOn('browser || vm')
import 'dart:async';
import 'dart:typed_data';

import 'package:http_parser/http_parser.dart';
import 'package:test/test.dart';
import 'package:w_transport/mock.dart';
import 'package:w_transport/w_transport.dart' as transport;

import '../../naming.dart';

void main() {
  final naming = Naming()
    ..testType = testTypeUnit
    ..topic = topicHttp;

  group(naming.toString(), () {
    group('BinaryRequest', () {
      setUp(() {
        MockTransports.install();
      });

      tearDown(() async {
        MockTransports.verifyNoOutstandingExceptions();
        await MockTransports.uninstall();
      });

      test('setting body with Uint8List', () {
        final binaryData = Uint8List.fromList([1, 2, 3, 4, 5]);
        final request = transport.BinaryRequest()..body = binaryData;
        expect(request.body, equals(binaryData));
      });

      test('setting body with null', () {
        final request = transport.BinaryRequest()..body = null;
        expect(request.body, isNull);
      });

      test('setting body with empty Uint8List', () {
        final emptyData = Uint8List(0);
        final request = transport.BinaryRequest()..body = emptyData;
        expect(request.body, equals(emptyData));
        expect(request.body!.length, equals(0));
      });

      test('setting body in request dispatcher is supported', () async {
        final uri = Uri.parse('/test');

        final c = Completer<Uint8List>();
        MockTransports.http.when(uri, (FinalizedRequest request) async {
          transport.HttpBody body = request.body as transport.HttpBody;
          c.complete(body.asBytes());
          return MockResponse.ok();
        });

        final request = transport.BinaryRequest();
        final binaryData = Uint8List.fromList([1, 2, 3, 255, 0]);
        await request.post(uri: uri, body: binaryData);
        expect(await c.future, equals(binaryData));
      });

      test('body should be unmodifiable once sent', () async {
        final uri = Uri.parse('/test');
        MockTransports.http.expect('POST', uri);
        final request = transport.BinaryRequest();
        await request.post(uri: uri);
        expect(() {
          request.body = Uint8List.fromList([1, 2, 3]);
        }, throwsStateError);
      });

      test('content-length cannot be set manually', () {
        final request = transport.Request();
        expect(() {
          request.contentLength = 10;
        }, throwsUnsupportedError);
      });

      test('content-length is calculated from body', () {
        final request = transport.BinaryRequest();
        expect(request.contentLength, equals(0));

        request.body = Uint8List.fromList([1, 2, 3, 4, 5]);
        expect(request.contentLength, equals(5));

        request.body = Uint8List(1000);
        expect(request.contentLength, equals(1000));

        request.body = null;
        expect(request.contentLength, equals(0));
      });

      test('default content-type should be application/octet-stream', () {
        final request = transport.BinaryRequest();
        expect(
            request.contentType!.mimeType, equals('application/octet-stream'));
        expect(request.contentType!.parameters.containsKey('charset'), isFalse);
      });

      test('setting content-type should not be allowed once sent', () async {
        final uri = Uri.parse('/test');
        MockTransports.http.expect('GET', uri);
        final request = transport.BinaryRequest();
        await request.get(uri: uri);
        expect(() {
          request.contentType = MediaType('application', 'x-custom');
        }, throwsStateError);
      });

      test('custom content-type can be set', () async {
        final uri = Uri.parse('/test');
        MockTransports.http.expect('POST', uri);
        final request = transport.BinaryRequest()
          ..contentType = MediaType('application', 'x-custom')
          ..body = Uint8List.fromList([1, 2, 3]);
        await request.post(uri: uri);
        expect(request.contentType!.mimeType, equals('application/x-custom'));
      });

      test('binary data edge cases', () {
        final request = transport.BinaryRequest();

        // Test with all possible byte values
        final allBytes = Uint8List(256);
        for (int i = 0; i < 256; i++) {
          allBytes[i] = i;
        }
        request.body = allBytes;
        expect(request.body, equals(allBytes));
        expect(request.contentLength, equals(256));
      });

      test('clone()', () {
        final body = Uint8List.fromList([0, 1, 2, 255, 254, 128]);
        final orig = transport.BinaryRequest()..body = body;
        final clone = orig.clone();
        expect(clone.body, equals(body));
        expect(clone.contentLength, equals(body.length));
      });
    });
  });
}
