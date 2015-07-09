library w_transport.test.mock_w_response_test;

import 'dart:async';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart'
    show WHttpException, WRequest, WResponse;
import 'package:w_transport/mocks.dart' show MockWRequest, MockWResponse;

void main() {
  group('MockWResponse', () {
    test('status should be mockable', () {
      expect(new MockWResponse(300).status, equals(300));
    });

    test('statusText should be mockable', () {
      expect(new MockWResponse.ok(statusText: 'GREAT').statusText,
          equals('GREAT'));
    });

    test('headers should be mockable', () {
      WResponse response =
          new MockWResponse.ok(headers: {'content-type': 'application/json'});
      expect(response.headers['content-type'], equals('application/json'));
    });

    test('body should be mockable as untyped object', () async {
      WResponse response = new MockWResponse.ok(body: {'result': 'success'});
      expect(await response.asFuture(), equals({'result': 'success'}));
    });

    test('body should be mockable as string', () async {
      WResponse response = new MockWResponse.ok(body: 'success');
      expect(await response.asText(), equals('success'));
    });

    test('body should be mockable as stream', () async {
      WResponse response =
          new MockWResponse.ok(body: new Stream.fromIterable(['success']));
      expect(await response.asStream().single, equals('success'));
    });
  });
}
