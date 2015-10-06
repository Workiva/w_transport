@TestOn('browser || vm')
library w_transport.test.unit.http.streamed_request_test;

import 'dart:async';
import 'dart:convert';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_mock.dart';

void main() {
  group('StreamedRequest', () {

    setUp(() {
      configureWTransportForTest();
    });

    test('setting body', () async {
      StreamedRequest request = new StreamedRequest();

      var chunks = [[1, 2], [3, 4]];
      request.body = new Stream.fromIterable(chunks);
      expect(await request.body.toList(), equals(chunks));
    });

    test('setting body in request dispatcher is supported', () async {
      Uri uri = Uri.parse('/test');

      Completer body = new Completer();
      MockTransports.http.when(uri, (FinalizedRequest request) async {
        body.complete(UTF8.decode(await (request.body as StreamedHttpBody).toBytes()));
        return new MockResponse.ok();
      });

      StreamedRequest request = new StreamedRequest();
      await request.post(uri: uri, body: new Stream.fromIterable([UTF8.encode('body')]));
      expect(await body.future, equals('body'));
    });

    test('setting body in request dispatcher should throw on invalid data', () async {
      Uri uri = Uri.parse('/test');

      StreamedRequest request = new StreamedRequest();
      expect(request.post(uri: uri, body: 'body'), throwsArgumentError);
    });

    test('body should be unmodifiable once sent', () async {
      Uri uri = Uri.parse('/test');
      MockTransports.http.expect('POST', uri);
      StreamedRequest request = new StreamedRequest();
      await request.post(uri: uri);
      expect(() {
        request.body = new Stream.fromIterable([[1, 2]]);
      }, throwsStateError);
    });

    test('content-length must be set manually', () {
      StreamedRequest request = new StreamedRequest();
      request.contentLength = 10;
      expect(request.contentLength, equals(10));
    });

    test('content-length should be unmodifiable once sent', () async {
      Uri uri = Uri.parse('/test');
      MockTransports.http.expect('GET', uri);
      StreamedRequest request = new StreamedRequest();
      await request.get(uri: uri);
    expect(() {
      request.contentLength = 10;
    }, throwsStateError);
    });

    test('setting encoding should update content-type', () {
      StreamedRequest request = new StreamedRequest();
      expect(request.contentType.parameters['charset'], equals(UTF8.name));

      request.encoding = LATIN1;
      expect(request.contentType.parameters['charset'], equals(LATIN1.name));

      request.encoding = ASCII;
      expect(request.contentType.parameters['charset'], equals(ASCII.name));
    });

    test('setting encoding should not be allowed once sent', () async {
      Uri uri = Uri.parse('/test');
      MockTransports.http.expect('GET', uri);
      StreamedRequest request = new StreamedRequest();
      await request.get(uri: uri);
      expect(() {
        request.encoding = LATIN1;
      }, throwsStateError);
    });

  });
}