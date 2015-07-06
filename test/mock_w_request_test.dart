library w_transport.test.mock_w_request_test;

import 'dart:async';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart' show WHttpException, WRequest, WResponse;
import 'package:w_transport/mocks.dart' show MockWRequest, MockWResponse;

void main() {
  group('MockWRequest', () {
    MockWRequest request;

    setUp(() {
      request = new MockWRequest()
        ..path = '/test/';
    });

    test('complete() should complete the request with a 200 OK by default', () async {
      request.complete();
      WResponse response = await request.get();
      expect(response.status, equals(200));
      expect(response.statusText, equals('OK'));
    });

    test('complete() should accept a mock response', () async {
      request.complete(response: new MockWResponse.unauthorized());
      WResponse response = await request.get();
      expect(response.status, equals(401));
      expect(response.statusText, equals('UNAUTHORIZED'));
    });

    test('completeError() should complete the request with an error', () async {
      request.completeError();
      WHttpException exception;
      try {
        await request.get();
      } on WHttpException catch (e) {
        exception = e;
      }
      expect(exception, isNotNull);
      expect(exception.method, equals('GET'));
      expect(exception.uri.path, equals('/test/'));
    });

    test('completeError() should accept a custom error', () async {
      request.completeError(error: new Exception('Custom error.'));
      WHttpException exception;
      try {
        await request.get();
      } on WHttpException catch (e) {
        exception = e;
      }
      expect(exception, isNotNull);
      expect(exception.toString(), contains('Custom error.'));
    });

    test('completeError() should accept a mock response', () async {
      request.completeError(response: new MockWResponse.internalServerError());
      WHttpException exception;
      try {
        await request.get();
      } on WHttpException catch (e) {
        exception = e;
      }
      expect(exception, isNotNull);
      expect(exception.response.status, equals(500));
      expect(exception.response.statusText, equals('INTERNAL SERVER ERROR'));
    });

    test('abort() should still cancel the request', () async {
      request.abort();
      WHttpException exception;
      try {
        await request.get();
      } on WHttpException catch (e) {
        exception = e;
      }
      expect(exception, isNotNull);
      expect(exception.toString(), contains('Request canceled.'));
    });

    test('uploadProgress stream should go from 0 to 100%', () async {
      Completer uploadComplete = new Completer();

      request.uploadProgress.listen((progress) {
        if (progress.percent == 100.0) {
          uploadComplete.complete();
        }
      });

      request.complete();
      await request.get();
      await uploadComplete.future;
    });

    test('downloadProgress stream should go from 0 to 100%', () async {
      Completer downloadComplete = new Completer();

      request.downloadProgress.listen((progress) {
        if (progress.percent == 100.0) {
          downloadComplete.complete();
        }
      });

      request.complete();
      await request.get();
      await downloadComplete.future;
    });
  });
}