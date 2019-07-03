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

import 'dart:async';
import 'dart:typed_data';

import 'package:dart2_constant/convert.dart' as convert;
import 'package:http_parser/http_parser.dart';
import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart' as transport;

import '../../naming.dart';

void main() {
  final naming = Naming()
    ..testType = testTypeUnit
    ..topic = topicHttp;

  group(naming.toString(), () {
    group('HttpBody', () {
      test('.fromBytes() ctor should default to empty list', () {
        final contentType = MediaType('text', 'plain');
        final body = transport.HttpBody.fromBytes(contentType, null);
        expect(body.asBytes(), isEmpty);
      });

      test('should use encoding if one is explicitly given', () {
        final contentType = MediaType('text', 'plain');

        final stringBody = transport.HttpBody.fromString(contentType, 'body',
            encoding: convert.ascii);
        expect(stringBody.encoding, equals(convert.ascii));

        final bytesBody = transport.HttpBody.fromBytes(
            contentType, convert.utf8.encode('body'),
            encoding: convert.ascii);
        expect(bytesBody.encoding, equals(convert.ascii));
      });

      test('should parse encoding from content-type', () {
        final contentType =
            MediaType('text', 'plain', {'charset': convert.ascii.name});

        final stringBody = transport.HttpBody.fromString(contentType, 'body');
        expect(stringBody.encoding, equals(convert.ascii));

        final bytesBody = transport.HttpBody.fromBytes(
            contentType, convert.utf8.encode('body'));
        expect(bytesBody.encoding, equals(convert.ascii));
      });

      test('should allow a fallback encoding', () {
        final contentType = MediaType('text', 'plain');

        final stringBody = transport.HttpBody.fromString(contentType, 'body',
            fallbackEncoding: convert.ascii);
        expect(stringBody.encoding, equals(convert.ascii));

        final bytesBody = transport.HttpBody.fromBytes(
            contentType, convert.utf8.encode('body'),
            fallbackEncoding: convert.ascii);
        expect(bytesBody.encoding, equals(convert.ascii));
      });

      test('should use UTF8 by default', () {
        final contentType = MediaType('text', 'plain');

        final stringBody = transport.HttpBody.fromString(contentType, 'body');
        expect(stringBody.encoding, equals(convert.utf8));

        final bytesBody = transport.HttpBody.fromBytes(
            contentType, convert.utf8.encode('body'));
        expect(bytesBody.encoding, equals(convert.utf8));
      });

      test('content-length should be calculated automaticlaly', () {
        final contentType = MediaType('text', 'plain');
        final body = transport.HttpBody.fromBytes(contentType, [1, 2, 3, 4]);
        expect(body.contentLength, equals(4));
      });

      test('asBytes() UTF8', () {
        final contentType =
            MediaType('text', 'plain', {'charset': convert.utf8.name});
        final body = transport.HttpBody.fromString(contentType, 'bodyçå®');
        final encoded = Uint8List.fromList(convert.utf8.encode('bodyçå®'));
        expect(body.asBytes(), equals(encoded));
      });

      test('asBytes() LATIN1', () {
        final contentType =
            MediaType('text', 'plain', {'charset': convert.latin1.name});
        final body = transport.HttpBody.fromString(contentType, 'bodyçå®');
        final encoded = Uint8List.fromList(convert.latin1.encode('bodyçå®'));
        expect(body.asBytes(), equals(encoded));
      });

      test('asBytes() ASCII', () {
        final contentType =
            MediaType('text', 'plain', {'charset': convert.ascii.name});
        final body = transport.HttpBody.fromString(contentType, 'body');
        final encoded = Uint8List.fromList(convert.ascii.encode('body'));
        expect(body.asBytes(), equals(encoded));
      });

      test('asJson() UTF8', () {
        final contentType =
            MediaType('application', 'json', {'charset': convert.utf8.name});
        final bodyJson = <Map<String, String>>[
          {'foo': 'bar', 'baz': 'çå®"'}
        ];
        final body = transport.HttpBody.fromBytes(
            contentType, convert.utf8.encode(convert.json.encode(bodyJson)));
        expect(body.asJson(), equals(bodyJson));
      });

      test('asJson() LATIN1', () {
        final contentType =
            MediaType('application', 'json', {'charset': convert.latin1.name});
        final bodyJson = <Map<String, String>>[
          {'foo': 'bar', 'baz': 'çå®"'}
        ];
        final body = transport.HttpBody.fromBytes(
            contentType, convert.latin1.encode(convert.json.encode(bodyJson)));
        expect(body.asJson(), equals(bodyJson));
      });

      test('asJson() ASCII', () {
        final contentType =
            MediaType('application', 'json', {'charset': convert.ascii.name});
        final bodyJson = <Map<String, String>>[
          {'foo': 'bar', 'bar': 'baz'}
        ];
        final body = transport.HttpBody.fromBytes(
            contentType, convert.ascii.encode(convert.json.encode(bodyJson)));
        expect(body.asJson(), equals(bodyJson));
      });

      test('asString() UTF8', () {
        final contentType =
            MediaType('application', 'json', {'charset': convert.utf8.name});
        final body = transport.HttpBody.fromBytes(
            contentType, convert.utf8.encode('bodyçå®'));
        expect(body.asString(), equals('bodyçå®'));
      });

      test('asString() LATIN1', () {
        final contentType =
            MediaType('application', 'json', {'charset': convert.latin1.name});
        final body = transport.HttpBody.fromBytes(
            contentType, convert.latin1.encode('bodyçå®'));
        expect(body.asString(), equals('bodyçå®'));
      });

      test('asString() ASCII', () {
        final contentType =
            MediaType('application', 'json', {'charset': convert.ascii.name});
        final body = transport.HttpBody.fromBytes(
            contentType, convert.ascii.encode('body'));
        expect(body.asString(), equals('body'));
      });

      test('should throw ResponseFormatException if body cannot be encoded',
          () {
        final contentType =
            MediaType('application', 'json', {'charset': convert.ascii.name});
        final body = transport.HttpBody.fromString(contentType, 'bodyçå®');
        Object exception;
        try {
          body.asBytes();
        } catch (e) {
          exception = e;
        }
        expect(exception, isNotNull,
            reason: 'should throw if body cannot be encoded');
        expect(exception, isA<transport.ResponseFormatException>(),
            reason:
                'should throw ResponseFormatException if body cannot be encoded');
        expect(exception.toString(), contains('Body could not be encoded'));
        expect(exception.toString(), contains('Content-Type: $contentType'));
        expect(
            exception.toString(), contains('Encoding: ${convert.ascii.name}'));
        expect(exception.toString(), contains('bodyçå®'));
      });

      test('should throw ResponseFormatException if bytes cannot be decoded',
          () {
        final contentType =
            MediaType('application', 'json', {'charset': convert.ascii.name});
        final body = transport.HttpBody.fromBytes(
            contentType, convert.utf8.encode('bodyçå®'));
        Object exception;
        try {
          body.asString();
        } catch (e) {
          exception = e;
        }
        expect(exception, isNotNull,
            reason: 'should throw if bytes cannot be decoded');
        expect(exception, isA<transport.ResponseFormatException>(),
            reason:
                'should throw ResponseFormatException if bytes cannot be decoded');
        expect(exception.toString(), contains('Bytes could not be decoded'));
        expect(exception.toString(), contains('Content-Type: $contentType'));
        expect(
            exception.toString(), contains('Encoding: ${convert.ascii.name}'));
        expect(exception.toString(),
            contains(convert.utf8.encode('bodyçå®').toString()));
      });
    });

    group('StreamedHttpBody', () {
      test('should parse encoding from content-type', () {
        final contentType =
            MediaType('text', 'plain', {'charset': convert.ascii.name});
        final body = transport.StreamedHttpBody.fromByteStream(
            contentType, Stream.fromIterable([]));
        expect(body.encoding.name, equals(convert.ascii.name));
      });

      test('should allow a fallback encoding', () {
        final contentType = MediaType('text', 'plain');
        final body = transport.StreamedHttpBody.fromByteStream(
            contentType, Stream.fromIterable([]),
            fallbackEncoding: convert.latin1);
        expect(body.encoding.name, equals(convert.latin1.name));
      });

      test('toBytes()', () async {
        final contentType =
            MediaType('text', 'plain', {'charset': convert.utf8.name});
        final body = transport.StreamedHttpBody.fromByteStream(
            contentType,
            Stream.fromIterable([
              [1, 2],
              [3, 4]
            ]),
            fallbackEncoding: convert.latin1);
        expect(await body.toBytes(), equals(Uint8List.fromList([1, 2, 3, 4])));
      });
    });
  });
}
