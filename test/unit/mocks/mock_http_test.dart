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

@TestOn('browser')
import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/mock.dart';

import '../../naming.dart';
import '../../utils.dart' show nextTick;

void main() {
  Naming naming = new Naming()
    ..testType = testTypeUnit
    ..topic = topicMocks;

  group(naming.toString(), () {
    group('TransportMocks.http', () {
      Uri requestUri = Uri.parse('/mock/test');

      setUp(() {
        configureWTransportForTest();
        MockTransports.reset();
      });

      test('causeFailureOnOpen() should cause request to throw', () async {
        Request request = new Request();
        MockTransports.http.causeFailureOnOpen(request);
        expect(request.get(uri: requestUri), throws);
      });

      test('verifies that requests are mock requests before controlling them',
          () {
        BaseRequest request;
        expect(() {
          MockTransports.http.completeRequest(request);
        }, throwsArgumentError);
      });

      group('completeRequest()', () {
        test('completes a request with 200 OK by default', () async {
          Request request = new Request();
          MockTransports.http.completeRequest(request);
          expect((await request.get(uri: requestUri)).status, equals(200));
        });

        test('can complete a request with custom response', () async {
          Request request = new Request();
          Response response = new MockResponse(202);
          MockTransports.http.completeRequest(request, response: response);
          expect((await request.get(uri: requestUri)).status, equals(202));
        });
      });

      group('expect()', () {
        test('expected request completes automatically with 200 OK by default',
            () async {
          MockTransports.http.expect('GET', requestUri);
          expect((await Http.get(requestUri)).status, equals(200));
        });

        test('expected request with custom response', () async {
          Response response = new MockResponse(202);
          MockTransports.http.expect('POST', requestUri, respondWith: response);
          expect((await Http.post(requestUri)).status, equals(202));
        });

        test('expected request failure', () async {
          Exception exception = new Exception('Custom exception');
          MockTransports.http.expect('DELETE', requestUri, failWith: exception);
          expect(Http.delete(requestUri), throwsA(predicate((error) {
            return error.toString().contains('Custom exception');
          })));
        });

        test('expected request has to match URI and method', () async {
          MockTransports.http.expect('GET', requestUri);
          // ignore: unawaited_futures
          Http.delete(requestUri); // Wrong method
          // ignore: unawaited_futures
          Http.get(Uri.parse('/wrong')); // Wrong URI
          await Http.get(requestUri); // Correct
          expect(MockTransports.http.numPendingRequests, equals(2));
        });

        test('supports failWith, or respondWith, but not both', () {
          expect(() {
            MockTransports.http.expect('GET', requestUri,
                failWith: new Exception(), respondWith: new MockResponse.ok());
          }, throwsArgumentError);
        });
      });

      group('expectPattern()', () {
        test('expected request completes automatically with 200 OK by default',
            () async {
          MockTransports.http.expectPattern('GET', requestUri.toString());
          expect((await Http.get(requestUri)).status, equals(200));
        });

        test('expected request with custom response', () async {
          Response response = new MockResponse(202);
          MockTransports.http.expectPattern('POST', requestUri.toString(),
              respondWith: response);
          expect((await Http.post(requestUri)).status, equals(202));
        });

        test('expected request failure', () async {
          Exception exception = new Exception('Custom exception');
          MockTransports.http.expectPattern('DELETE', requestUri.toString(),
              failWith: exception);
          expect(Http.delete(requestUri), throwsA(predicate((error) {
            return error.toString().contains('Custom exception');
          })));
        });

        test('expected request has to match URI and method', () async {
          MockTransports.http.expectPattern('GET', requestUri.toString());
          // ignore: unawaited_futures
          Http.delete(requestUri); // Wrong method
          // ignore: unawaited_futures
          Http.get(Uri.parse('/wrong')); // Wrong URI
          await Http.get(requestUri); // Correct
          expect(MockTransports.http.numPendingRequests, equals(2));
        });

        test('supports failWith, or respondWith, but not both', () {
          expect(() {
            MockTransports.http.expectPattern('GET', requestUri.toString(),
                failWith: new Exception(), respondWith: new MockResponse.ok());
          }, throwsArgumentError);
        });

        test('handles requests that match a pattern', () async {
          var pattern = new RegExp('https:\/\/(google|github)\.com');

          // ignore: unawaited_futures
          Http.get(Uri.parse('https://example.com')); // Wrong URI.

          MockTransports.http.expectPattern('GET', pattern);
          await Http.get(Uri.parse('https://google.com'));

          MockTransports.http.expectPattern('GET', pattern);
          await Http.get(Uri.parse('https://github.com'));

          expect(MockTransports.http.numPendingRequests, equals(1));
        });
      });

      group('failRequest()', () {
        test('causes request to throw', () async {
          Request request = new Request();
          MockTransports.http.failRequest(request);
          expect(request.get(uri: requestUri), throws);
        });

        test('can include a custom exception', () async {
          Request request = new Request();
          MockTransports.http
              .failRequest(request, error: new Exception('Custom exception'));
          expect(request.get(uri: requestUri), throwsA(predicate((error) {
            return error.toString().contains('Custom exception');
          })));
        });

        test('can include a custom response', () async {
          Request request = new Request();
          Response response = new MockResponse.internalServerError();
          MockTransports.http.failRequest(request, response: response);
          expect(request.get(uri: requestUri), throwsA(predicate((error) {
            return error is RequestException && error.response.status == 500;
          })));
        });
      });

      test(
          'reset() should clear all expectations, pending requests, and handlers',
          () async {
        MockTransports.http
            .when(requestUri, (req) async => new MockResponse.ok());
        MockTransports.http.whenPattern(
            requestUri.toString(), (req, match) async => new MockResponse.ok());
        MockTransports.http.expect('GET', Uri.parse('/expected'));
        MockTransports.http.expectPattern('GET', '/expected');
        Request request = new Request();
        // ignore: unawaited_futures
        request.get(uri: Uri.parse('/other'));
        MockPlainTextRequest mockRequest = request;
        await mockRequest.onSent;
        expect(MockTransports.http.numPendingRequests, equals(1));

        MockTransports.http.reset();

        // Would have been handled by either of the handlers, but should no
        // longer be:
        Request request2 = new Request();
        // ignore: unawaited_futures
        request2.delete(uri: requestUri);
        MockPlainTextRequest mockRequest2 = request2;
        await mockRequest2.onSent;

        // Would have been expected, but should no longer be:
        Request request3 = new Request();
        // ignore: unawaited_futures
        request3.get(uri: Uri.parse('/expected'));
        MockPlainTextRequest mockRequest3 = request3;
        await mockRequest3.onSent;

        expect(MockTransports.http.numPendingRequests, equals(2));
      });

      group('verifyNoOutstandingExceptions()', () {
        test(
            'does not throw if no pending requests and no unfulfilled expectations',
            () {
          MockTransports.http.verifyNoOutstandingExceptions();
        });

        test('throws if requests are pending', () async {
          Request request = new Request();
          // ignore: unawaited_futures
          request.get(uri: requestUri);
          MockPlainTextRequest mockRequest = request;
          await mockRequest.onSent;
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
        test(
            'registers a handler for all requests with matching URI and method',
            () async {
          Response ok = new MockResponse.ok();
          MockTransports.http.when(requestUri, (_) async => ok, method: 'GET');
          // ignore: unawaited_futures
          Http.get(Uri.parse('/wrong')); // Wrong URI.
          // ignore: unawaited_futures
          Http.delete(requestUri); // Wrong method.
          await Http.get(requestUri); // Matches.
          await Http.get(requestUri); // Matches again.
          expect(MockTransports.http.numPendingRequests, equals(2));
        });

        test(
            'registers a handler for all requests with matching URI and ANY method',
            () async {
          Response ok = new MockResponse.ok();
          MockTransports.http.when(requestUri, (_) async => ok);
          // ignore: unawaited_futures
          Http.get(Uri.parse('/wrong')); // Wrong URI.
          await Http.delete(requestUri); // Matches.
          await Http.get(requestUri); // Matches.
          await Http.get(requestUri); // Matches again.
          expect(MockTransports.http.numPendingRequests, equals(1));
        });

        test('supports all standard methods', () async {
          var ok = new MockResponse.ok();
          MockTransports.http
              .when(requestUri, (_) async => ok, method: 'DELETE');
          MockTransports.http.when(requestUri, (_) async => ok, method: 'GET');
          MockTransports.http.when(requestUri, (_) async => ok, method: 'HEAD');
          MockTransports.http
              .when(requestUri, (_) async => ok, method: 'OPTIONS');
          MockTransports.http
              .when(requestUri, (_) async => ok, method: 'PATCH');
          MockTransports.http.when(requestUri, (_) async => ok, method: 'POST');
          MockTransports.http.when(requestUri, (_) async => ok, method: 'PUT');

          await Http.delete(requestUri);
          await Http.get(requestUri);
          await Http.head(requestUri);
          await Http.options(requestUri);
          await Http.patch(requestUri);
          await Http.post(requestUri);
          await Http.put(requestUri);
        });

        test('supports custom method', () async {
          var ok = new MockResponse.ok();
          MockTransports.http.when(requestUri, (_) async => ok, method: 'COPY');
          await Http.send('COPY', requestUri);
        });

        test('registers handler that throws to cause request failure',
            () async {
          MockTransports.http
              .when(requestUri, (_) async => throw new Exception());
          expect(Http.get(requestUri), throws);
        });

        test('registers a handler that can be canceled', () async {
          var ok = new MockResponse.ok();
          var handler = MockTransports.http.when(requestUri, (_) async => ok);
          await Http.get(requestUri);
          handler.cancel();
          // ignore: unawaited_futures
          Http.get(requestUri);
          await nextTick();
          expect(MockTransports.http.numPendingRequests, equals(1));
        });

        test('canceling a handler does nothing if handler no longer exists',
            () async {
          var oldHandler = MockTransports.http
              .when(requestUri, (_) async => new MockResponse.notFound());
          MockTransports.http
              .when(requestUri, (_) async => new MockResponse.ok());
          expect(() {
            oldHandler.cancel();
          }, returnsNormally);
          await Http.get(requestUri);

          // Test the same, but with a specific method.
          oldHandler = MockTransports.http.when(
              requestUri, (_) async => new MockResponse.notFound(),
              method: 'DELETE');
          MockTransports.http.when(
              requestUri, (_) async => new MockResponse.ok(),
              method: 'DELETE');
          expect(() {
            oldHandler.cancel();
          }, returnsNormally);
          await Http.get(requestUri);
        });

        test('canceling a handler does nothing if handler was reset', () async {
          var oldHandler = MockTransports.http
              .when(requestUri, (_) async => new MockResponse.ok());
          MockTransports.reset();
          expect(() {
            oldHandler.cancel();
          }, returnsNormally);

          // ignore: unawaited_futures
          Http.get(requestUri);
          await nextTick();
          expect(MockTransports.http.numPendingRequests, equals(1));
        });
      });

      group('whenPattern()', () {
        test(
            'registers a handler for all requests with a matching URI and method',
            () async {
          var ok = new MockResponse.ok();
          MockTransports.http.whenPattern(
              requestUri.toString(), (_a, _b) async => ok,
              method: 'GET');
          // ignore: unawaited_futures
          Http.get(Uri.parse('/wrong')); // Wrong URI.
          // ignore: unawaited_futures
          Http.delete(requestUri); // Wrong method.
          await Http.get(requestUri); // Matches.
          await Http.get(requestUri); // Matches again.
          expect(MockTransports.http.numPendingRequests, equals(2));
        });

        test(
            'registers a handler for all requests with a matching URI and ANY method',
            () async {
          var ok = new MockResponse.ok();
          MockTransports.http
              .whenPattern(requestUri.toString(), (_a, _b) async => ok);
          // ignore: unawaited_futures
          Http.get(Uri.parse('/wrong')); // Wrong URI.
          await Http.delete(requestUri); // Matches.
          await Http.get(requestUri); // Matches.
          await Http.get(requestUri); // Matches again.
          expect(MockTransports.http.numPendingRequests, equals(1));
        });

        test('registers a handler that throws to cause request failure',
            () async {
          MockTransports.http.whenPattern(
              requestUri.toString(), (_a, _b) async => throw new Exception());
          expect(Http.get(requestUri), throws);
        });

        test(
            'registers a handler for all requests with a partially matching URI',
            () async {
          var pattern = new RegExp('https:\/\/(google|github)\.com.*');
          var ok = new MockResponse.ok();
          MockTransports.http.whenPattern(pattern, (_a, _b) async => ok);
          // ignore: unawaited_futures
          Http.get(Uri.parse('/wrong')); // Wrong URI.
          await Http.get(Uri.parse('https://google.com'));
          await Http.get(Uri.parse('https://github.com/Workiva/w_transport'));
          expect(MockTransports.http.numPendingRequests, equals(1));
        });

        test('handler should recieve the Match instance from the pattern test',
            () async {
          var pattern = new RegExp('https:\/\/(google|github)\.com');
          var matches = <Match>[];
          MockTransports.http.whenPattern(pattern, (_, match) async {
            matches.add(match);
            return new MockResponse.ok();
          });
          await Http.get(Uri.parse('https://google.com'));
          await Http.get(Uri.parse('https://github.com'));

          expect(matches[0].group(0), equals('https://google.com'));
          expect(matches[0].group(1), equals('google'));

          expect(matches[1].group(0), equals('https://github.com'));
          expect(matches[1].group(1), equals('github'));
        });

        test('registers a handler that can be canceled', () async {
          var ok = new MockResponse.ok();
          var handler = MockTransports.http
              .whenPattern(requestUri.toString(), (_a, _b) async => ok);
          await Http.get(requestUri);
          handler.cancel();
          // ignore: unawaited_futures
          Http.get(requestUri);
          await nextTick();
          expect(MockTransports.http.numPendingRequests, equals(1));
        });

        test('canceling a handler does nothing if handler no longer exists',
            () async {
          var oldHandler = MockTransports.http.whenPattern(
              requestUri.toString(),
              (_a, _b) async => new MockResponse.notFound());
          MockTransports.http.whenPattern(
              requestUri.toString(), (_a, _b) async => new MockResponse.ok());
          expect(() {
            oldHandler.cancel();
          }, returnsNormally);
          await Http.get(requestUri);

          // Test the same, but with a specific method.
          oldHandler = MockTransports.http.whenPattern(requestUri.toString(),
              (_a, _b) async => new MockResponse.notFound(),
              method: 'DELETE');
          MockTransports.http.whenPattern(
              requestUri.toString(), (_a, _b) async => new MockResponse.ok(),
              method: 'DELETE');
          expect(() {
            oldHandler.cancel();
          }, returnsNormally);
          await Http.get(requestUri);
        });

        test('canceling a handler does nothing if handler was reset', () async {
          var oldHandler = MockTransports.http.whenPattern(
              requestUri.toString(), (_a, _b) async => new MockResponse.ok());
          MockTransports.reset();
          expect(() {
            oldHandler.cancel();
          }, returnsNormally);

          // ignore: unawaited_futures
          Http.get(requestUri);
          await nextTick();
          expect(MockTransports.http.numPendingRequests, equals(1));
        });
      });
    });
  });
}
