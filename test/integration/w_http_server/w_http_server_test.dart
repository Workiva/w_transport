library w_http_server_test;

// Dart imports
import 'dart:convert';

// Package imports
import 'package:unittest/unittest.dart';
import 'package:w_transport/w_http_server.dart';

// Src imports
import '../../server/http_server_constants.dart';
import '../common_http_integration_tests.dart' as common_http_integration_tests;


void main() {
  // Almost all of the integration tests are identical regardless of client/server usage.
  // So, we run them from a common location.
  common_http_integration_tests.run('Server', () => new WHttp(), (WStreamedResponse resp) {
    return resp.utf8Text;
  });

  void setReqPath(WHttp req, String path) {
    req.url(Uri.parse(httpServerAddress).replace(path: path));
  }

  group('WHttp', () {

    WHttp req;

    setUp(() {
      req = new WHttp()..url(Uri.parse(httpServerAddress));
    });

    // The following two tests are unique from a server consumer.

    // When sending an HTTP request within a server app, the response type
    // cannot be assumed to be a UTF8 string. As such, the HttpClientResponse
    // instance used internally returns an empty stream when the response body is empty,
    // which is the case with a HEAD request.
    test('should support a HEAD method', () {
      // HEAD requests cannot return a body, but we can use that to
      // verify that this was actually a HEAD request
      setReqPath(req, Routes.reflect);
      req.head().then(expectAsync((WStreamedResponse response) {
        expect(response.status, equals(200));
        response.stream.length.then(expectAsync((int length) {
          expect(length, equals(0));
        }));
      }));
    });

    // Unlike the browser environment, a server app has fewer security restrictions
    // and can successfully send a TRACE request.
    test('should support a TRACE method', () {
      setReqPath(req, Routes.reflect);
      req.trace().then(expectAsync((WStreamedResponse response) {
        expect(response.status, equals(200));
        response.utf8Text.then(expectAsync((String responseText) {
          Map responseJson = JSON.decode(responseText);
          expect(responseJson['method'], equals('TRACE'));
        }));
      }));
    });

  });
}