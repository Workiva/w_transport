@TestOn('browser || content-shell')
library w_transport.test.integration.w_http_client_test;

import 'dart:html';

import 'package:test/test.dart';
import 'package:w_transport/w_http.dart';
import 'package:w_transport/w_http_client.dart' show configureWHttpForBrowser;

import './w_http_common_tests.dart' as common_tests;
import './w_http_utils.dart';

void main() {
  configureWHttpForBrowser();

  // Almost all of the integration tests are identical regardless of client/server usage.
  // So, we run them from a common location.
  common_tests.run('Client');

  group('WRequest (Client)', () {
    WRequest request;

    setUp(() {
      request = new WRequest()..uri = Uri.parse('http://localhost:8024');
    });

    // The following two tests are unique from a client consumer.

    // When sending an HTTP request within a client app, the response will always
    // be a string. As such, the HttpRequest response data will be an empty string
    // if the response body is empty, as is the case with a HEAD request.
    test('should support a HEAD method', httpTest((store) async {
      // HEAD requests cannot return a body, but we can use that to
      // verify that this was actually a HEAD request
      request.path = '/test/http/reflect';
      WResponse response = store(await request.head());
      expect(response.status, equals(200));
      expect(await response.text, equals(''));
    }));

    test('should support a FormData payload', httpTest((store) async {
      request.path = '/test/http/reflect';
      FormData data = new FormData();
      Blob blob = new Blob(['blob']);
      data.appendBlob('blob', blob);
      data.append('text', 'text');
      request.data = data;
      store(await request.post());
    }));
  });
}
