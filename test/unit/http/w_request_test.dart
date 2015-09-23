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

  group('WRequest', () {
    Uri requestUri = Uri.parse('/mock/request');

    setUp(() {
      MockTransports.reset();
    });

    tearDown(() {
      MockTransports.verifyNoOutstandingExceptions();
    });

    test('DELETE', () async {
      MockTransports.http.expect('DELETE', requestUri);
      await new WRequest().delete(uri: requestUri);
    });

    test('GET', () async {
      MockTransports.http.expect('GET', requestUri);
      await new WRequest().get(uri: requestUri);
    });

    test('HEAD', () async {
      MockTransports.http.expect('HEAD', requestUri);
      await new WRequest().head(uri: requestUri);
    });

    test('OPTIONS', () async {
      MockTransports.http.expect('OPTIONS', requestUri);
      await new WRequest().options(uri: requestUri);
    });

    test('PATCH', () async {
      MockTransports.http.expect('PATCH', requestUri);
      await new WRequest().patch(uri: requestUri);
    });

    test('POST', () async {
      MockTransports.http.expect('POST', requestUri);
      await new WRequest().post(uri: requestUri);
    });

    test('PUT', () async {
      MockTransports.http.expect('PUT', requestUri);
      await new WRequest().put(uri: requestUri);
    });

    test('TRACE', () async {
      MockTransports.http.expect('TRACE', requestUri);
      await new WRequest().trace(uri: requestUri);
    });

    test('URI should be required', () async {
      expect(new WRequest().get(), throwsStateError);
    });

    test('headers should be merged when added by a request method', () async {
      MockTransports.http.expect('GET', requestUri,
          headers: {'header1': 'value1', 'header2': 'value2'});
      WRequest request = new WRequest()..headers = {'header2': 'value2'};
      await request.get(uri: requestUri, headers: {'header1': 'value1'});
    });

    test('request header value should override WRequest header value',
        () async {
      MockTransports.http
          .expect('GET', requestUri, headers: {'HEADER1': 'value2'});
      WRequest request = new WRequest()..headers = {'header1': 'value1'};
      await request.get(uri: requestUri, headers: {'HEADER1': 'value2'});
    });

    group('with headers', () {
      test('DELETE', () async {
        MockTransports.http
            .expect('DELETE', requestUri, headers: {'content-type': 'json'});
        await new WRequest()
            .delete(uri: requestUri, headers: {'content-type': 'json'});
      });

      test('GET', () async {
        MockTransports.http
            .expect('GET', requestUri, headers: {'content-type': 'json'});
        await new WRequest()
            .get(uri: requestUri, headers: {'content-type': 'json'});
      });

      test('HEAD', () async {
        MockTransports.http
            .expect('HEAD', requestUri, headers: {'content-type': 'json'});
        await new WRequest()
            .head(uri: requestUri, headers: {'content-type': 'json'});
      });

      test('OPTIONS', () async {
        MockTransports.http
            .expect('OPTIONS', requestUri, headers: {'content-type': 'json'});
        await new WRequest()
            .options(uri: requestUri, headers: {'content-type': 'json'});
      });

      test('PATCH', () async {
        MockTransports.http
            .expect('PATCH', requestUri, headers: {'content-type': 'json'});
        await new WRequest()
            .patch(uri: requestUri, headers: {'content-type': 'json'});
      });

      test('POST', () async {
        MockTransports.http
            .expect('POST', requestUri, headers: {'content-type': 'json'});
        await new WRequest()
            .post(uri: requestUri, headers: {'content-type': 'json'});
      });

      test('PUT', () async {
        MockTransports.http
            .expect('PUT', requestUri, headers: {'content-type': 'json'});
        await new WRequest()
            .put(uri: requestUri, headers: {'content-type': 'json'});
      });

      test('TRACE', () async {
        MockTransports.http
            .expect('TRACE', requestUri, headers: {'content-type': 'json'});
        await new WRequest()
            .trace(uri: requestUri, headers: {'content-type': 'json'});
      });
    });

    test(
        'URI and data should be accepted as parameters to a request dispatch method',
        () async {
      Completer dataCompleter = new Completer();
      MockTransports.http.when(requestUri, (WRequest request) async {
        dataCompleter.complete(request.data);
        return new MockWResponse.ok();
      });
      await new WRequest().post(uri: requestUri, data: 'data');
      expect(await dataCompleter.future, equals('data'));
    });

    test('request cancellation prior to dispatch should cancel request',
        () async {
      WRequest request = new WRequest();
      request.abort();
      expect(request.get(uri: requestUri),
          throwsA(new isInstanceOf<WHttpException>()));
    });

    test(
        'request cancellation after dispatch but prior to resolution should cancel request',
        () async {
      WRequest request = new WRequest();
      Future future = request.get(uri: requestUri);
      await new Future.delayed(new Duration(milliseconds: 500));
      request.abort();
      expect(future, throwsA(new isInstanceOf<WHttpException>()));
    });

    test('request cancellation after request has succeeded should do nothing',
        () async {
      MockTransports.http.expect('GET', requestUri);
      WRequest request = new WRequest();
      await request.get(uri: requestUri);
      request.abort();
    });

    test('request cancellation after request has failed should do nothing',
        () async {
      MockTransports.http.expect('GET', requestUri, failWith: new Exception());
      WRequest request = new WRequest();
      Future future = request.get(uri: requestUri);
      expect(future, throwsA(new isInstanceOf<WHttpException>()));
      try {
        await future;
      } catch (e) {}
      request.abort();
    });

    test('request cancellation should accept a custom error', () async {
      WRequest request = new WRequest();
      request.abort(new Exception('custom error'));
      expect(request.get(uri: requestUri), throwsA(predicate((error) {
        return error is WHttpException &&
            error.toString().contains('custom error');
      })));
    });

    test('should wrap an unexpected exception in WHttpException', () async {
      MockWRequest request = new MockWRequest();
      MockTransports.http.causeFailureOnOpen(request);
      expect(request.get(uri: requestUri),
          throwsA(new isInstanceOf<WHttpException>()));
    });
  });
}
