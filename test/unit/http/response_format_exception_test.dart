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

import 'dart:convert';
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart' as transport;

import '../../naming.dart';

void main() {
  final naming = new Naming()
    ..testType = testTypeUnit
    ..topic = topicHttp;

  group(naming.toString(), () {
    group('ResponseFormatException', () {
      test('should detail why bytes could not be decoded', () {
        final bytes = utf8.encode('bodyçå®');
        final contentType = new MediaType(
            'application', 'json', {'charset': ascii.name});
        final exception = new transport.ResponseFormatException(
            contentType, ascii,
            bytes: bytes);
        expect(exception.toString(), contains('Bytes could not be decoded'));
        expect(exception.toString(), contains('Content-Type: $contentType'));
        expect(
            exception.toString(), contains('Encoding: ${ascii.name}'));
        expect(exception.toString(),
            contains(utf8.encode('bodyçå®').toString()));
      });

      test('should detail why string could not be encoded', () {
        const body = 'bodyçå®';
        final contentType = new MediaType(
            'application', 'json', {'charset': ascii.name});
        final exception = new transport.ResponseFormatException(
            contentType, ascii,
            body: body);
        expect(exception.toString(), contains('Body could not be encoded'));
        expect(exception.toString(), contains('Content-Type: $contentType'));
        expect(
            exception.toString(), contains('Encoding: ${ascii.name}'));
        expect(exception.toString(), contains('bodyçå®'));
      });

      test('should warn if encoding is null', () {
        const body = 'bodyçå®';
        final contentType = new MediaType(
            'application', 'json', {'charset': ascii.name});
        final exception = new transport.ResponseFormatException(
            contentType, null,
            body: body);
        expect(exception.toString(), contains('Body could not be encoded'));
        expect(exception.toString(), contains('Content-Type: $contentType'));
        expect(exception.toString(), contains('Encoding: null'));
        expect(exception.toString(), contains('bodyçå®'));
      });
    });
  });
}
