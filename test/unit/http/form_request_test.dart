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

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/mock.dart';

import '../../naming.dart';

void main() {
  final naming = new Naming()
    ..testType = testTypeUnit
    ..topic = topicHttp;

  group(naming.toString(), () {
    group('FormRequest', () {
      setUp(() {
        configureWTransportForTest();
      });

      test('setting fields defaults to empty map if null', () {
        final request = new FormRequest()..fields = null;
        expect(request.fields, equals({}));
      });

      test('setting entire fields map', () {
        final request = new FormRequest()..fields = {'field': 'value'};
        expect(request.fields, equals({'field': 'value'}));
      });

      test('setting fields incrementally', () {
        final request = new FormRequest()
          ..fields['field1'] = 'value1'
          ..fields['field2'] = 'value2';
        expect(
            request.fields, equals({'field1': 'value1', 'field2': 'value2'}));
      });

      test('setting body in request dispatcher is supported', () async {
        final uri = Uri.parse('/test');

        final c = new Completer<String>();
        MockTransports.http.when(uri, (FinalizedRequest request) async {
          HttpBody body = request.body;
          c.complete(body.asString());
          return new MockResponse.ok();
        });

        final request = new FormRequest();
        await request.post(uri: uri, body: {'field': 'value'});
        expect(await c.future, equals('field=value'));
      });

      test('setting body in request dispatcher should throw if invalid',
          () async {
        final uri = Uri.parse('/test');

        final request = new FormRequest();
        expect(request.post(uri: uri, body: 'invalid'), throws);
      });

      test('body should be unmodifiable once sent', () async {
        final uri = Uri.parse('/test');
        MockTransports.http.expect('POST', uri);
        final request = new FormRequest();
        await request.post(uri: uri);
        expect(() {
          request.fields['too'] = 'late';
        }, throwsUnsupportedError);
        expect(() {
          request.fields = {'new': 'field'};
        }, throwsStateError);
      });

      test('content-length cannot be set manually', () {
        final request = new Request();
        expect(() {
          request.contentLength = 10;
        }, throwsUnsupportedError);
      });

      test('setting encoding to null should throw', () {
        final request = new FormRequest();
        expect(() {
          request.encoding = null;
        }, throwsArgumentError);
      });

      test('setting encoding should update content-type', () {
        final request = new FormRequest();
        expect(request.contentType.parameters['charset'], equals(UTF8.name));

        request.encoding = LATIN1;
        expect(request.contentType.parameters['charset'], equals(LATIN1.name));

        request.encoding = ASCII;
        expect(request.contentType.parameters['charset'], equals(ASCII.name));
      });

      test(
          'setting encoding should not update content-type if content-type has been set manually',
          () {
        final request = new FormRequest();
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
        final uri = Uri.parse('/test');
        MockTransports.http.expect('GET', uri);
        final request = new FormRequest();
        await request.get(uri: uri);
        expect(() {
          request.contentType = new MediaType('application', 'x-custom');
        }, throwsStateError);
      });

      test('setting encoding should not be allowed once sent', () async {
        final uri = Uri.parse('/test');
        MockTransports.http.expect('GET', uri);
        final request = new FormRequest();
        await request.get(uri: uri);
        expect(() {
          request.encoding = LATIN1;
        }, throwsStateError);
      });

      test('custom content-type without inferrable encoding', () async {
        final uri = Uri.parse('/test');
        MockTransports.http.expect('POST', uri);
        final request = new FormRequest()
          ..contentType = new MediaType('application', 'x-custom')
          ..fields['foo'] = 'bar';
        await request.post(uri: uri);
      });

      test('clone()', () {
        final fields = <String, String>{'f1': 'v1', 'f2': 'v2'};
        final orig = new FormRequest()..fields = fields;
        final clone = orig.clone();
        expect(clone.fields, equals(fields));
      });
    });
  });
}
