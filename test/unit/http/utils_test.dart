library w_transport.test.unit.http.utils_test;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:test/test.dart';

import 'package:w_transport/src/http/utils.dart' as http_utils;

void main() {
  group('HTTP utils', () {

    test('isAsciiOnly()', () {
      expect(http_utils.isAsciiOnly('abc'), isTrue);
      expect(http_utils.isAsciiOnly('abç'), isFalse);
    });

    test('mapToQuery() with default encoding (UTF8)', () {
      var map = {
        'foo': 'bar',
        'count': '10',
        'sentence': 'words with spaces',
        'chars': 'ç%/\\{].+"\''
      };
      var expected = [
        'foo=bar',
        'count=10',
        'sentence=words+with+spaces',
        'chars=%C3%A7%25%2F%5C%7B%5D.%2B%22%27'
      ].join('&');
      expect(http_utils.mapToQuery(map), equals(expected));
    });

    test('mapToQuery() with non-default encoding (LATIN1)', () {
      var map = {
        'foo': 'bar',
        'count': '10',
        'sentence': 'words with spaces',
        'chars': 'ç%/\\{].+"\''
      };
      var expected = [
        'foo=bar',
        'count=10',
        'sentence=words+with+spaces',
        'chars=%E7%25%2F%5C%7B%5D.%2B%22%27'
      ].join('&');
      expect(http_utils.mapToQuery(map, encoding: LATIN1), equals(expected));
    });

    test('queryToMap() with default encoding (UTF8)', () {
      var query = [
        'foo=bar',
        'count=10',
        'sentence=words+with+spaces',
        'chars=%C3%A7%25%2F%5C%7B%5D.%2B%22%27'
      ].join('&');
      var expected = {
        'foo': 'bar',
        'count': '10',
        'sentence': 'words with spaces',
        'chars': 'ç%/\\{].+"\''
      };
      expect(http_utils.queryToMap(query), equals(expected));
    });

    test('queryToMap() with default encoding (UTF8)', () {
      var query = [
        'foo=bar',
        'count=10',
        'sentence=words+with+spaces',
        'chars=%E7%25%2F%5C%7B%5D.%2B%22%27'
      ].join('&');
      var expected = {
        'foo': 'bar',
        'count': '10',
        'sentence': 'words with spaces',
        'chars': 'ç%/\\{].+"\''
      };
      expect(http_utils.queryToMap(query, encoding: LATIN1), equals(expected));
    });

    test('parseContentTypeFromHeaders()', () {
      var headers = {'content-type': 'text/plain'};
      MediaType ct = http_utils.parseContentTypeFromHeaders(headers);
      expect(ct.mimeType, equals('text/plain'));
      expect(ct.parameters, isEmpty);
    });

    test('parseContentTypeFromHeaders() no content-type header', () {
      var headers = {};
      MediaType ct = http_utils.parseContentTypeFromHeaders(headers);
      expect(ct.mimeType, equals('application/octet-stream'), reason: 'application/octet-stream content-type should be assumed if header is missing.');
      expect(ct.parameters, isEmpty);
    });

    test('parseContentTypeFromHeaders() case mismatch', () {
      var headers = {'cOntEnt-tYPe': 'text/plain'};
      MediaType ct = http_utils.parseContentTypeFromHeaders(headers);
      expect(ct.mimeType, equals('text/plain'));
      expect(ct.parameters, isEmpty);
    });

    test('parseContentTypeFromHeaders() with parameters', () {
      var headers = {'content-type': 'text/plain; charset=utf-8'};
      MediaType ct = http_utils.parseContentTypeFromHeaders(headers);
      expect(ct.mimeType, equals('text/plain'));
      expect(ct.parameters, containsPair('charset', 'utf-8'));
    });

    test('parseEncodingFromContentType()', () {
      MediaType ct;
      ct = new MediaType('text', 'plain', {'charset': UTF8.name});
      expect(http_utils.parseEncodingFromContentType(ct), equals(UTF8));
      ct = new MediaType('text', 'plain', {'charset': LATIN1.name});
      expect(http_utils.parseEncodingFromContentType(ct), equals(LATIN1));
    });

    test('parseEncodingFromContentType() no charset', () {
      MediaType ct = new MediaType('text', 'plain');
      expect(http_utils.parseEncodingFromContentType(ct, fallback: ASCII), equals(ASCII));
    });

    test('parseEncodingFromContentType() null content-type', () {
      expect(http_utils.parseEncodingFromContentType(null, fallback: ASCII), equals(ASCII));
    });

    test('parseEncodingFromContentType() unrecognized charset', () {
      MediaType ct = new MediaType('text', 'plain', {'charset': 'unknown'});
      expect(http_utils.parseEncodingFromContentType(ct, fallback: ASCII), equals(ASCII));
    });

    test('parseEncodingFromContentTypeOrFail()', () {
      MediaType ct;
      ct = new MediaType('text', 'plain', {'charset': UTF8.name});
      expect(http_utils.parseEncodingFromContentTypeOrFail(ct), equals(UTF8));
      ct = new MediaType('text', 'plain', {'charset': LATIN1.name});
      expect(http_utils.parseEncodingFromContentTypeOrFail(ct), equals(LATIN1));
    });

    test('parseEncodingFromContentTypeOrFail() no charset', () {
      MediaType ct = new MediaType('text', 'plain');
      expect(() {
        http_utils.parseEncodingFromContentTypeOrFail(ct);
      }, throwsFormatException);
    });

    test('parseEncodingFromContentTypeOrFail() null content-type', () {
      expect(() {
        http_utils.parseEncodingFromContentTypeOrFail(null);
      }, throwsFormatException);
    });

    test('parseEncodingFromContentTypeOrFail() unrecognized charset', () {
      MediaType ct = new MediaType('text', 'plain', {'charset': 'unknown'});
      expect(() {
        http_utils.parseEncodingFromContentTypeOrFail(ct);
      }, throwsFormatException);
    });

    test('parseEncodingFromHeaders()', () {
      var headers;
      headers = {'content-type': 'text/plain; charset=utf-8'};
      expect(http_utils.parseEncodingFromHeaders(headers), equals(UTF8));
      headers = {'content-type': 'text/plain; charset=iso-8859-1'};
      expect(http_utils.parseEncodingFromHeaders(headers), equals(LATIN1));
    });

    test('parseEncodingFromHeaders() case mismatch', () {
      var headers = {'cOnteNt-tYPe': 'text/plain; charset=utf-8'};
      expect(http_utils.parseEncodingFromHeaders(headers), equals(UTF8));
    });

    test('parseEncodingFromHeaders() no charset', () {
      var headers = {'content-type': 'text/plain'};
      expect(http_utils.parseEncodingFromHeaders(headers, fallback: ASCII), equals(ASCII));
    });

    test('parseEncodingFromHeaders() no content-type', () {
      var headers = {};
      expect(http_utils.parseEncodingFromHeaders(headers, fallback: ASCII), equals(ASCII));
    });

    test('parseEncodingFromHeaders() unrecognized charset', () {
      var headers = {'content-type': 'text/plain; charset=unknown'};
      expect(http_utils.parseEncodingFromHeaders(headers, fallback: ASCII), equals(ASCII));
    });

    test('reduceByteStream()', () async {
      Stream byteStream = new Stream.fromIterable([
        [1, 2, 3],
        [4, 5],
        [6, 7, 8]
      ]);
      var expected = new Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);
      expect(await http_utils.reduceByteStream(byteStream), equals(expected));
    });

    test('reduceByteStream() empty', () async {
      Stream byteStream = new Stream.fromIterable([]);
      expect(await http_utils.reduceByteStream(byteStream), isEmpty);
    });

    test('reduceByteStream() single element', () async {
      Stream byteStream = new Stream.fromIterable([[1, 2]]);
      var expected = new Uint8List.fromList([1, 2]);
      expect(await http_utils.reduceByteStream(byteStream), equals(expected));
    });

    test('ByteStreamProgressListener', () async {
      Stream byteStream = new Stream.fromIterable([
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9, 10]
      ]);
      var listener = new http_utils.ByteStreamProgressListener(byteStream, total: 10);

      var chunks = [];
      await for (var chunk in listener.byteStream) {
        chunks.add(chunk);
      }
      expect(chunks, equals([
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9, 10]
      ]));

      var progressEvents = await listener.progressStream.toList();
      expect(progressEvents.length, equals(3));
      expect(progressEvents[0].percent, equals(30.0));
      expect(progressEvents[1].percent, equals(60.0));
      expect(progressEvents[2].percent, equals(100.0));
    });

    test('ByteStreamProgressListener pause/resume', () async {
      Stream byteStream = new Stream.fromIterable([
        [1, 2, 3],
        [4, 5, 6],
      ]);
      var listener = new http_utils.ByteStreamProgressListener(byteStream);

      Completer done = new Completer();
      StreamSubscription sub = listener.byteStream.listen((_) {}, onDone: done.complete);
      sub.pause();
      sub.resume();
      await done.future;
    });

  });
}