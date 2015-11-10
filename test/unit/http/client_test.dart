// Copyright 2015 Workiva Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

@TestOn('vm || browser')
library w_transport.test.unit.http.client_test;

import 'dart:async';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_mock.dart';

import '../../naming.dart';

void main() {
  Naming naming = new Naming()
    ..testType = testTypeUnit
    ..topic = topicHttp;

  group(naming.toString(), () {
    group('Client', () {
      setUp(() {
        configureWTransportForTest();
        MockTransports.reset();
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
        expect(
            client.newMultipartRequest(), new isInstanceOf<MultipartRequest>());
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
        expect(
            client.newStreamedRequest(), new isInstanceOf<StreamedRequest>());
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

      test('withCredentials should cascade to all factoried requests',
          () async {
        Client client = new Client()..withCredentials = true;
        Uri uri = Uri.parse('/test');
        Completer c = new Completer();
        MockTransports.http.when(uri, (FinalizedRequest request) async {
          request.withCredentials
              ? c.complete()
              : c.completeError(
                  new Exception('withCredentials should be true'));
          return new MockResponse.ok();
        }, method: 'GET');
        await client.newRequest().get(uri: uri);
        await c.future;
      });

      test('headers should cascade to all factoried requests', () async {
        var headers = {'x-custom1': 'value', 'x-custom2': 'value2'};
        Client client = new Client()..headers = headers;
        Uri uri = Uri.parse('/test');
        MockTransports.http.expect('GET', uri, headers: headers);
        await client.newRequest().get(uri: uri);
      });

      test('headers', () async {
        var headers = {'x-custom1': 'value', 'x-custom2': 'value2'};
        Client client = new Client()..headers = headers;
        expect(client.headers, equals(headers));
      });

      test('close()', () async {
        Client client = new Client();
        Future future = client.newRequest().get(uri: Uri.parse('/test'));
        client.close();
        expect(future, throws);
      });
    });
  });
}
