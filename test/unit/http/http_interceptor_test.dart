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
import 'package:http_parser/http_parser.dart';
import 'package:test/test.dart';
import 'package:w_transport/mock.dart';
import 'package:w_transport/w_transport.dart' as transport;

import 'package:w_transport/src/http/http_interceptor.dart' show Pathway;

import '../../naming.dart';

void main() {
  final naming = Naming()
    ..testType = testTypeUnit
    ..topic = topicHttp;

  group(naming.toString(), () {
    group('HttpInterceptor', () {
      setUp(() {
        MockTransports.install();
      });

      tearDown(() async {
        MockTransports.verifyNoOutstandingExceptions();
        await MockTransports.uninstall();
      });

      test('default implementations should not modify the payloads', () async {
        final req = transport.Request()..uri = Uri.parse('/test');
        final body =
            transport.HttpBody.fromString(MediaType('text', 'plain'), 'body');
        final finalizedReq = FinalizedRequest('GET', req.uri, {}, body, false);
        final resp = MockResponse.ok();
        final reqPayload = transport.RequestPayload(transport.Request());
        final respPayload = transport.ResponsePayload(finalizedReq, resp);

        final interceptor = transport.HttpInterceptor();
        expect(
            identical(
                reqPayload, await interceptor.interceptRequest(reqPayload)),
            isTrue);
        expect(
            identical(
                respPayload, await interceptor.interceptResponse(respPayload)),
            isTrue);
      });
    });

    group('Pathway', () {
      test('waits for Futures to resolve', () async {
        final pathway = Pathway<String>();
        pathway.addInterceptor((String input) async => input * 2);
        pathway.addInterceptor((String input) async => input + 'b');
        final result = await pathway.process('a');
        expect(result, equals('aab'));
      });

      test('handles values returned immediately (no Future)', () async {
        final pathway = Pathway<String>();
        pathway.addInterceptor((String input) => input * 2);
        pathway.addInterceptor((String input) => input + 'b');
        final result = await pathway.process('a');
        expect(result, equals('aab'));
      });

      test('handles a mix of immediate values and Futures', () async {
        final pathway = Pathway<String>();
        pathway.addInterceptor((String input) async => input * 2);
        pathway.addInterceptor((String input) => input + 'b');
        final result = await pathway.process('a');
        expect(result, equals('aab'));
      });

      test('throws if an invalid value is returned', () async {
        final pathway = Pathway<String>();
        pathway.addInterceptor((String input) async => input * 2);
        pathway.addInterceptor((String input) => input + 'b');
        pathway.addInterceptor((String input) => 10);
        expect(pathway.process('a'), throwsException);
      });
    });
  });
}
