@TestOn('vm || browser')
library w_transport.test.unit.http.client_test;

import 'dart:async';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_mock.dart';

void main() {
  group('Client', () {

    setUp(() {
      configureWTransportForTest();
    });

    test('newFormRequest() should create a new request', () async {
      Client client = new Client();
      expect(client.newFormRequest(), new isInstanceOf<FormRequest>());
    });

    test('newFormRequest() should throw if closed', () async {
      Client client = new Client();
      client.close();
      expect(client.newFormRequest, throwsStateError);
    });

    test('newJsonRequest() should create a new request', () async {
      Client client = new Client();
      expect(client.newJsonRequest(), new isInstanceOf<JsonRequest>());
    });

    test('newJsonRequest() should throw if closed', () async {
      Client client = new Client();
      client.close();
      expect(client.newJsonRequest, throwsStateError);
    });

    test('newMultipartRequest() should create a new request', () async {
      Client client = new Client();
      expect(client.newMultipartRequest(), new isInstanceOf<MultipartRequest>());
    });

    test('newMultipartRequest() should throw if closed', () async {
      Client client = new Client();
      client.close();
      expect(client.newMultipartRequest, throwsStateError);
    });

    test('newRequest() should create a new request', () async {
      Client client = new Client();
      expect(client.newRequest(), new isInstanceOf<Request>());
    });

    test('newRequest() should throw if closed', () async {
      Client client = new Client();
      client.close();
      expect(client.newRequest, throwsStateError);
    });

    test('newStreamedRequest() should create a new request', () async {
      Client client = new Client();
      expect(client.newStreamedRequest(), new isInstanceOf<StreamedRequest>());
    });

    test('newStreamedRequest() should throw if closed', () async {
      Client client = new Client();
      client.close();
      expect(client.newStreamedRequest, throwsStateError);
    });

    test('complete request', () async {
      Client client = new Client();
      Uri uri = Uri.parse('/test');
      MockTransports.http.expect('GET', uri);
      await client.newRequest().get(uri: uri);
    });

    test('close()', () async {
      Client client = new Client();
      Future future = client.newRequest().get(uri: Uri.parse('/test'));
      client.close();
      expect(future, throws);
    });

  });
}
