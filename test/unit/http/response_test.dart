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

void main() {
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
  });
}
