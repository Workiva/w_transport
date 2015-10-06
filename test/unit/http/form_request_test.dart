@TestOn('browser || vm')
library w_transport.test.unit.http.form_request_test;

import 'dart:async';
import 'dart:convert';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_mock.dart';

void main() {
  group('FormRequest', () {
    setUp(() {
      configureWTransportForTest();
    });

    test('setting fields defaults to empty map if null', () {
      FormRequest request = new FormRequest()..fields = null;
      expect(request.fields, equals({}));
    });

    test('setting entire fields map', () {
      FormRequest request = new FormRequest()..fields = {'field': 'value'};
      expect(request.fields, equals({'field': 'value'}));
    });

    test('setting fields incrementally', () {
      FormRequest request = new FormRequest()
        ..fields['field1'] = 'value1'
        ..fields['field2'] = 'value2';
      expect(request.fields, equals({'field1': 'value1', 'field2': 'value2'}));
    });

    test('setting body in request dispatcher is supported', () async {
      Uri uri = Uri.parse('/test');

      Completer body = new Completer();
      MockTransports.http.when(uri, (FinalizedRequest request) async {
        body.complete((request.body as HttpBody).asString());
        return new MockResponse.ok();
      });

      FormRequest request = new FormRequest();
      await request.post(uri: uri, body: {'field': 'value'});
      expect(await body.future, equals('field=value'));
    });

    test('setting body in request dispatcher should throw if invalid',
        () async {
      Uri uri = Uri.parse('/test');

      FormRequest request = new FormRequest();
      expect(request.post(uri: uri, body: 'invalid'), throws);
    });

    test('body should be unmodifiable once sent', () async {
      Uri uri = Uri.parse('/test');
      MockTransports.http.expect('POST', uri);
      FormRequest request = new FormRequest();
      await request.post(uri: uri);
      expect(() {
        request.fields['too'] = 'late';
      }, throwsUnsupportedError);
      expect(() {
        request.fields = {'new': 'field'};
      }, throwsStateError);
    });

    test('content-length cannot be set manually', () {
      Request request = new Request();
      expect(() {
        request.contentLength = 10;
      }, throwsUnsupportedError);
    });

    test('setting encoding should update content-type', () {
      FormRequest request = new FormRequest();
      expect(request.contentType.parameters['charset'], equals(UTF8.name));

      request.encoding = LATIN1;
      expect(request.contentType.parameters['charset'], equals(LATIN1.name));

      request.encoding = ASCII;
      expect(request.contentType.parameters['charset'], equals(ASCII.name));
    });

    test('setting encoding should not be allowed once sent', () async {
      Uri uri = Uri.parse('/test');
      MockTransports.http.expect('GET', uri);
      FormRequest request = new FormRequest();
      await request.get(uri: uri);
      expect(() {
        request.encoding = LATIN1;
      }, throwsStateError);
    });
  });
}
