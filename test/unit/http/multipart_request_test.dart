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
    group('MultipartRequest', () {
      setUp(() {
        configureWTransportForTest();
      });

      test('content-type cannot be set manually', () {
        MultipartRequest request = new MultipartRequest();
        expect(() => request.contentType = null, throwsUnsupportedError);
      });

      test('content-length cannot be set manually', () {
        MultipartRequest request = new MultipartRequest();
        expect(() {
          request.contentLength = 10;
        }, throwsUnsupportedError);
      });

      test('setting body in request dispatcher is unsupported', () async {
        Uri uri = Uri.parse('/test');
        MultipartRequest request = new MultipartRequest();
        expect(request.post(uri: uri, body: 'body'), throwsUnsupportedError);
      });

      test('body cannot be empty', () {
        MultipartRequest request = new MultipartRequest();
        expect(request.post(uri: Uri.parse('/test')), throwsUnsupportedError);
      });

      test('body can be set incrementally or all at once', () {
        MultipartRequest request = new MultipartRequest();
        request.fields = {'field1': 'v1'};
        expect(request.fields, containsPair('field1', 'v1'));
        request.files = {'file1': 'f1'};
        expect(request.files, containsPair('file1', 'f1'));
        request.fields['field2'] = 'v2';
        expect(request.fields, containsPair('field2', 'v2'));
        request.files['file2'] = 'f2';
        expect(request.files, containsPair('file2', 'f2'));
      });

      test('body should be unmodifiable once sent', () async {
        Uri uri = Uri.parse('/test');
        MockTransports.http.expect('POST', uri);
        MultipartRequest request = new MultipartRequest()
          ..fields['field1'] = 'value1';
        await request.post(uri: uri);
        expect(() {
          request.fields['too'] = 'late';
        }, throwsUnsupportedError);
        expect(() {
          request.files['too'] = 'late';
        }, throwsUnsupportedError);
        expect(() {
          request.fields = {'too': 'late'};
        }, throwsStateError);
        expect(() {
          request.files = {'too': 'late'};
        }, throwsStateError);
      });

      test('setting encoding should be unsupported', () {
        MultipartRequest request = new MultipartRequest();
        expect(() {
          request.encoding = UTF8;
        }, throwsUnsupportedError);
      });

      test('clone()', () {
        var fields = {'f1': 'v1', 'f2': 'v2'};
        MultipartRequest orig = new MultipartRequest()..fields = fields;
        MultipartRequest clone = orig.clone();
        expect(clone.fields, equals(fields));
      });

      test('autoRetry with files not supported', () {
        MultipartRequest request = new MultipartRequest()..files['k'] = 'f';
        expect(request.autoRetry.supported, isFalse);
      });
    });
  });
}
