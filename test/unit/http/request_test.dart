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
library w_transport.test.unit.http.w_request_test;

import 'dart:async';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_mock.dart';

void main() {
  configureWTransportForTest();

  group('Request', () {
    Uri requestUri = Uri.parse('/mock/request');

    setUp(() {
      MockTransports.reset();
    });

    tearDown(() {
      MockTransports.verifyNoOutstandingExceptions();
    });

    test('DELETE', () async {
      MockTransports.http.expect('DELETE', requestUri);
      await new Request().delete(uri: requestUri);
    });

    test('GET', () async {
      MockTransports.http.expect('GET', requestUri);
      await new Request().get(uri: requestUri);
    });

    test('HEAD', () async {
      MockTransports.http.expect('HEAD', requestUri);
      await new Request().head(uri: requestUri);
    });

    test('OPTIONS', () async {
      MockTransports.http.expect('OPTIONS', requestUri);
      await new Request().options(uri: requestUri);
    });

    test('PATCH', () async {
      MockTransports.http.expect('PATCH', requestUri);
      await new Request().patch(uri: requestUri);
    });

    test('POST', () async {
      MockTransports.http.expect('POST', requestUri);
      await new Request().post(uri: requestUri);
    });

    test('PUT', () async {
      MockTransports.http.expect('PUT', requestUri);
      await new Request().put(uri: requestUri);
    });

    test('TRACE', () async {
      MockTransports.http.expect('TRACE', requestUri);
      await new Request().trace(uri: requestUri);
    });

    test('URI should be required', () async {
      expect(new Request().get(), throwsStateError);
    });

    test(
        'URI and data should be accepted as parameters to a request dispatch method',
        () async {
      Completer dataCompleter = new Completer();
      MockTransports.http.when(requestUri, (FinalizedRequest request) async {
        dataCompleter.complete((request.body as HttpBody).asString());
        return new MockResponse.ok();
      });
      await new Request().post(uri: requestUri, body: 'data');
      expect(await dataCompleter.future, equals('data'));
    });

    test('request cancellation prior to dispatch should cancel request',
        () async {
          Request request = new Request();
      request.abort();
      expect(
          request.get(uri: requestUri), throwsA(new isInstanceOf<RequestException>()));
    });

    test(
        'request cancellation after dispatch but prior to resolution should cancel request',
        () async {
          Request request = new Request();
      Future future = request.get(uri: requestUri);
      await new Future.delayed(new Duration(milliseconds: 500));
      request.abort();
      expect(future, throwsA(new isInstanceOf<RequestException>()));
    });

    test('request cancellation after request has succeeded should do nothing',
        () async {
      MockTransports.http.expect('GET', requestUri);
      Request request = new Request();
      await request.get(uri: requestUri);
      request.abort();
    });

    test('request cancellation after request has failed should do nothing',
        () async {
      MockTransports.http.expect('GET', requestUri, failWith: new Exception());
      Request request = new Request();
      Future future = request.get(uri: requestUri);
      expect(future, throwsA(new isInstanceOf<RequestException>()));
      try {
        await future;
      } catch (e) {}
      request.abort();
    });

    test('request cancellation should accept a custom error', () async {
      Request request = new Request();
      request.abort(new Exception('custom error'));
      expect(request.get(uri: requestUri), throwsA(predicate((error) {
        return error is RequestException &&
            error.toString().contains('custom error');
      })));
    });

    test('should wrap an unexpected exception in WHttpException', () async {
      Request request = new Request();
      MockTransports.http.causeFailureOnOpen(request);
      expect(
          request.get(uri: requestUri), throwsA(new isInstanceOf<RequestException>()));
    });
  });
}
