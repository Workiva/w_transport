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
library w_transport.test.unit.http.form_request_test;

import 'dart:async';
import 'dart:convert';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_mock.dart';

import '../../naming.dart';

void main() {
  Naming naming = new Naming()
    ..testType = testTypeUnit
    ..topic = topicHttp;

  group(naming.toString(), () {
    group('FormRequest', () {
      setUp(() {
        configureWTransportForTest();
      });

      test('content-type cannot be set manually', () {
        FormRequest request = new FormRequest();
        expect(() => request.contentType = null, throwsUnsupportedError);
      });

      test('setting fields defaults to empty map if null', () {
        FormRequest request = new FormRequest()..fields = null;
        expect(request.fields, equals({}));
      });

      test('setting entire fields map', () {
        FormRequest request = new FormRequest()..fields = {'field': 'value'};
        expect(request.fields, equals({'field': 'value'}));
      });

      test('setting fields incrementally', () {
        FormRequest request = new FormRequest()
          ..fields['field1'] = 'value1'
          ..fields['field2'] = 'value2';
        expect(
            request.fields, equals({'field1': 'value1', 'field2': 'value2'}));
      });

      test('setting body in request dispatcher is supported', () async {
        Uri uri = Uri.parse('/test');

        Completer body = new Completer();
        MockTransports.http.when(uri, (FinalizedRequest request) async {
          body.complete((request.body as HttpBody).asString());
          return new MockResponse.ok();
        });

        FormRequest request = new FormRequest();
        await request.post(uri: uri, body: {'field': 'value'});
        expect(await body.future, equals('field=value'));
      });

      test('setting body in request dispatcher should throw if invalid',
          () async {
        Uri uri = Uri.parse('/test');

        FormRequest request = new FormRequest();
        expect(request.post(uri: uri, body: 'invalid'), throws);
      });

      test('body should be unmodifiable once sent', () async {
        Uri uri = Uri.parse('/test');
        MockTransports.http.expect('POST', uri);
        FormRequest request = new FormRequest();
        await request.post(uri: uri);
        expect(() {
          request.fields['too'] = 'late';
        }, throwsUnsupportedError);
        expect(() {
          request.fields = {'new': 'field'};
        }, throwsStateError);
      });

      test('content-length cannot be set manually', () {
        Request request = new Request();
        expect(() {
          request.contentLength = 10;
        }, throwsUnsupportedError);
      });

      test('setting encoding should update content-type', () {
        FormRequest request = new FormRequest();
        expect(request.contentType.parameters['charset'], equals(UTF8.name));

        request.encoding = LATIN1;
        expect(request.contentType.parameters['charset'], equals(LATIN1.name));

        request.encoding = ASCII;
        expect(request.contentType.parameters['charset'], equals(ASCII.name));
      });

      test('setting encoding should not be allowed once sent', () async {
        Uri uri = Uri.parse('/test');
        MockTransports.http.expect('GET', uri);
        FormRequest request = new FormRequest();
        await request.get(uri: uri);
        expect(() {
          request.encoding = LATIN1;
        }, throwsStateError);
      });

      test('clone()', () {
        var fields = {'f1': 'v1', 'f2': 'v2'};
        FormRequest orig = new FormRequest()..fields = fields;
        FormRequest clone = orig.clone();
        expect(clone.fields, equals(fields));
      });
    });
  });
}
