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
  final naming = new Naming()
    ..testType = testTypeUnit
    ..topic = topicHttp;

  group(naming.toString(), () {
    group('Request', () {
      setUp(() {
        MockTransports.install();
      });

      tearDown(() async {
        MockTransports.verifyNoOutstandingExceptions();
        await MockTransports.uninstall();
      });

      test('setting body (string)', () {
        final request = new transport.Request();

        request.body = 'body';
        expect(request.body, equals('body'));
        expect(request.bodyBytes, equals(utf8.encode('body')));

        request.body = null;
        expect(request.body, equals(''));
        expect(request.bodyBytes, isEmpty);
      });

      test('setting body (bytes)', () {
        final request = new transport.Request();

        request.bodyBytes = utf8.encode('body');
        expect(request.bodyBytes, equals(utf8.encode('body')));
        expect(request.body, equals('body'));

        request.bodyBytes = null;
        expect(request.bodyBytes, isEmpty);
        expect(request.body, equals(''));
      });

      test('setting body in request dispatcher is supported (string)',
          () async {
        final uri = Uri.parse('/test');

        final c = new Completer<String>();
        MockTransports.http.when(uri, (FinalizedRequest request) async {
          transport.HttpBody body = request.body;
          c.complete(body.asString());
          return new MockResponse.ok();
        });

        final request = new transport.Request();
        await request.post(uri: uri, body: 'body');
        expect(await c.future, equals('body'));
      });

      test('setting body in request dispatcher is supported (bytes)', () async {
        final uri = Uri.parse('/test');

        final c = new Completer<String>();
        MockTransports.http.when(uri, (FinalizedRequest request) async {
          transport.HttpBody body = request.body;
          c.complete(body.asString());
          return new MockResponse.ok();
        });

        final request = new transport.Request();
        await request.post(uri: uri, body: utf8.encode('body'));
        expect(await c.future, equals('body'));
      });

      test('setting body in request dispatcher should throw if invalid',
          () async {
        final uri = Uri.parse('/test');

        final request = new transport.Request();
        expect(request.post(uri: uri, body: {'invalid': 'map'}),
            throwsArgumentError);
      });

      test('body should be unmodifiable once sent', () async {
        final uri = Uri.parse('/test');
        MockTransports.http.expect('POST', uri);
        final request = new transport.Request();
        await request.post(uri: uri);
        expect(() {
          request.body = 'too late';
        }, throwsStateError);
        expect(() {
          request.bodyBytes = utf8.encode('too late');
        }, throwsStateError);
      });

      test('content-length cannot be set manually', () {
        final request = new transport.Request();
        expect(() {
          request.contentLength = 10;
        }, throwsUnsupportedError);
      });

      test('setting encoding to null should throw', () {
        final request = new transport.Request();
        expect(() {
          request.encoding = null;
        }, throwsArgumentError);
      });

      test('setting encoding should update content-type', () {
        final request = new transport.Request();
        expect(request.contentType.parameters['charset'], equals(utf8.name));

        request.encoding = latin1;
        expect(request.contentType.parameters['charset'], equals(latin1.name));

        request.encoding = ascii;
        expect(request.contentType.parameters['charset'], equals(ascii.name));
      });

      test(
          'setting encoding should not update content-type if content-type has been set manually',
          () {
        final request = new transport.Request();
        expect(request.contentType.parameters['charset'], equals(utf8.name));

        // Manually override content-type.
        request.contentType =
            new MediaType('application', 'x-custom', {'charset': latin1.name});
        expect(request.contentType.mimeType, equals('application/x-custom'));
        expect(request.contentType.parameters['charset'], equals(latin1.name));

        // Changes to encoding should no longer update the content-type.
        request.encoding = ascii;
        expect(request.contentType.parameters['charset'], equals(latin1.name));
      });

      test('setting content-type should not be allowed once sent', () async {
        final uri = Uri.parse('/test');
        MockTransports.http.expect('GET', uri);
        final request = new transport.Request();
        await request.get(uri: uri);
        expect(() {
          request.contentType = new MediaType('application', 'x-custom');
        }, throwsStateError);
      });

      test('setting encoding should not be allowed once sent', () async {
        final uri = Uri.parse('/test');
        MockTransports.http.expect('GET', uri);
        final request = new transport.Request();
        await request.get(uri: uri);
        expect(() {
          request.encoding = latin1;
        }, throwsStateError);
      });

      test('custom content-type without inferrable encoding', () async {
        final uri = Uri.parse('/test');
        MockTransports.http.expect('POST', uri);
        final request = new transport.Request()
          ..contentType = new MediaType('application', 'x-custom')
          ..body = 'body';
        await request.post(uri: uri);
      });

      test('clone()', () {
        const body = 'body';
        final orig = new transport.Request()..body = body;
        final clone = orig.clone();
        expect(clone.body, equals(body));

        final bodyBytes = utf8.encode('bytes');
        final orig2 = new transport.Request()..bodyBytes = bodyBytes;
        final clone2 = orig2.clone();
        expect(clone2.bodyBytes, equals(bodyBytes));
      });
    });
  });
}
