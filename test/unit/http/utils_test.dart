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
import 'dart:math';
import 'dart:typed_data';

import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:w_transport/mock.dart';
import 'package:w_transport/src/http/auto_retry.dart';
import 'package:w_transport/w_transport.dart' as transport;

import 'package:w_transport/src/http/utils.dart' as http_utils;
import 'package:w_transport/w_transport.dart';

import '../../naming.dart';

class MockRandom extends Mock implements Random {}

void main() {
  final naming = Naming()
    ..testType = testTypeUnit
    ..topic = topicHttp;

  group(naming.toString(), () {
    group('HTTP utils', () {
      group('calculateBackoff()', () {
        setUp(() {
          MockTransports.install();
        });

        tearDown(() async {
          MockTransports.verifyNoOutstandingExceptions();
          await MockTransports.uninstall();
        });

        group('advanced jitter', () {
          Request request;
          final random = MockRandom();
          // Return the mean/median value of this random so we have a deterministic output
          when(random.nextDouble()).thenReturn(0.5);

          void expectBackOffOf(int backOffInMs) {
                expect(
                    http_utils
                        .calculateBackOff(request.autoRetry, random: random)
                        .inMilliseconds,
                    equals(backOffInMs));
          }

          tearDown(() {
            request = null;
          });

          test('produces expected delays without hitting maxInterval', () async {
            request = transport.Request();
            final interval = Duration(seconds: 1);
            final maxInterval = Duration(seconds: 15);
            request.autoRetry.backOff = transport.RetryBackOff.exponential(
                interval,
                jitter: RetryJitterMethod.advanced,
                maxInterval: maxInterval);

            for (int i = 1; i <= 5; i++) {
              // We start at 1, since the advanced backoff/jitter algorithm
              // only activates once we've had one attempt, so it expects
              // `numAttempts` to be at least 1
              request.autoRetry.numAttempts = i;

              switch (i) {
                case 1:
                  expectBackOffOf(897);
                  break;
                case 2:
                  expectBackOffOf(1093);
                  break;
                case 3:
                  expectBackOffOf(2035);
                  break;
                case 4:
                  expectBackOffOf(4045);
                  break;
                case 5:
                  expectBackOffOf(8083);
                  break;
              }
            }
          });
        });

        group('exponential', () {
          test('maxInterval should not be exceeded (no jitter)', () async {
            final request = transport.Request();
            final interval = Duration(milliseconds: 5);
            final maxInterval = Duration(milliseconds: 400);
            request.autoRetry.backOff = transport.RetryBackOff.exponential(
                interval,
                maxInterval: maxInterval);

            for (int i = 0; i < 5; i++) {
              request.autoRetry.numAttempts = i;

              if (i == 0) {
                expect(
                    http_utils
                        .calculateBackOff(request.autoRetry)
                        .inMilliseconds,
                    equals(interval.inMilliseconds));
              } else {
                expect(
                    http_utils
                        .calculateBackOff(request.autoRetry)
                        .inMilliseconds,
                    equals(interval.inMilliseconds *
                        pow(2, request.autoRetry.numAttempts)));
              }
            }
          });

          test('maxInterval should not be exceeded (with full jitter)', () async {
            final request = transport.Request();
            final interval = Duration(milliseconds: 5);
            final maxInterval = Duration(milliseconds: 400);
            request.autoRetry.backOff = transport.RetryBackOff.exponential(
                interval,
                withJitter: true,
                maxInterval: maxInterval);

            for (int i = 0; i < 5; i++) {
              request.autoRetry.numAttempts = i;

              if (i == 0) {
                expect(
                    http_utils
                        .calculateBackOff(request.autoRetry)
                        .inMilliseconds,
                    lessThanOrEqualTo(interval.inMilliseconds));
              } else {
                expect(
                    http_utils
                        .calculateBackOff(request.autoRetry)
                        .inMilliseconds,
                    lessThanOrEqualTo(interval.inMilliseconds *
                        pow(2, request.autoRetry.numAttempts)));
              }
            }
          });

          test('maxInterval should be exceeded (no jitter)', () async {
            final request = transport.Request();
            final interval = Duration(milliseconds: 5);
            final maxInterval = Duration(milliseconds: 20);
            const withJitter = false;
            request.autoRetry.backOff = transport.RetryBackOff.exponential(
                interval,
                withJitter: withJitter,
                maxInterval: maxInterval);

            for (int i = 0; i < 5; i++) {
              request.autoRetry.numAttempts = i;

              if (i == 0) {
                expect(
                    http_utils
                        .calculateBackOff(request.autoRetry)
                        .inMilliseconds,
                    equals(interval.inMilliseconds));
              } else if (i == 1) {
                expect(
                    http_utils
                        .calculateBackOff(request.autoRetry)
                        .inMilliseconds,
                    equals(10));
              } else {
                expect(
                    http_utils
                        .calculateBackOff(request.autoRetry)
                        .inMilliseconds,
                    equals(
                        request.autoRetry.backOff.maxInterval.inMilliseconds));
              }
            }
          });

          test('maxInterval should be exceeded (with jitter)', () async {
            final request = transport.Request();
            final interval = Duration(milliseconds: 5);
            final maxInterval = Duration(milliseconds: 20);
            const withJitter = true;
            request.autoRetry.backOff = transport.RetryBackOff.exponential(
                interval,
                withJitter: withJitter,
                maxInterval: maxInterval);

            for (int i = 0; i < 50; i++) {
              request.autoRetry.numAttempts = i;

              if (i == 0) {
                expect(
                    http_utils
                        .calculateBackOff(request.autoRetry)
                        .inMilliseconds,
                    lessThanOrEqualTo(interval.inMilliseconds));
              } else if (i == 1) {
                expect(
                    http_utils
                        .calculateBackOff(request.autoRetry)
                        .inMilliseconds,
                    lessThanOrEqualTo(
                        request.autoRetry.backOff.maxInterval.inMilliseconds));
              } else {
                expect(
                    http_utils
                        .calculateBackOff(request.autoRetry)
                        .inMilliseconds,
                    lessThanOrEqualTo(
                        request.autoRetry.backOff.maxInterval.inMilliseconds));
              }
            }
          });
        });

        group('fixed', () {
          test('no jitter', () async {
            final request = transport.Request();
            final interval = Duration(milliseconds: 5);
            const withJitter = false;
            request.autoRetry.backOff =
                transport.RetryBackOff.fixed(interval, withJitter: withJitter);

            for (int i = 0; i < 5; i++) {
              request.autoRetry.numAttempts = i;

              if (i == 0) {
                expect(
                    http_utils
                        .calculateBackOff(request.autoRetry)
                        .inMilliseconds,
                    equals(interval.inMilliseconds));
              }
            }
          });

          test('with jitter', () async {
            final request = transport.Request();
            final interval = Duration(milliseconds: 5);
            const withJitter = true;
            request.autoRetry.backOff =
                transport.RetryBackOff.fixed(interval, withJitter: withJitter);

            for (int i = 0; i < 5; i++) {
              final backOff =
                  http_utils.calculateBackOff(request.autoRetry).inMilliseconds;
              expect(backOff, lessThanOrEqualTo(interval.inMilliseconds * 1.5));
              expect(
                  backOff, greaterThanOrEqualTo(interval.inMilliseconds ~/ 2));
            }
          });
        });
      });

      test('isAsciiOnly()', () {
        expect(http_utils.isAsciiOnly('abc'), isTrue);
        expect(http_utils.isAsciiOnly('abç'), isFalse);
      });

      test('mapToQuery() with default encoding (UTF8)', () {
        final map = <String, String>{
          'foo': 'bar',
          'count': '10',
          'sentence': 'words with spaces',
          'chars': 'ç%/\\{].+"\''
        };
        final expected = <String>[
          'foo=bar',
          'count=10',
          'sentence=words+with+spaces',
          'chars=%C3%A7%25%2F%5C%7B%5D.%2B%22%27'
        ].join('&');
        expect(http_utils.mapToQuery(map), equals(expected));
      });

      test('mapToQuery() with non-default encoding (LATIN1)', () {
        final map = <String, String>{
          'foo': 'bar',
          'count': '10',
          'sentence': 'words with spaces',
          'chars': 'ç%/\\{].+"\''
        };
        final expected = <String>[
          'foo=bar',
          'count=10',
          'sentence=words+with+spaces',
          'chars=%E7%25%2F%5C%7B%5D.%2B%22%27'
        ].join('&');
        expect(http_utils.mapToQuery(map, encoding: latin1), equals(expected));
      });

      test('queryToMap() with default encoding (UTF8)', () {
        final query = <String>[
          'foo=bar',
          'count=10',
          'sentence=words+with+spaces',
          'chars=%C3%A7%25%2F%5C%7B%5D.%2B%22%27'
        ].join('&');
        final expected = <String, String>{
          'foo': 'bar',
          'count': '10',
          'sentence': 'words with spaces',
          'chars': 'ç%/\\{].+"\''
        };
        expect(http_utils.queryToMap(query), equals(expected));
      });

      test('queryToMap() with default encoding (UTF8)', () {
        final query = <String>[
          'foo=bar',
          'count=10',
          'sentence=words+with+spaces',
          'chars=%E7%25%2F%5C%7B%5D.%2B%22%27'
        ].join('&');
        final expected = <String, String>{
          'foo': 'bar',
          'count': '10',
          'sentence': 'words with spaces',
          'chars': 'ç%/\\{].+"\''
        };
        expect(
            http_utils.queryToMap(query, encoding: latin1), equals(expected));
      });

      test('parseContentTypeFromHeaders()', () {
        final headers = <String, String>{'content-type': 'text/plain'};
        final ct = http_utils.parseContentTypeFromHeaders(headers);
        expect(ct.mimeType, equals('text/plain'));
        expect(ct.parameters, isEmpty);
      });

      test('parseContentTypeFromHeaders() no content-type header', () {
        final headers = <String, String>{};
        final ct = http_utils.parseContentTypeFromHeaders(headers);
        expect(ct.mimeType, equals('application/octet-stream'),
            reason:
                'application/octet-stream content-type should be assumed if header is missing.');
        expect(ct.parameters, isEmpty);
      });

      test('parseContentTypeFromHeaders() case mismatch', () {
        final headers = <String, String>{'cOntEnt-tYPe': 'text/plain'};
        final ct = http_utils.parseContentTypeFromHeaders(headers);
        expect(ct.mimeType, equals('text/plain'));
        expect(ct.parameters, isEmpty);
      });

      test('parseContentTypeFromHeaders() with parameters', () {
        final headers = <String, String>{
          'content-type': 'text/plain; charset=utf-8'
        };
        final ct = http_utils.parseContentTypeFromHeaders(headers);
        expect(ct.mimeType, equals('text/plain'));
        expect(ct.parameters, containsPair('charset', 'utf-8'));
      });

      test('parseEncodingFromContentType()', () {
        MediaType ct;
        ct = MediaType('text', 'plain', {'charset': utf8.name});
        expect(http_utils.parseEncodingFromContentType(ct), equals(utf8));
        ct = MediaType('text', 'plain', {'charset': latin1.name});
        expect(http_utils.parseEncodingFromContentType(ct), equals(latin1));
      });

      test('parseEncodingFromContentType() no charset', () {
        final ct = MediaType('text', 'plain');
        expect(http_utils.parseEncodingFromContentType(ct, fallback: ascii),
            equals(ascii));
      });

      test('parseEncodingFromContentType() null content-type', () {
        expect(http_utils.parseEncodingFromContentType(null, fallback: ascii),
            equals(ascii));
      });

      test('parseEncodingFromContentType() unrecognized charset', () {
        final ct = MediaType('text', 'plain', {'charset': 'unknown'});
        expect(http_utils.parseEncodingFromContentType(ct, fallback: ascii),
            equals(ascii));
      });

      test('parseEncodingFromContentTypeOrFail()', () {
        MediaType ct;
        ct = MediaType('text', 'plain', {'charset': utf8.name});
        expect(http_utils.parseEncodingFromContentTypeOrFail(ct), equals(utf8));
        ct = MediaType('text', 'plain', {'charset': latin1.name});
        expect(
            http_utils.parseEncodingFromContentTypeOrFail(ct), equals(latin1));
      });

      test('parseEncodingFromContentTypeOrFail() no charset', () {
        final ct = MediaType('text', 'plain');
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
        final ct = MediaType('text', 'plain', {'charset': 'unknown'});
        expect(() {
          http_utils.parseEncodingFromContentTypeOrFail(ct);
        }, throwsFormatException);
      });

      test('parseEncodingFromHeaders()', () {
        Map<String, String> headers;
        headers = {'content-type': 'text/plain; charset=utf-8'};
        expect(http_utils.parseEncodingFromHeaders(headers), equals(utf8));
        headers = {'content-type': 'text/plain; charset=iso-8859-1'};
        expect(http_utils.parseEncodingFromHeaders(headers), equals(latin1));
      });

      test('parseEncodingFromHeaders() case mismatch', () {
        final headers = <String, String>{
          'cOnteNt-tYPe': 'text/plain; charset=utf-8'
        };
        expect(http_utils.parseEncodingFromHeaders(headers), equals(utf8));
      });

      test('parseEncodingFromHeaders() no charset', () {
        final headers = <String, String>{'content-type': 'text/plain'};
        expect(http_utils.parseEncodingFromHeaders(headers, fallback: ascii),
            equals(ascii));
      });

      test('parseEncodingFromHeaders() no content-type', () {
        final headers = <String, String>{};
        expect(http_utils.parseEncodingFromHeaders(headers, fallback: ascii),
            equals(ascii));
      });

      test('parseEncodingFromHeaders() unrecognized charset', () {
        final headers = <String, String>{
          'content-type': 'text/plain; charset=unknown'
        };
        expect(http_utils.parseEncodingFromHeaders(headers, fallback: ascii),
            equals(ascii));
      });

      test('reduceByteStream()', () async {
        final byteStream = Stream.fromIterable([
          [1, 2, 3],
          [4, 5],
          [6, 7, 8]
        ]);
        final expected = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);
        expect(await http_utils.reduceByteStream(byteStream), equals(expected));
      });

      test('reduceByteStream() empty', () async {
        final byteStream = Stream<List<int>>.fromIterable([]);
        expect(await http_utils.reduceByteStream(byteStream), isEmpty);
      });

      test('reduceByteStream() single element', () async {
        final byteStream = Stream.fromIterable([
          [1, 2]
        ]);
        final expected = Uint8List.fromList([1, 2]);
        expect(await http_utils.reduceByteStream(byteStream), equals(expected));
      });

      test('ByteStreamProgressListener', () async {
        final byteStream = Stream.fromIterable([
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9, 10]
        ]);
        final listener =
            http_utils.ByteStreamProgressListener(byteStream, total: 10);

        final chunks = <List<int>>[];
        await for (final chunk in listener.byteStream) {
          chunks.add(chunk);
        }
        expect(
            chunks,
            equals([
              [1, 2, 3],
              [4, 5, 6],
              [7, 8, 9, 10]
            ]));

        final progressEvents = await listener.progressStream.toList();
        expect(progressEvents.length, equals(3));
        expect(progressEvents[0].percent, equals(30.0));
        expect(progressEvents[1].percent, equals(60.0));
        expect(progressEvents[2].percent, equals(100.0));
      });

      test('ByteStreamProgressListener pause/resume', () async {
        final byteStream = Stream.fromIterable([
          [1, 2, 3],
          [4, 5, 6],
        ]);
        final listener = http_utils.ByteStreamProgressListener(byteStream);

        final done = Completer<Null>();
        final sub = listener.byteStream.listen((_) {}, onDone: done.complete);
        sub.pause();
        sub.resume();
        await done.future;
        await sub.cancel();
      });
    });
  });
}
