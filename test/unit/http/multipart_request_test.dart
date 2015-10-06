@TestOn('browser || vm')
library w_transport.test.unit.http.multipart_request_test;

import 'dart:async';
import 'dart:convert';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_mock.dart';

void main() {
  group('MultipartRequest', () {
    setUp(() {
      configureWTransportForTest();
    });

    test('content-length cannot be set manually', () {
      MultipartRequest request = new MultipartRequest();
      expect(() {
        request.contentLength = 10;
      }, throwsUnsupportedError);
    });

    test('setting body in request dispatcher is unsupported', () async {
      Uri uri = Uri.parse('/test');
      MultipartRequest request = new MultipartRequest();
      expect(request.post(uri: uri, body: 'body'), throwsUnsupportedError);
    });

    test('body cannot be empty', () {
      MultipartRequest request = new MultipartRequest();
      expect(request.post(uri: Uri.parse('/test')), throwsUnsupportedError);
    });

    test('body should be unmodifiable once sent', () async {
      Uri uri = Uri.parse('/test');
      MockTransports.http.expect('POST', uri);
      MultipartRequest request = new MultipartRequest()
        ..fields['field1'] = 'value1';
      await request.post(uri: uri);
      expect(() {
        request.fields['too'] = 'late';
      }, throwsUnsupportedError);
      expect(() {
        request.files['too'] = 'late';
      }, throwsUnsupportedError);
    });

    test('setting encoding should be unsupported', () {
      MultipartRequest request = new MultipartRequest();
      expect(() {
        request.encoding = UTF8;
      }, throwsUnsupportedError);
    });
  });
}
