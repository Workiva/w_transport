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

@TestOn('vm')
library w_transport.test.unit.mocks.mock_http_test;

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_mock.dart';
import 'package:w_transport/w_transport_server.dart';

void main() {
  configureWTransportForTest();

  group('TransportMocks.http', () {
    Uri requestUri = Uri.parse('/mock/test');

    setUp(() {
      MockTransports.reset();
    });

    test('causeFailureOnOpen() should cause request to throw', () async {
      WRequest request = new WRequest();
      MockTransports.http.causeFailureOnOpen(request);
      expect(request.get(uri: requestUri), throws);
    });

    test('verifies that requests are mock requests before controlling them',
        () {
      configureWTransportForServer();
      WRequest request = new WRequest();
      expect(() {
        MockTransports.http.completeRequest(request);
      }, throwsArgumentError);
      configureWTransportForTest();
    });

    group('completeRequest()', () {
      test('completes a request with 200 OK by default', () async {
        WRequest request = new WRequest();
        MockTransports.http.completeRequest(request);
        expect((await request.get(uri: requestUri)).status, equals(200));
      });

      test('can complete a request with custom response', () async {
        WRequest request = new WRequest();
        WResponse response = new MockWResponse(202);
        MockTransports.http.completeRequest(request, response: response);
        expect((await request.get(uri: requestUri)).status, equals(202));
      });
    });

    group('expect()', () {
      test('expected request completes automatically with 200 OK by default',
          () async {
        MockTransports.http.expect('GET', requestUri);
        expect((await WHttp.get(requestUri)).status, equals(200));
      });

      test('expected request with custom response', () async {
        MockWResponse response = new MockWResponse(202);
        MockTransports.http.expect('POST', requestUri, respondWith: response);
        expect((await WHttp.post(requestUri)).status, equals(202));
      });

      test('expected request failure', () async {
        Exception exception = new Exception('Custom exception');
        MockTransports.http.expect('DELETE', requestUri, failWith: exception);
        expect(WHttp.delete(requestUri), throwsA(predicate((error) {
          return error.toString().contains('Custom exception');
        })));
      });

      test('expected request has to match URI and method', () async {
        MockTransports.http.expect('GET', requestUri);
        WHttp.delete(requestUri); // Wrong method
        WHttp.get(Uri.parse('/wrong')); // Wrong URI
        await WHttp.get(requestUri); // Correct
        expect(MockTransports.http.numPendingRequests, equals(2));
      });

      test('supports failWith, or respondWith, but not both', () {
        expect(() {
          MockTransports.http.expect('GET', requestUri,
              failWith: new Exception(), respondWith: new MockWResponse.ok());
        }, throwsArgumentError);
      });
    });

    group('failRequest()', () {
      test('causes request to throw', () async {
        WRequest request = new WRequest();
        MockTransports.http.failRequest(request);
        expect(request.get(uri: requestUri), throws);
      });

      test('can include a custom exception', () async {
        WRequest request = new WRequest();
        MockTransports.http
            .failRequest(request, error: new Exception('Custom exception'));
        expect(request.get(uri: requestUri), throwsA(predicate((error) {
          return error.toString().contains('Custom exception');
        })));
      });

      test('can include a custom response', () async {
        WRequest request = new WRequest();
        WResponse response = new MockWResponse.internalServerError();
        MockTransports.http.failRequest(request, response: response);
        expect(request.get(uri: requestUri), throwsA(predicate((error) {
          return error is WHttpException && error.response.status == 500;
        })));
      });
    });

    test(
        'reset() should clear all expectations, pending requests, and handlers',
        () async {
      MockTransports.http
          .when(requestUri, (req) async => new MockWResponse.ok());
      MockTransports.http.expect('GET', Uri.parse('/expected'));
      MockWRequest request = new MockWRequest();
      request.get(uri: Uri.parse('/other'));
      await request.onSent;
      expect(MockTransports.http.numPendingRequests, equals(1));

      MockTransports.http.reset();

      // Would have been handled by our handler, but should no longer be:
      MockWRequest request2 = new MockWRequest();
      request2.delete(uri: requestUri);
      await request2.onSent;

      // Would have been expected, but should no longer be:
      MockWRequest request3 = new MockWRequest();
      request3.get(uri: Uri.parse('/expected'));
      await request3.onSent;

      expect(MockTransports.http.numPendingRequests, equals(2));
    });

    group('verifyNoOutstandingExceptions()', () {
      test(
          'does not throw if no pending requests and no unfulfilled expectations',
          () {
        MockTransports.http.verifyNoOutstandingExceptions();
      });

      test('throws if requests are pending', () async {
        MockWRequest request = new MockWRequest();
        request.get(uri: requestUri);
        await request.onSent;
        expect(() {
          MockTransports.http.verifyNoOutstandingExceptions();
        }, throwsStateError);
      });

      test('throws if expectation is unfulfilled', () {
        MockTransports.http.expect('GET', requestUri);
        expect(() {
          MockTransports.http.verifyNoOutstandingExceptions();
        }, throwsStateError);
      });
    });

    group('when()', () {
      test('registers a handler for all requests with matching URI and method',
          () async {
        WResponse ok = new MockWResponse.ok();
        MockTransports.http
            .when(requestUri, (WRequest request) async => ok, method: 'GET');
        WHttp.get(Uri.parse('/wrong')); // Wrong URI.
        WHttp.delete(requestUri); // Wrong method.
        await WHttp.get(requestUri); // Matches.
        await WHttp.get(requestUri); // Matches again.
        expect(MockTransports.http.numPendingRequests, equals(2));
      });

      test(
          'registers a handler for all requests with matching URI and ANY method',
          () async {
        WResponse ok = new MockWResponse.ok();
        MockTransports.http.when(requestUri, (WRequest request) async => ok);
        WHttp.get(Uri.parse('/wrong')); // Wrong URI.
        await WHttp.delete(requestUri); // Matches.
        await WHttp.get(requestUri); // Matches.
        await WHttp.get(requestUri); // Matches again.
        expect(MockTransports.http.numPendingRequests, equals(1));
      });

      test('registers handler that throws to cause request failure', () async {
        MockTransports.http.when(
            requestUri, (WRequest request) async => throw new Exception());
        expect(WHttp.get(requestUri), throws);
      });
    });
  });
}
