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
import 'dart:convert';
import 'dart:typed_data';

import 'package:http_parser/http_parser.dart';
import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart' as transport;

import '../../naming.dart';

void main() {
  final naming = new Naming()
    ..testType = testTypeUnit
    ..topic = topicHttp;

  group(naming.toString(), () {
    group('HttpBody', () {
      test('.fromBytes() ctor should default to empty list', () {
        final contentType = new MediaType('text', 'plain');
        final body = new transport.HttpBody.fromBytes(contentType, null);
        expect(body.asBytes(), isEmpty);
      });

      test('should use encoding if one is explicitly given', () {
        final contentType = new MediaType('text', 'plain');

        final stringBody = new transport.HttpBody.fromString(
            contentType, 'body',
            encoding: ASCII);
        expect(stringBody.encoding, equals(ASCII));

        final bytesBody = new transport.HttpBody.fromBytes(
            contentType, UTF8.encode('body'),
            encoding: ASCII);
        expect(bytesBody.encoding, equals(ASCII));
      });

      test('should parse encoding from content-type', () {
        final contentType =
            new MediaType('text', 'plain', {'charset': ASCII.name});

        final stringBody =
            new transport.HttpBody.fromString(contentType, 'body');
        expect(stringBody.encoding, equals(ASCII));

        final bytesBody =
            new transport.HttpBody.fromBytes(contentType, UTF8.encode('body'));
        expect(bytesBody.encoding, equals(ASCII));
      });

      test('should allow a fallback encoding', () {
        final contentType = new MediaType('text', 'plain');

        final stringBody = new transport.HttpBody.fromString(
            contentType, 'body',
            fallbackEncoding: ASCII);
        expect(stringBody.encoding, equals(ASCII));

        final bytesBody = new transport.HttpBody.fromBytes(
            contentType, UTF8.encode('body'),
            fallbackEncoding: ASCII);
        expect(bytesBody.encoding, equals(ASCII));
      });

      test('should use UTF8 by default', () {
        final contentType = new MediaType('text', 'plain');

        final stringBody =
            new transport.HttpBody.fromString(contentType, 'body');
        expect(stringBody.encoding, equals(UTF8));

        final bytesBody =
            new transport.HttpBody.fromBytes(contentType, UTF8.encode('body'));
        expect(bytesBody.encoding, equals(UTF8));
      });

      test('content-length should be calculated automaticlaly', () {
        final contentType = new MediaType('text', 'plain');
        final body =
            new transport.HttpBody.fromBytes(contentType, [1, 2, 3, 4]);
        expect(body.contentLength, equals(4));
      });

      test('asBytes() UTF8', () {
        final contentType =
            new MediaType('text', 'plain', {'charset': UTF8.name});
        final body = new transport.HttpBody.fromString(contentType, 'bodyçå®');
        final encoded = new Uint8List.fromList(UTF8.encode('bodyçå®'));
        expect(body.asBytes(), equals(encoded));
      });

      test('asBytes() LATIN1', () {
        final contentType =
            new MediaType('text', 'plain', {'charset': LATIN1.name});
        final body = new transport.HttpBody.fromString(contentType, 'bodyçå®');
        final encoded = new Uint8List.fromList(LATIN1.encode('bodyçå®'));
        expect(body.asBytes(), equals(encoded));
      });

      test('asBytes() ASCII', () {
        final contentType =
            new MediaType('text', 'plain', {'charset': ASCII.name});
        final body = new transport.HttpBody.fromString(contentType, 'body');
        final encoded = new Uint8List.fromList(ASCII.encode('body'));
        expect(body.asBytes(), equals(encoded));
      });

      test('asJson() UTF8', () {
        final contentType =
            new MediaType('application', 'json', {'charset': UTF8.name});
        final bodyJson = <Map<String, String>>[
          {'foo': 'bar', 'baz': 'çå®"'}
        ];
        final body = new transport.HttpBody.fromBytes(
            contentType, UTF8.encode(JSON.encode(bodyJson)));
        expect(body.asJson(), equals(bodyJson));
      });

      test('asJson() LATIN1', () {
        final contentType =
            new MediaType('application', 'json', {'charset': LATIN1.name});
        final bodyJson = <Map<String, String>>[
          {'foo': 'bar', 'baz': 'çå®"'}
        ];
        final body = new transport.HttpBody.fromBytes(
            contentType, LATIN1.encode(JSON.encode(bodyJson)));
        expect(body.asJson(), equals(bodyJson));
      });

      test('asJson() ASCII', () {
        final contentType =
            new MediaType('application', 'json', {'charset': ASCII.name});
        final bodyJson = <Map<String, String>>[
          {'foo': 'bar', 'bar': 'baz'}
        ];
        final body = new transport.HttpBody.fromBytes(
            contentType, ASCII.encode(JSON.encode(bodyJson)));
        expect(body.asJson(), equals(bodyJson));
      });

      test('asString() UTF8', () {
        final contentType =
            new MediaType('application', 'json', {'charset': UTF8.name});
        final body = new transport.HttpBody.fromBytes(
            contentType, UTF8.encode('bodyçå®'));
        expect(body.asString(), equals('bodyçå®'));
      });

      test('asString() LATIN1', () {
        final contentType =
            new MediaType('application', 'json', {'charset': LATIN1.name});
        final body = new transport.HttpBody.fromBytes(
            contentType, LATIN1.encode('bodyçå®'));
        expect(body.asString(), equals('bodyçå®'));
      });

      test('asString() ASCII', () {
        final contentType =
            new MediaType('application', 'json', {'charset': ASCII.name});
        final body =
            new transport.HttpBody.fromBytes(contentType, ASCII.encode('body'));
        expect(body.asString(), equals('body'));
      });

      test('should throw ResponseFormatException if body cannot be encoded',
          () {
        final contentType =
            new MediaType('application', 'json', {'charset': ASCII.name});
        final body = new transport.HttpBody.fromString(contentType, 'bodyçå®');
        Object exception;
        try {
          body.asBytes();
        } catch (e) {
          exception = e;
        }
        expect(exception, isNotNull,
            reason: 'should throw if body cannot be encoded');
        expect(exception, new isInstanceOf<transport.ResponseFormatException>(),
            reason:
                'should throw ResponseFormatException if body cannot be encoded');
        expect(exception.toString(), contains('Body could not be encoded'));
        expect(exception.toString(), contains('Content-Type: $contentType'));
        expect(exception.toString(), contains('Encoding: ${ASCII.name}'));
        expect(exception.toString(), contains('bodyçå®'));
      });

      test('should throw ResponseFormatException if bytes cannot be decoded',
          () {
        final contentType =
            new MediaType('application', 'json', {'charset': ASCII.name});
        final body = new transport.HttpBody.fromBytes(
            contentType, UTF8.encode('bodyçå®'));
        Object exception;
        try {
          body.asString();
        } catch (e) {
          exception = e;
        }
        expect(exception, isNotNull,
            reason: 'should throw if bytes cannot be decoded');
        expect(exception, new isInstanceOf<transport.ResponseFormatException>(),
            reason:
                'should throw ResponseFormatException if bytes cannot be decoded');
        expect(exception.toString(), contains('Bytes could not be decoded'));
        expect(exception.toString(), contains('Content-Type: $contentType'));
        expect(exception.toString(), contains('Encoding: ${ASCII.name}'));
        expect(
            exception.toString(), contains(UTF8.encode('bodyçå®').toString()));
      });
    });

    group('StreamedHttpBody', () {
      test('should parse encoding from content-type', () {
        final contentType =
            new MediaType('text', 'plain', {'charset': ASCII.name});
        final body = new transport.StreamedHttpBody.fromByteStream(
            contentType, new Stream.fromIterable([]));
        expect(body.encoding.name, equals(ASCII.name));
      });

      test('should allow a fallback encoding', () {
        final contentType = new MediaType('text', 'plain');
        final body = new transport.StreamedHttpBody.fromByteStream(
            contentType, new Stream.fromIterable([]),
            fallbackEncoding: LATIN1);
        expect(body.encoding.name, equals(LATIN1.name));
      });

      test('toBytes()', () async {
        final contentType =
            new MediaType('text', 'plain', {'charset': UTF8.name});
        final body = new transport.StreamedHttpBody.fromByteStream(
            contentType,
            new Stream.fromIterable([
              [1, 2],
              [3, 4]
            ]),
            fallbackEncoding: LATIN1);
        expect(
            await body.toBytes(), equals(new Uint8List.fromList([1, 2, 3, 4])));
      });
    });
  });
}
