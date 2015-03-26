library w_http_server_test;

// Dart imports
import 'dart:convert';

// Package imports
import 'package:unittest/unittest.dart';
import 'package:w_transport/w_http.dart';
import 'package:w_transport/w_http_server.dart' as w_http_server;

// Src imports
import '../../server/http_server_constants.dart';
import '../common_http_integration_tests.dart' as common_http_integration_tests;


void main() {
  // Setup WHttp for client-side usage
  w_http_server.useServerConfiguration();

  // Almost all of the integration tests are identical regardless of client/server usage.
  // So, we run them from a common location.
  common_http_integration_tests.run('Server');

  group('WHttp', () {

    WHttp req;

    setUp(() {
      req = new WHttp()..url = Uri.parse(httpServerAddress);
    });

    // The following two tests are unique from a server consumer.

    // When sending an HTTP request within a server app, the response type
    // cannot be assumed to be a UTF8 string. As such, the HttpClientResponse
    // instance used internally returns null when the response body is empty,
    // which is the case with a HEAD request.
    test('should support a HEAD method', () {
      // HEAD requests cannot return a body, but we can use that to
      // verify that this was actually a HEAD request
      req.path = Routes.reflect;
      req.head().then(expectAsync((_) {
        expect(req.status, equals(200));
        expect(req.response, isNull);
      }));
    });

    // Unlike the browser environment, a server app has fewer security restrictions
    // and can successfully send a TRACE request.
    test('should support a TRACE method', () {
      req.path = Routes.reflect;
      req.trace().then(expectAsync((_) {
        expect(req.status, equals(200));
        Map response = JSON.decode(req.response);
        expect(response['method'], equals('TRACE'));
      }));
    });

  });
}