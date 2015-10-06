library w_transport.test.unit.http.http_body_test;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';

void main() {
  group('HttpBody', () {
    test('.fromBytes() ctor should default to empty list', () {
      MediaType contentType = new MediaType('text', 'plain');
      HttpBody body = new HttpBody.fromBytes(contentType, null);
      expect(body.asBytes(), isEmpty);
    });

    test('should parse encoding from content-type', () {
      MediaType contentType =
          new MediaType('text', 'plain', {'charset': ASCII.name});
      HttpBody body = new HttpBody.fromString(contentType, 'body');
      expect(body.encoding.name, equals(ASCII.name));
    });

    test('should allow a fallback encoding', () {
      MediaType contentType = new MediaType('text', 'plain');
      HttpBody body = new HttpBody.fromString(contentType, 'body',
          fallbackEncoding: LATIN1);
      expect(body.encoding.name, equals(LATIN1.name));
    });

    test('content-length should be calculated automaticlaly', () {
      MediaType contentType = new MediaType('text', 'plain');
      HttpBody body = new HttpBody.fromBytes(contentType, [1, 2, 3, 4]);
      expect(body.contentLength, equals(4));
    });

    test('asBytes() UTF8', () {
      MediaType contentType =
          new MediaType('text', 'plain', {'charset': UTF8.name});
      HttpBody body = new HttpBody.fromString(contentType, 'bodyçå®');
      Uint8List encoded = new Uint8List.fromList(UTF8.encode('bodyçå®'));
      expect(body.asBytes(), equals(encoded));
    });

    test('asBytes() LATIN1', () {
      MediaType contentType =
          new MediaType('text', 'plain', {'charset': LATIN1.name});
      HttpBody body = new HttpBody.fromString(contentType, 'bodyçå®');
      Uint8List encoded = new Uint8List.fromList(LATIN1.encode('bodyçå®'));
      expect(body.asBytes(), equals(encoded));
    });

    test('asBytes() ASCII', () {
      MediaType contentType =
          new MediaType('text', 'plain', {'charset': ASCII.name});
      HttpBody body = new HttpBody.fromString(contentType, 'body');
      Uint8List encoded = new Uint8List.fromList(ASCII.encode('body'));
      expect(body.asBytes(), equals(encoded));
    });

    test('asJson() UTF8', () {
      MediaType contentType =
          new MediaType('application', 'json', {'charset': UTF8.name});
      var bodyJson = [
        {'foo': 'bar', 'baz': 'çå®"'}
      ];
      HttpBody body = new HttpBody.fromBytes(
          contentType, UTF8.encode(JSON.encode(bodyJson)));
      expect(body.asJson(), equals(bodyJson));
    });

    test('asJson() LATIN1', () {
      MediaType contentType =
          new MediaType('application', 'json', {'charset': LATIN1.name});
      var bodyJson = [
        {'foo': 'bar', 'baz': 'çå®"'}
      ];
      HttpBody body = new HttpBody.fromBytes(
          contentType, LATIN1.encode(JSON.encode(bodyJson)));
      expect(body.asJson(), equals(bodyJson));
    });

    test('asJson() ASCII', () {
      MediaType contentType =
          new MediaType('application', 'json', {'charset': ASCII.name});
      var bodyJson = [
        {'foo': 'bar', 'bar': 'baz'}
      ];
      HttpBody body = new HttpBody.fromBytes(
          contentType, ASCII.encode(JSON.encode(bodyJson)));
      expect(body.asJson(), equals(bodyJson));
    });

    test('asString() UTF8', () {
      MediaType contentType =
          new MediaType('application', 'json', {'charset': UTF8.name});
      HttpBody body =
          new HttpBody.fromBytes(contentType, UTF8.encode('bodyçå®'));
      expect(body.asString(), equals('bodyçå®'));
    });

    test('asString() LATIN1', () {
      MediaType contentType =
          new MediaType('application', 'json', {'charset': LATIN1.name});
      HttpBody body =
          new HttpBody.fromBytes(contentType, LATIN1.encode('bodyçå®'));
      expect(body.asString(), equals('bodyçå®'));
    });

    test('asString() ASCII', () {
      MediaType contentType =
          new MediaType('application', 'json', {'charset': ASCII.name});
      HttpBody body = new HttpBody.fromBytes(contentType, ASCII.encode('body'));
      expect(body.asString(), equals('body'));
    });
  });

  group('StreamedHttpBody', () {
    test('should parse encoding from content-type', () {
      MediaType contentType =
          new MediaType('text', 'plain', {'charset': ASCII.name});
      StreamedHttpBody body = new StreamedHttpBody.fromByteStream(
          contentType, new Stream.fromIterable([]));
      expect(body.encoding.name, equals(ASCII.name));
    });

    test('should allow a fallback encoding', () {
      MediaType contentType = new MediaType('text', 'plain');
      StreamedHttpBody body = new StreamedHttpBody.fromByteStream(
          contentType, new Stream.fromIterable([]),
          fallbackEncoding: LATIN1);
      expect(body.encoding.name, equals(LATIN1.name));
    });

    test('toBytes()', () async {
      MediaType contentType =
          new MediaType('text', 'plain', {'charset': UTF8.name});
      StreamedHttpBody body = new StreamedHttpBody.fromByteStream(
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
}
