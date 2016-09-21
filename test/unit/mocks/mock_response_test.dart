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
import 'dart:convert';

import 'package:test/test.dart';
import 'package:w_transport/mock.dart';

import '../../naming.dart';

void main() {
  final naming = new Naming()
    ..testType = testTypeUnit
    ..topic = topicMocks;

  group(naming.toString(), () {
    group('MockResponse', () {
      test('custom constructor', () async {
        final response = new MockResponse(100,
            statusText: 'custom', headers: {'x-custom': 'value'}, body: 'data');
        expect(response.status, equals(100));
        expect(response.statusText, equals('custom'));
        expect(response.headers['x-custom'], equals('value'));
        expect(response.body.asString(), equals('data'));
      });

      test('.ok() 200', () {
        final response = new MockResponse.ok();
        expect(response.status, equals(200));
        expect(response.statusText, equals('OK'));
      });

      test('.badRequest() 400', () {
        final response = new MockResponse.badRequest();
        expect(response.status, equals(400));
        expect(response.statusText, equals('BAD REQUEST'));
      });

      test('.unauthorized() 401', () {
        final response = new MockResponse.unauthorized();
        expect(response.status, equals(401));
        expect(response.statusText, equals('UNAUTHORIZED'));
      });

      test('.forbidden() 403', () {
        final response = new MockResponse.forbidden();
        expect(response.status, equals(403));
        expect(response.statusText, equals('FORBIDDEN'));
      });

      test('.notFound() 404', () {
        final response = new MockResponse.notFound();
        expect(response.status, equals(404));
        expect(response.statusText, equals('NOT FOUND'));
      });

      test('.methodNotAllowed() 405', () {
        final response = new MockResponse.methodNotAllowed();
        expect(response.status, equals(405));
        expect(response.statusText, equals('METHOD NOT ALLOWED'));
      });

      test('.internalServerError() 500', () {
        final response = new MockResponse.internalServerError();
        expect(response.status, equals(500));
        expect(response.statusText, equals('INTERNAL SERVER ERROR'));
      });

      test('.notImplemented() 501', () {
        final response = new MockResponse.notImplemented();
        expect(response.status, equals(501));
        expect(response.statusText, equals('NOT IMPLEMENTED'));
      });

      test('.badGateway() 502', () {
        final response = new MockResponse.badGateway();
        expect(response.status, equals(502));
        expect(response.statusText, equals('BAD GATEWAY'));
      });

      test('encoding should set charset', () {
        final response = new MockResponse(200, encoding: ASCII);
        expect(response.contentType.parameters['charset'], equals(ASCII.name));
      });

      test('should support string body', () {
        final response = new MockResponse(200, body: 'body');
        expect(response.body.asString(), equals('body'));
      });

      test('should support bytes body', () {
        final response = new MockResponse(200, body: UTF8.encode('body'));
        expect(response.body.asString(), equals('body'));
      });

      test('should throw on invalid body', () {
        expect(() {
          new MockResponse(200, body: {'invalid': 'map'});
        }, throwsArgumentError);
      });

      test('content-length', () {
        final response = new MockResponse.ok(body: [1, 2]);
        expect(response.contentLength, equals(2));
      });

      test('content-type', () {
        final response = new MockResponse.ok(
            headers: {'content-type': 'application/json; charset=utf-8'});
        expect(response.contentType.mimeType, equals('application/json'));
        expect(
            response.contentType.parameters, containsPair('charset', 'utf-8'));
      });

      test('replace', () {
        final response = new MockResponse.ok();
        final response2 = response.replace(status: 201);
        expect(response2.status, equals(201));
      });
    });

    group('MockStreamedResponse', () {
      Stream<List<int>> toByteStream(String body) =>
          new Stream.fromIterable([UTF8.encode(body)]);

      test('custom constructor', () async {
        final response = new MockStreamedResponse(100,
            statusText: 'custom',
            headers: {'x-custom': 'value'},
            byteStream: toByteStream('data'));
        expect(response.status, equals(100));
        expect(response.statusText, equals('custom'));
        expect(response.headers['x-custom'], equals('value'));
        expect(UTF8.decode(await response.body.toBytes()), equals('data'));
      });

      test('.ok() 200', () {
        final response = new MockStreamedResponse.ok();
        expect(response.status, equals(200));
        expect(response.statusText, equals('OK'));
      });

      test('.badRequest() 400', () {
        final response = new MockStreamedResponse.badRequest();
        expect(response.status, equals(400));
        expect(response.statusText, equals('BAD REQUEST'));
      });

      test('.unauthorized() 401', () {
        final response = new MockStreamedResponse.unauthorized();
        expect(response.status, equals(401));
        expect(response.statusText, equals('UNAUTHORIZED'));
      });

      test('.forbidden() 403', () {
        final response = new MockStreamedResponse.forbidden();
        expect(response.status, equals(403));
        expect(response.statusText, equals('FORBIDDEN'));
      });

      test('.notFound() 404', () {
        final response = new MockStreamedResponse.notFound();
        expect(response.status, equals(404));
        expect(response.statusText, equals('NOT FOUND'));
      });

      test('.methodNotAllowed() 405', () {
        final response = new MockStreamedResponse.methodNotAllowed();
        expect(response.status, equals(405));
        expect(response.statusText, equals('METHOD NOT ALLOWED'));
      });

      test('.internalServerError() 500', () {
        final response = new MockStreamedResponse.internalServerError();
        expect(response.status, equals(500));
        expect(response.statusText, equals('INTERNAL SERVER ERROR'));
      });

      test('.notImplemented() 501', () {
        final response = new MockStreamedResponse.notImplemented();
        expect(response.status, equals(501));
        expect(response.statusText, equals('NOT IMPLEMENTED'));
      });

      test('.badGateway() 502', () {
        final response = new MockStreamedResponse.badGateway();
        expect(response.status, equals(502));
        expect(response.statusText, equals('BAD GATEWAY'));
      });

      test('encoding should set charset', () {
        final response = new MockStreamedResponse(200, encoding: ASCII);
        expect(response.contentType.parameters['charset'], equals(ASCII.name));
      });

      test('should support byteStream body', () async {
        final response =
            new MockStreamedResponse(200, byteStream: toByteStream('body'));
        expect(UTF8.decode(await response.body.toBytes()), equals('body'));
      });

      test('content-length', () {
        final response =
            new MockStreamedResponse.ok(headers: {'content-length': '5'});
        expect(response.contentLength, equals(5));
      });

      test('content-type', () {
        final response = new MockStreamedResponse.ok(
            headers: {'content-type': 'application/json; charset=utf-8'});
        expect(response.contentType.mimeType, equals('application/json'));
        expect(
            response.contentType.parameters, containsPair('charset', 'utf-8'));
      });

      test('encoding', () {
        final response = new MockStreamedResponse(200, encoding: UTF8);
        expect(response.encoding, equals(UTF8));
      });

      test('replace', () {
        final response = new MockStreamedResponse.ok();
        final response2 = response.replace(status: 201);
        expect(response2.status, equals(201));
      });
    });
  });
}
