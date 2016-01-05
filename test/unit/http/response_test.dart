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

library w_transport.test.unit.http.response_test;

import 'dart:async';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';

import '../../naming.dart';

void main() {
  Naming naming = new Naming()
    ..testType = testTypeUnit
    ..topic = topicHttp;

  group(naming.toString(), () {
    group('Response', () {
      test('content-length should be set automatically', () {
        List<int> bytes = [10, 390];
        Response response = new Response.fromBytes(200, 'OK', {}, bytes);
        expect(response.contentLength, equals(bytes.length));
      });

      test('body', () {
        Response response = new Response.fromString(200, 'OK', {}, 'body');
        expect(response.body.asString(), equals('body'));
      });

      test('replace', () {
        Response response = new Response.fromString(200, 'OK', {}, 'body');
        Response response2 = response.replace(status: 301);
        expect(response2.status, equals(301));
        expect(response2.statusText, equals('OK'));
        expect(response2.headers, equals({}));
        expect(response2.body.asString(), equals('body'));

        Response response3 = response.replace(statusText: 'Not OK');
        expect(response3.status, equals(200));
        expect(response3.statusText, equals('Not OK'));
        expect(response3.headers, equals({}));
        expect(response3.body.asString(), equals('body'));

        Response response4 = response.replace(headers: {'origin': 'pluto'});
        expect(response4.status, equals(200));
        expect(response4.statusText, equals('OK'));
        expect(response4.headers, equals({'origin': 'pluto'}));
        expect(response4.body.asString(), equals('body'));

        Response response5 = response.replace(bodyString: 'phrasing');
        expect(response5.status, equals(200));
        expect(response5.statusText, equals('OK'));
        expect(response5.headers, equals({}));
        expect(response5.body.asString(), equals('phrasing'));

        Response response6 = response.replace(bodyBytes: [10, 134]);
        expect(response6.status, equals(200));
        expect(response6.statusText, equals('OK'));
        expect(response6.headers, equals({}));
        expect(response6.body.asBytes(), equals([10, 134]));
      });
    });

    group('StreamedResponse', () {
      test('content-length should be taken from headers', () {
        List<int> bytes = [10, 390];
        var headers = {'content-length': '${bytes.length}'};
        StreamedResponse response = new StreamedResponse.fromByteStream(
            200, 'OK', headers, new Stream.fromIterable([bytes]));
        expect(response.contentLength, equals(bytes.length));
      });

      test('body', () async {
        List<int> bytes = [1, 2, 3, 4];
        StreamedResponse response = new StreamedResponse.fromByteStream(
            200, 'OK', {}, new Stream.fromIterable([bytes]));
        expect(await response.body.byteStream.toList(), equals([bytes]));
      });

      test('replace', () async {
        List<int> bytes = [1, 2, 3, 4];
        StreamedResponse response = new StreamedResponse.fromByteStream(
            200, 'OK', {}, new Stream.fromIterable([bytes]));
        StreamedResponse response2 = response.replace(status: 301);
        expect(response2.status, equals(301));
        expect(response2.statusText, equals('OK'));
        expect(response2.headers, equals({}));
        expect(response2.body, equals(response.body));

        StreamedResponse response3 = response.replace(statusText: 'Not OK');
        expect(response3.status, equals(200));
        expect(response3.statusText, equals('Not OK'));
        expect(response3.headers, equals({}));
        expect(response3.body, equals(response.body));

        StreamedResponse response4 =
            response.replace(headers: {'origin': 'pluto'});
        expect(response4.status, equals(200));
        expect(response4.statusText, equals('OK'));
        expect(response4.headers, equals({'origin': 'pluto'}));
        expect(response4.body, equals(response.body));

        bytes = [5, 6, 7];
        StreamedResponse response5 =
            response.replace(byteStream: new Stream.fromIterable([bytes]));
        expect(response5.status, equals(200));
        expect(response5.statusText, equals('OK'));
        expect(response5.headers, equals({}));
        expect(await response5.body.byteStream.toList(), equals([bytes]));
      });
    });
  });
}
