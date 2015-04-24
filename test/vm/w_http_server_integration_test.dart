library w_transport.test.integration.w_http_server_test;

@TestOn('vm')

import 'dart:async';
import 'dart:convert';

import 'package:test/test.dart';
import 'package:w_transport/w_http_server.dart';

import '../common/w_http_common_tests.dart' as common_tests;
import '../common/w_http_utils.dart';


void main() {
  // Almost all of the integration tests are identical regardless of client/server usage.
  // So, we run them from a common location.
  common_tests.run('Server', () => new WRequest(), (WStreamedResponse resp) {
    return resp.transform(new Utf8Decoder()).join('');
  });

  void setReqPath(WRequest req, String path) {
    req.uri = Uri.parse('http://localhost:8024').replace(path: path);
  }

  group('WRequest (Server)', () {
    WRequest req;

    setUp(() {
      req = new WRequest()..uri = Uri.parse('http://localhost:8024');
    });

    // The following two tests are unique from a server consumer.

    // When sending an HTTP request within a server app, the response type
    // cannot be assumed to be a UTF8 string. As such, the HttpClientResponse
    // instance used internally returns an empty stream when the response body is empty,
    // which is the case with a HEAD request.
    test('should support a HEAD method', httpTest((store) async {
      // HEAD requests cannot return a body, but we can use that to
      // verify that this was actually a HEAD request
      setReqPath(req, '/test/http/reflect');
      WStreamedResponse response = store(await req.head());
      expect(response.status, equals(200));
      expect(await response.length, equals(0));
    }));

    // Unlike the browser environment, a server app has fewer security restrictions
    // and can successfully send a TRACE request.
    test('should support a TRACE method', httpTest((store) async {
      setReqPath(req, '/test/http/reflect');
      WStreamedResponse response = store(await req.trace());
      expect(response.status, equals(200));
      expect(JSON.decode(await response.transform(new Utf8Decoder()).join(''))['method'], equals('TRACE'));
    }));

    test('should allow a String data payload', () {
      WRequest req = new WRequest();
      req.data = 'data';
      expect(req.data, equals('data'));
    });

    test('should allow a Stream data payload', () async {
      WRequest req = new WRequest();
      req.data = new Stream.fromIterable(['data']);
      expect(await req.data.join(''), equals('data'));
    });

    test('should throw on invalid data payload', () {
      WRequest req = new WRequest();
      expect(() {
        req.data = 10;
      }, throwsArgumentError);
    });
  });
}