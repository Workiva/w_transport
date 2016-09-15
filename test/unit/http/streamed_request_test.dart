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
  Naming naming = new Naming()
    ..testType = testTypeUnit
    ..topic = topicHttp;

  group(naming.toString(), () {
    group('StreamedRequest', () {
      setUp(() {
        configureWTransportForTest();
      });

      test('content-type can be set manually', () {
        StreamedRequest request = new StreamedRequest();
        request.contentType = new MediaType('application', 'json');
        expect(request.contentType.mimeType, equals('application/json'));
      });

      test('setting body', () async {
        StreamedRequest request = new StreamedRequest();

        var chunks = [
          [1, 2],
          [3, 4]
        ];
        request.body = new Stream.fromIterable(chunks);
        expect(await request.body.toList(), equals(chunks));
      });

      test('setting body in request dispatcher is supported', () async {
        Uri uri = Uri.parse('/test');

        Completer c = new Completer();
        MockTransports.http.when(uri, (FinalizedRequest request) async {
          StreamedHttpBody body = request.body;
          c.complete(UTF8.decode(await body.toBytes()));
          return new MockResponse.ok();
        });

        StreamedRequest request = new StreamedRequest();
        await request.post(
            uri: uri, body: new Stream.fromIterable([UTF8.encode('body')]));
        expect(await c.future, equals('body'));
      });

      test('setting body in request dispatcher should throw on invalid data',
          () async {
        Uri uri = Uri.parse('/test');

        StreamedRequest request = new StreamedRequest();
        expect(request.post(uri: uri, body: 'body'), throwsArgumentError);
      });

      test('body should be unmodifiable once sent', () async {
        Uri uri = Uri.parse('/test');
        MockTransports.http.expect('POST', uri);
        StreamedRequest request = new StreamedRequest();
        await request.post(uri: uri);
        expect(() {
          request.body = new Stream.fromIterable([
            [1, 2]
          ]);
        }, throwsStateError);
      });

      test('content-length must be set manually', () {
        StreamedRequest request = new StreamedRequest();
        request.contentLength = 10;
        expect(request.contentLength, equals(10));
      });

      test('content-length should be unmodifiable once sent', () async {
        Uri uri = Uri.parse('/test');
        MockTransports.http.expect('GET', uri);
        StreamedRequest request = new StreamedRequest();
        await request.get(uri: uri);
        expect(() {
          request.contentLength = 10;
        }, throwsStateError);
      });

      test('setting encoding to null should throw', () {
        var request = new StreamedRequest();
        expect(() {
          request.encoding = null;
        }, throwsArgumentError);
      });

      test('setting encoding should update content-type', () {
        StreamedRequest request = new StreamedRequest();
        expect(request.contentType.parameters['charset'], equals(UTF8.name));

        request.encoding = LATIN1;
        expect(request.contentType.parameters['charset'], equals(LATIN1.name));

        request.encoding = ASCII;
        expect(request.contentType.parameters['charset'], equals(ASCII.name));
      });

      test(
          'setting encoding should not update content-type if content-type has been set manually',
          () {
        StreamedRequest request = new StreamedRequest();
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
        StreamedRequest request = new StreamedRequest();
        await request.get(uri: uri);
        expect(() {
          request.contentType = new MediaType('application', 'x-custom');
        }, throwsStateError);
      });

      test('setting encoding should not be allowed once sent', () async {
        Uri uri = Uri.parse('/test');
        MockTransports.http.expect('GET', uri);
        StreamedRequest request = new StreamedRequest();
        await request.get(uri: uri);
        expect(() {
          request.encoding = LATIN1;
        }, throwsStateError);
      });

      test('custom content-type without inferrable encoding', () async {
        Uri uri = Uri.parse('/test');
        MockTransports.http.expect('POST', uri);
        var request = new StreamedRequest()
          ..contentType = new MediaType('application', 'x-custom')
          ..body = new Stream.fromIterable([
            [1, 2]
          ]);
        await request.post(uri: uri);
      });

      test('clone()', () {
        StreamedRequest request = new StreamedRequest();
        expect(request.clone, throwsUnsupportedError);
      });

      test('autoRetry not supported', () {
        expect(new StreamedRequest().autoRetry.supported, isFalse);
      });
    });
  });
}
