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
import 'dart:convert';

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
    group('StreamedRequest', () {
      setUp(() {
        MockTransports.install();
      });

      tearDown(() async {
        MockTransports.verifyNoOutstandingExceptions();
        await MockTransports.uninstall();
      });

      test('content-type can be set manually', () {
        final request = transport.StreamedRequest();
        request.contentType = MediaType('application', 'json');
        expect(request.contentType!.mimeType, equals('application/json'));
      });

      test('setting body', () async {
        final request = transport.StreamedRequest();

        final chunks = <List<int>>[
          [1, 2],
          [3, 4]
        ];
        request.body = Stream.fromIterable(chunks);
        expect(await request.body!.toList(), equals(chunks));
      });

      test('setting body in request dispatcher is supported', () async {
        final uri = Uri.parse('/test');

        final c = Completer<String>();
        MockTransports.http.when(uri, (FinalizedRequest request) async {
          transport.StreamedHttpBody body = request.body as StreamedHttpBody;
          c.complete(utf8.decode(await body.toBytes()));
          return MockResponse.ok();
        });

        final request = transport.StreamedRequest();
        await request.post(
            uri: uri, body: Stream.fromIterable([utf8.encode('body')]));
        expect(await c.future, equals('body'));
      });

      test('setting body in request dispatcher should throw on invalid data',
          () async {
        final uri = Uri.parse('/test');

        final request = transport.StreamedRequest();
        expect(request.post(uri: uri, body: 'body'), throwsArgumentError);
      });

      test('body should be unmodifiable once sent', () async {
        final uri = Uri.parse('/test');
        MockTransports.http.expect('POST', uri);
        final request = transport.StreamedRequest();
        await request.post(uri: uri);
        expect(() {
          request.body = Stream.fromIterable([
            [1, 2]
          ]);
        }, throwsStateError);
      });

      test('content-length must be set manually', () {
        final request = transport.StreamedRequest();
        request.contentLength = 10;
        expect(request.contentLength, equals(10));
      });

      test('content-length should be unmodifiable once sent', () async {
        final uri = Uri.parse('/test');
        MockTransports.http.expect('GET', uri);
        final request = transport.StreamedRequest();
        await request.get(uri: uri);
        expect(() {
          request.contentLength = 10;
        }, throwsStateError);
      });

      test('setting encoding to null should throw', () {
        final request = transport.StreamedRequest();
        expect(() {
          request.encoding = null;
        }, throwsArgumentError);
      });

      test('setting encoding should update content-type', () {
        final request = transport.StreamedRequest();
        expect(request.contentType!.parameters['charset'], equals(utf8.name));

        request.encoding = latin1;
        expect(request.contentType!.parameters['charset'], equals(latin1.name));

        request.encoding = ascii;
        expect(request.contentType!.parameters['charset'], equals(ascii.name));
      });

      test(
          'setting encoding should not update content-type if content-type has been set manually',
          () {
        final request = transport.StreamedRequest();
        expect(request.contentType!.parameters['charset'], equals(utf8.name));

        // Manually override content-type.
        request.contentType =
            MediaType('application', 'x-custom', {'charset': latin1.name});
        expect(request.contentType!.mimeType, equals('application/x-custom'));
        expect(request.contentType!.parameters['charset'], equals(latin1.name));

        // Changes to encoding should no longer update the content-type.
        request.encoding = ascii;
        expect(request.contentType!.parameters['charset'], equals(latin1.name));
      });

      test('setting content-type should not be allowed once sent', () async {
        final uri = Uri.parse('/test');
        MockTransports.http.expect('GET', uri);
        final request = transport.StreamedRequest();
        await request.get(uri: uri);
        expect(() {
          request.contentType = MediaType('application', 'x-custom');
        }, throwsStateError);
      });

      test('setting encoding should not be allowed once sent', () async {
        final uri = Uri.parse('/test');
        MockTransports.http.expect('GET', uri);
        final request = transport.StreamedRequest();
        await request.get(uri: uri);
        expect(() {
          request.encoding = latin1;
        }, throwsStateError);
      });

      test('custom content-type without inferrable encoding', () async {
        final uri = Uri.parse('/test');
        MockTransports.http.expect('POST', uri);
        final request = transport.StreamedRequest()
          ..contentType = MediaType('application', 'x-custom')
          ..body = Stream.fromIterable([
            [1, 2]
          ]);
        await request.post(uri: uri);
      });

      test('clone()', () {
        final request = transport.StreamedRequest();
        expect(request.clone, throwsUnsupportedError);
      });

      test('autoRetry not supported', () {
        expect(transport.StreamedRequest().autoRetry!.supported, isFalse);
      });
    });
  });
}
