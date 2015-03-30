library common_http_integration_tests;

// Dart imports
import 'dart:async';
import 'dart:convert';

// Package imports
import 'package:unittest/unittest.dart';

// Src imports
import '../server/http_server_constants.dart';
import 'utils.dart';


/**
 * These are HTTP integration tests that should work from client or server.
 * These will not pass if run on their own!
 */
void run(String usage, dynamic newRequest(), Future<String> getResponseText(resp)) {

  void setReqPath(WHttp req, String path) {
    req.url(Uri.parse(httpServerAddress).replace(path: path));
  }

  group('WHttp $usage', () {

    dynamic req;

    setUp(() {
      req = newRequest()..url(Uri.parse(httpServerAddress));
    });

    test('should successfully send an HTTP request', () {
      setReqPath(req, Routes.ping);
      req.get().then(expectAsync((response) {
        expect(response.status, equals(200));
        getResponseText(response).then(expectAsync((String responseText) {
          expect(responseText, equals(pingResponse));
        }));
      }));
    });

    group('request methods', () {

      setUp(() {
        setReqPath(req, Routes.reflect);
      });

      test('should support a DELETE method', () {
        req.delete().then(expectAsync((response) {
          expect(response.status, equals(200));
          getResponseText(response).then(expectAsync((String responseText) {
            Map responseJson = JSON.decode(responseText);
            expect(responseJson['method'], equals('DELETE'));
          }));
        }));
      });

      test('should support a GET method', () {
        req.get().then(expectAsync((response) {
          expect(response.status, equals(200));
          getResponseText(response).then(expectAsync((String responseText) {
            Map responseJson = JSON.decode(responseText);
            expect(responseJson['method'], equals('GET'));
          }));
        }));
      });

      test('should support a OPTIONS method', () {
        req.options().then(expectAsync((response) {
          expect(response.status, equals(200));
          getResponseText(response).then(expectAsync((String responseText) {
            Map responseJson = JSON.decode(responseText);
            expect(responseJson['method'], equals('OPTIONS'));
          }));
        }));
      });

      test('should support a PATCH method', () {
        req.patch().then(expectAsync((response) {
          expect(response.status, equals(200));
          getResponseText(response).then(expectAsync((String responseText) {
            Map responseJson = JSON.decode(responseText);
            expect(responseJson['method'], equals('PATCH'));
          }));
        }));
      });

      test('should support a POST method', () {
        req.post().then(expectAsync((response) {
          expect(response.status, equals(200));
          getResponseText(response).then(expectAsync((String responseText) {
            Map responseJson = JSON.decode(responseText);
            expect(responseJson['method'], equals('POST'));
          }));
        }));
      });

      test('should support a PUT method', () {
        req.put().then(expectAsync((response) {
          expect(response.status, equals(200));
          getResponseText(response).then(expectAsync((String responseText) {
            Map responseJson = JSON.decode(responseText);
            expect(responseJson['method'], equals('PUT'));
          }));
        }));
      });

    });

    group('request data', () {

      setUp(() {
        setReqPath(req, Routes.reflect);
        req.data('data');
      });

      test('should be supported on a PATCH request', () {
        req.patch().then(expectAsync((response) {
          expect(response.status, equals(200));
          getResponseText(response).then(expectAsync((String responseText) {
            Map responseJson = JSON.decode(responseText);
            expect(responseJson['body'], equals('data'));
          }));
        }));
      });

      test('should be supported on a POST request', () {
        req.post().then(expectAsync((response) {
          expect(response.status, equals(200));
          getResponseText(response).then(expectAsync((String responseText) {
            Map responseJson = JSON.decode(responseText);
            expect(responseJson['body'], equals('data'));
          }));
        }));
      });

      test('should be supported on a PUT request', () {
        req.put().then(expectAsync((response) {
          expect(response.status, equals(200));
          getResponseText(response).then(expectAsync((String responseText) {
            Map responseJson = JSON.decode(responseText);
            expect(responseJson['body'], equals('data'));
          }));
        }));
      });

    });

    group('request headers', () {

      setUp(() {
        setReqPath(req, Routes.reflect);
        req.headers({
            'content-type': 'application/json',
            'x-tokens': 'token1, token2',
        }).header('authorization', 'test');
      });

      test('should be supported on a DELETE request', () {
        req.delete().then(expectAsync((response) {
          expect(response.status, equals(200));
          getResponseText(response).then(expectAsync((String responseText) {
            Map responseJson = JSON.decode(responseText);
            Map<String, List<String>> headers = parseHeaders(responseJson['headers']);
            expect(headers['content-type'], equals(['application/json']));
            expect(headers['authorization'], equals(['test']));
            expect(headers['x-tokens'], equals(['token1', 'token2']));
          }));
        }));
      });

      test('should be supported on a GET request', () {
        req.get().then(expectAsync((response) {
          expect(response.status, equals(200));
          getResponseText(response).then(expectAsync((String responseText) {
            Map responseJson = JSON.decode(responseText);
            Map<String, List<String>> headers = parseHeaders(responseJson['headers']);
            expect(headers['content-type'], equals(['application/json']));
            expect(headers['authorization'], equals(['test']));
            expect(headers['x-tokens'], equals(['token1', 'token2']));
          }));
        }));
      });

      test('should be supported on a OPTIONS request', () {
        req.options().then(expectAsync((response) {
          expect(response.status, equals(200));
          getResponseText(response).then(expectAsync((String responseText) {
            Map responseJson = JSON.decode(responseText);
            Map<String, List<String>> headers = parseHeaders(responseJson['headers']);
            expect(headers['content-type'], equals(['application/json']));
            expect(headers['authorization'], equals(['test']));
            expect(headers['x-tokens'], equals(['token1', 'token2']));
          }));
        }));
      });

      test('should be supported on a PATCH request', () {
        req.patch().then(expectAsync((response) {
          expect(response.status, equals(200));
          getResponseText(response).then(expectAsync((String responseText) {
            Map responseJson = JSON.decode(responseText);
            Map<String, List<String>> headers = parseHeaders(responseJson['headers']);
            expect(headers['content-type'], equals(['application/json']));
            expect(headers['authorization'], equals(['test']));
            expect(headers['x-tokens'], equals(['token1', 'token2']));
          }));
        }));
      });

      test('should be supported on a POST request', () {
        req.post().then(expectAsync((response) {
          expect(response.status, equals(200));
          getResponseText(response).then(expectAsync((String responseText) {
            Map responseJson = JSON.decode(responseText);
            Map<String, List<String>> headers = parseHeaders(responseJson['headers']);
            expect(headers['content-type'], equals(['application/json']));
            expect(headers['authorization'], equals(['test']));
            expect(headers['x-tokens'], equals(['token1', 'token2']));
          }));
        }));
      });

      test('should be supported on a PUT request', () {
        req.put().then(expectAsync((response) {
          expect(response.status, equals(200));
          getResponseText(response).then(expectAsync((String responseText) {
            Map responseJson = JSON.decode(responseText);
            Map<String, List<String>> headers = parseHeaders(responseJson['headers']);
            expect(headers['content-type'], equals(['application/json']));
            expect(headers['authorization'], equals(['test']));
            expect(headers['x-tokens'], equals(['token1', 'token2']));
          }));
        }));
      });

    });

  });
}