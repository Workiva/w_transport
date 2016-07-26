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
library w_transport.test.unit.http.plain_text_request_test;

import 'dart:async';
import 'dart:convert';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/mock.dart';

import '../../naming.dart';

void main() {
  Naming naming = new Naming()
    ..testType = testTypeUnit
    ..topic = topicHttp;

  group(naming.toString(), () {
    group('Request', () {
      setUp(() {
        configureWTransportForTest();
      });

      test('setting body (string)', () {
        Request request = new Request();

        request.body = 'body';
        expect(request.body, equals('body'));
        expect(request.bodyBytes, equals(UTF8.encode('body')));

        request.body = null;
        expect(request.body, equals(''));
        expect(request.bodyBytes, isEmpty);
      });

      test('setting body (bytes)', () {
        Request request = new Request();

        request.bodyBytes = UTF8.encode('body');
        expect(request.bodyBytes, equals(UTF8.encode('body')));
        expect(request.body, equals('body'));

        request.bodyBytes = null;
        expect(request.bodyBytes, isEmpty);
        expect(request.body, equals(''));
      });

      test('setting body in request dispatcher is supported (string)',
          () async {
        Uri uri = Uri.parse('/test');

        Completer body = new Completer();
        MockTransports.http.when(uri, (FinalizedRequest request) async {
          body.complete((request.body as HttpBody).asString());
          return new MockResponse.ok();
        });

        Request request = new Request();
        await request.post(uri: uri, body: 'body');
        expect(await body.future, equals('body'));
      });

      test('setting body in request dispatcher is supported (bytes)', () async {
        Uri uri = Uri.parse('/test');

        Completer body = new Completer();
        MockTransports.http.when(uri, (FinalizedRequest request) async {
          body.complete((request.body as HttpBody).asString());
          return new MockResponse.ok();
        });

        Request request = new Request();
        await request.post(uri: uri, body: UTF8.encode('body'));
        expect(await body.future, equals('body'));
      });

      test('setting body in request dispatcher should throw if invalid',
          () async {
        Uri uri = Uri.parse('/test');

        Request request = new Request();
        expect(request.post(uri: uri, body: {'invalid': 'map'}),
            throwsArgumentError);
      });

      test('body should be unmodifiable once sent', () async {
        Uri uri = Uri.parse('/test');
        MockTransports.http.expect('POST', uri);
        Request request = new Request();
        await request.post(uri: uri);
        expect(() {
          request.body = 'too late';
        }, throwsStateError);
        expect(() {
          request.bodyBytes = UTF8.encode('too late');
        }, throwsStateError);
      });

      test('content-length cannot be set manually', () {
        Request request = new Request();
        expect(() {
          request.contentLength = 10;
        }, throwsUnsupportedError);
      });

      test('setting encoding to null should throw', () {
        var request = new Request();
        expect(() {
          request.encoding = null;
        }, throwsArgumentError);
      });

      test('setting encoding should update content-type', () {
        Request request = new Request();
        expect(request.contentType.parameters['charset'], equals(UTF8.name));

        request.encoding = LATIN1;
        expect(request.contentType.parameters['charset'], equals(LATIN1.name));

        request.encoding = ASCII;
        expect(request.contentType.parameters['charset'], equals(ASCII.name));
      });

      test(
          'setting encoding should not update content-type if content-type has been set manually',
          () {
        Request request = new Request();
        expect(request.contentType.parameters['charset'], equals(UTF8.name));

        // Manually override content-type.
        request.contentType =
            new MediaType('application', 'x-custom', {'charset': LATIN1.name});
        expect(request.contentType.mimeType, equals('application/x-custom'));
        expect(request.contentType.parameters['charset'], equals(LATIN1.name));

        // Changes to encoding should no longer update the content-type.
        request.encoding = ASCII;
        expect(request.contentType.parameters['charset'], equals(LATIN1.name));
      });

      test('setting content-type should not be allowed once sent', () async {
        Uri uri = Uri.parse('/test');
        MockTransports.http.expect('GET', uri);
        Request request = new Request();
        await request.get(uri: uri);
        expect(() {
          request.contentType = new MediaType('application', 'x-custom');
        }, throwsStateError);
      });

      test('setting encoding should not be allowed once sent', () async {
        Uri uri = Uri.parse('/test');
        MockTransports.http.expect('GET', uri);
        Request request = new Request();
        await request.get(uri: uri);
        expect(() {
          request.encoding = LATIN1;
        }, throwsStateError);
      });

      test('custom content-type without inferrable encoding', () async {
        Uri uri = Uri.parse('/test');
        MockTransports.http.expect('POST', uri);
        var request = new Request()
          ..contentType = new MediaType('application', 'x-custom')
          ..body = 'body';
        await request.post(uri: uri);
      });

      test('clone()', () {
        var body = 'body';
        Request orig = new Request()..body = body;
        Request clone = orig.clone();
        expect(clone.body, equals(body));

        var bodyBytes = UTF8.encode('bytes');
        Request orig2 = new Request()..bodyBytes = bodyBytes;
        Request clone2 = orig2.clone();
        expect(clone2.bodyBytes, equals(bodyBytes));
      });
    });
  });
}
