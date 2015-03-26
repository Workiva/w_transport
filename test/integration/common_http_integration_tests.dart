library common_http_integration_tests;

// Dart imports
import 'dart:convert';

// Package imports
import 'package:unittest/unittest.dart';
import 'package:w_transport/w_http.dart';

// Src imports
import '../server/http_server_constants.dart';
import 'utils.dart';


/**
 * These are HTTP integration tests that should work from client or server.
 * These will not pass if run on their own!
 */
void run(String usage) {
  group('WHttp $usage', () {

    WHttp req;

    setUp(() {
      req = new WHttp()..url = Uri.parse(httpServerAddress);
    });

    test('should successfully send an HTTP request', () {
      req.path = Routes.ping;
      req.get().then(expectAsync((_) {
        expect(req.status, equals(200));
        expect(req.response, equals(pingResponse));
      }));
    });

    group('request methods', () {

      test('should support a DELETE method', () {
        req.path = Routes.reflect;
        req.delete().then(expectAsync((_) {
          Map response = JSON.decode(req.response);
          expect(response['method'], equals('DELETE'));
        }));
      });

      test('should support a GET method', () {
        req.path = Routes.reflect;
        req.get().then(expectAsync((_) {
          Map response = JSON.decode(req.response);
          expect(response['method'], equals('GET'));
        }));
      });

      test('should support a OPTIONS method', () {
        req.path = Routes.reflect;
        req.options().then(expectAsync((_) {
          expect(req.status, equals(200));
          Map response = JSON.decode(req.response);
          expect(response['method'], equals('OPTIONS'));
        }));
      });

      test('should support a PATCH method', () {
        req.path = Routes.reflect;
        req.patch().then(expectAsync((_) {
          expect(req.status, equals(200));
          Map response = JSON.decode(req.response);
          expect(response['method'], equals('PATCH'));
        }));
      });

      test('should support a POST method', () {
        req.path = Routes.reflect;
        req.post().then(expectAsync((_) {
          expect(req.status, equals(200));
          Map response = JSON.decode(req.response);
          expect(response['method'], equals('POST'));
        }));
      });

      test('should support a PUT method', () {
        req.path = Routes.reflect;
        req.put().then(expectAsync((_) {
          expect(req.status, equals(200));
          Map response = JSON.decode(req.response);
          expect(response['method'], equals('PUT'));
        }));
      });

    });

    group('request data', () {

      test('should be supported on a PATCH request', () {
        req
          ..path = Routes.reflect
          ..data = 'data';

        req.patch().then(expectAsync((_) {
          expect(req.status, equals(200));
          Map response = JSON.decode(req.response);
          expect(response['body'], equals('data'));
        }));
      });

      test('should be supported on a POST request', () {
        req
          ..path = Routes.reflect
          ..data = 'data';

        req.post().then(expectAsync((_) {
          expect(req.status, equals(200));
          Map response = JSON.decode(req.response);
          expect(response['body'], equals('data'));
        }));
      });

      test('should be supported on a PUT request', () {
        req
          ..path = Routes.reflect
          ..data = 'data';

        req.put().then(expectAsync((_) {
          expect(req.status, equals(200));
          Map response = JSON.decode(req.response);
          expect(response['body'], equals('data'));
        }));
      });

    });

    group('request headers', () {

      setUp(() {
        req
          ..path = Routes.reflect
          ..headers = {
            'content-type': 'application/json',
            'x-tokens': 'token1, token2',
        }
          ..header('authorization', 'test');
      });

      test('should be supported on a DELETE request', () {
        req.delete().then(expectAsync((_) {
          expect(req.status, equals(200));
          Map response = JSON.decode(req.response);
          Map<String, List<String>> headers = parseHeaders(response['headers']);
          expect(headers['content-type'], equals(['application/json']));
          expect(headers['authorization'], equals(['test']));
          expect(headers['x-tokens'], equals(['token1', 'token2']));
        }));
      });

      test('should be supported on a GET request', () {
        req.get().then(expectAsync((_) {
          expect(req.status, equals(200));
          Map response = JSON.decode(req.response);
          Map<String, List<String>> headers = parseHeaders(response['headers']);
          expect(headers['content-type'], equals(['application/json']));
          expect(headers['authorization'], equals(['test']));
          expect(headers['x-tokens'], equals(['token1', 'token2']));
        }));
      });

      test('should be supported on a OPTIONS request', () {
        req.options().then(expectAsync((_) {
          expect(req.status, equals(200));
          Map response = JSON.decode(req.response);
          Map<String, List<String>> headers = parseHeaders(response['headers']);
          expect(headers['content-type'], equals(['application/json']));
          expect(headers['authorization'], equals(['test']));
          expect(headers['x-tokens'], equals(['token1', 'token2']));
        }));
      });

      test('should be supported on a PATCH request', () {
        req.patch().then(expectAsync((_) {
          expect(req.status, equals(200));
          Map response = JSON.decode(req.response);
          Map<String, List<String>> headers = parseHeaders(response['headers']);
          expect(headers['content-type'], equals(['application/json']));
          expect(headers['authorization'], equals(['test']));
          expect(headers['x-tokens'], equals(['token1', 'token2']));
        }));
      });

      test('should be supported on a POST request', () {
        req.post().then(expectAsync((_) {
          expect(req.status, equals(200));
          Map response = JSON.decode(req.response);
          Map<String, List<String>> headers = parseHeaders(response['headers']);
          expect(headers['content-type'], equals(['application/json']));
          expect(headers['authorization'], equals(['test']));
          expect(headers['x-tokens'], equals(['token1', 'token2']));
        }));
      });

      test('should be supported on a PUT request', () {
        req.put().then(expectAsync((_) {
          expect(req.status, equals(200));
          Map response = JSON.decode(req.response);
          Map<String, List<String>> headers = parseHeaders(response['headers']);
          expect(headers['content-type'], equals(['application/json']));
          expect(headers['authorization'], equals(['test']));
          expect(headers['x-tokens'], equals(['token1', 'token2']));
        }));
      });

    });

  });
}