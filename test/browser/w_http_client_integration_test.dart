library w_transport.test.integration.w_http_client_test;

@TestOn('browser || content-shell')

import 'dart:async';
import 'dart:html';

import 'package:test/test.dart';
import 'package:w_transport/w_http_client.dart';

import '../common/w_http_common_tests.dart' as common_tests;
import '../common/w_http_utils.dart';


void main() {
  // Almost all of the integration tests are identical regardless of client/server usage.
  // So, we run them from a common location.
  common_tests.run('Client', () => new WRequest(), (WResponse resp) {
    return new Future.value(resp.text);
  });

  void setReqPath(WRequest req, String path) {
    req.uri = Uri.parse('http://localhost:8024').replace(path: path);
  }

  group('WRequest (Client)', () {
    WRequest req;

    setUp(() {
      req = new WRequest()..uri = Uri.parse('http://localhost:8024');
    });

    // The following two tests are unique from a client consumer.

    // When sending an HTTP request within a client app, the response will always
    // be a string. As such, the HttpRequest response data will be an empty string
    // if the response body is empty, as is the case with a HEAD request.
    test('should support a HEAD method', httpTest((store) async {
      // HEAD requests cannot return a body, but we can use that to
      // verify that this was actually a HEAD request
      setReqPath(req, '/test/http/reflect');
      WResponse response = store(await req.head());
      expect(response.status, equals(200));
      expect(response.text, equals(''));
    }));

    test('should support a FormData payload', httpTest((store) async {
      setReqPath(req, '/test/http/reflect');
      FormData data = new FormData();
      Blob blob = new Blob(['blob']);
      data.appendBlob('blob', blob);
      data.append('text', 'text');
      req.data = data;
      store(await req.post());
    }));
  });
}