library w_http_client_test;

// Dart imports
import 'dart:async';
import 'dart:html';

// Package imports
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart';
import 'package:w_transport/w_http_client.dart';

// Test imports
import '../../server/http_server_constants.dart';
import '../common_http_integration_tests.dart' as common_http_integration_tests;


void main() {
  // Setup tests and WHttp for client-side usage
  useHtmlConfiguration();

  // Almost all of the integration tests are identical regardless of client/server usage.
  // So, we run them from a common location.
  common_http_integration_tests.run('Client', () => new WHttp(), (WResponse resp) {
    return new Future.value(resp.text);
  });

  void setReqPath(WHttp req, String path) {
    req.url(Uri.parse(httpServerAddress).replace(path: path));
  }

  group('WHttp', () {

    WHttp req;

    setUp(() {
      req = new WHttp()..url(Uri.parse(httpServerAddress));
    });

    // The following two tests are unique from a client consumer.

    // When sending an HTTP request within a client app, the response will always
    // be a string. As such, the HttpRequest response data will be an empty string
    // if the response body is empty, as is the case with a HEAD request.
    test('should support a HEAD method', () {
      // HEAD requests cannot return a body, but we can use that to
      // verify that this was actually a HEAD request
      setReqPath(req, Routes.reflect);
      req.head().then(expectAsync((WResponse response) {
        expect(response.status, equals(200));
        expect(response.text, equals(''));
      }));
    });

    // A client app has to deal with the browser environment, including the additional
    // security restrictions. This means that a TRACE request is forbidden.
    test('should support a TRACE method', () {
      // TRACE requests are not allowed from a browser because they
      // violate the user agent security policy, but we can use this
      // to verify that a TRACE request was actually sent
      setReqPath(req, Routes.reflect);
      expect(() {
        try {
          req.trace();
        } on DomException {
          // silence security error
        }
      }, returnsNormally);
    });
  });
}