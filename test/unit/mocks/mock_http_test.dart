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
import 'package:w_transport/mock.dart';
import 'package:w_transport/w_transport.dart' as transport;

import 'package:w_transport/src/http/mock/http_client.dart';
import 'package:w_transport/src/mocks/mock_transports.dart'
    show MockHttpInternal;

import '../../naming.dart';
import '../../utils.dart' show nextTick;

void main() {
  final naming = Naming()
    ..testType = testTypeUnit
    ..topic = topicMocks;

  group(naming.toString(), () {
    final requestUri = Uri.parse('/mock/test');

    setUp(() {
      MockTransports.install();
    });

    tearDown(() async {
      MockTransports.verifyNoOutstandingExceptions();
      await MockTransports.uninstall();
    });

    test('MockClient extends MockHttpClient', () {
      // ignore: deprecated_member_use_from_same_package
      expect(MockClient(null), isA<MockHttpClient>());
    });

    group('TransportMocks.http', () {
      test('causeFailureOnOpen() should cause request to throw', () async {
        final request = transport.Request();
        MockTransports.http.causeFailureOnOpen(request);
        expect(request.get(uri: requestUri),
            throwsA(isA<transport.RequestException>()));
      });

      test('verifies that requests are mock requests before controlling them',
          () {
        transport.BaseRequest request;
        expect(() {
          // ignore: deprecated_member_use_from_same_package
          MockTransports.http.completeRequest(request);
        }, throwsArgumentError);
      });

      group('completeRequest()', () {
        test('completes a request with 200 OK by default', () async {
          final request = transport.Request();
          // ignore: deprecated_member_use_from_same_package
          MockTransports.http.completeRequest(request);
          expect((await request.get(uri: requestUri)).status, equals(200));
        });

        test('can complete a request with custom response', () async {
          final request = transport.Request();
          final response = MockResponse(202);
          // ignore: deprecated_member_use_from_same_package
          MockTransports.http.completeRequest(request, response: response);
          expect((await request.get(uri: requestUri)).status, equals(202));
        });
      });

      group('expect()', () {
        test('expected request completes automatically with 200 OK by default',
            () async {
          MockTransports.http.expect('GET', requestUri);
          expect((await transport.Http.get(requestUri)).status, equals(200));
        });

        test('expected request with custom response', () async {
          final response = MockResponse(202);
          MockTransports.http.expect('POST', requestUri, respondWith: response);
          expect((await transport.Http.post(requestUri)).status, equals(202));
        });

        test('expected request failure', () async {
          final exception = Exception('Custom exception');
          MockTransports.http.expect('DELETE', requestUri, failWith: exception);
          expect(transport.Http.delete(requestUri), throwsA(predicate((error) {
            return error.toString().contains('Custom exception');
          })));
        });

        test('expected request has to match URI and method', () async {
          MockTransports.http.expect('GET', requestUri);
          // ignore: unawaited_futures
          transport.Http.delete(requestUri); // Wrong method
          // ignore: unawaited_futures
          transport.Http.get(Uri.parse('/wrong')); // Wrong URI
          await transport.Http.get(requestUri); // Correct
          expect(MockTransports.http.numPendingRequests, equals(2));
          await MockTransports.reset();
        });

        test('supports failWith, or respondWith, but not both', () async {
          expect(() {
            MockTransports.http.expect('GET', requestUri,
                failWith: Exception(), respondWith: MockResponse.ok());
          }, throwsArgumentError);
          await MockTransports.reset();
        });
      });

      group('expectPattern()', () {
        test('expected request completes automatically with 200 OK by default',
            () async {
          MockTransports.http.expectPattern('GET', requestUri.toString());
          expect((await transport.Http.get(requestUri)).status, equals(200));
        });

        test('expected request with custom response', () async {
          final response = MockResponse(202);
          MockTransports.http.expectPattern('POST', requestUri.toString(),
              respondWith: response);
          expect((await transport.Http.post(requestUri)).status, equals(202));
        });

        test('expected request failure', () async {
          final exception = Exception('Custom exception');
          MockTransports.http.expectPattern('DELETE', requestUri.toString(),
              failWith: exception);
          expect(transport.Http.delete(requestUri), throwsA(predicate((error) {
            return error.toString().contains('Custom exception');
          })));
        });

        test('expected request has to match URI and method', () async {
          MockTransports.http.expectPattern('GET', requestUri.toString());
          // ignore: unawaited_futures
          transport.Http.delete(requestUri); // Wrong method
          // ignore: unawaited_futures
          transport.Http.get(Uri.parse('/wrong')); // Wrong URI
          await transport.Http.get(requestUri); // Correct
          expect(MockTransports.http.numPendingRequests, equals(2));
          await MockTransports.reset();
        });

        test('supports failWith, or respondWith, but not both', () async {
          expect(() {
            MockTransports.http.expectPattern('GET', requestUri.toString(),
                failWith: Exception(), respondWith: MockResponse.ok());
          }, throwsArgumentError);
          await MockTransports.reset();
        });

        test('handles requests that match a pattern', () async {
          final pattern = RegExp('https:\/\/(google|github)\.com');

          // ignore: unawaited_futures
          transport.Http.get(Uri.parse('https://example.com')); // Wrong URI.

          MockTransports.http.expectPattern('GET', pattern);
          await transport.Http.get(Uri.parse('https://google.com'));

          MockTransports.http.expectPattern('GET', pattern);
          await transport.Http.get(Uri.parse('https://github.com'));

          expect(MockTransports.http.numPendingRequests, equals(1));
          await MockTransports.reset();
        });
      });

      group('failRequest()', () {
        test('causes request to throw', () async {
          final request = transport.Request();
          // ignore: deprecated_member_use_from_same_package
          MockTransports.http.failRequest(request);
          expect(request.get(uri: requestUri),
              throwsA(isA<transport.RequestException>()));
        });

        test('can include a custom exception', () async {
          final request = transport.Request();
          MockTransports.http
              // ignore: deprecated_member_use_from_same_package
              .failRequest(request, error: Exception('Custom exception'));
          expect(request.get(uri: requestUri), throwsA(predicate((error) {
            return error.toString().contains('Custom exception');
          })));
        });

        test('can include a custom response', () async {
          final request = transport.Request();
          final response = MockResponse.internalServerError();
          // ignore: deprecated_member_use_from_same_package
          MockTransports.http.failRequest(request, response: response);
          expect(request.get(uri: requestUri), throwsA(predicate((error) {
            return error is transport.RequestException &&
                error.response.status == 500;
          })));
        });
      });

      test(
          'reset() should clear all expectations, pending requests, and handlers',
          () async {
        MockTransports.http.when(requestUri, (req) async => MockResponse.ok());
        MockTransports.http.whenPattern(
            requestUri.toString(), (req, match) async => MockResponse.ok());
        MockTransports.http.expect('GET', Uri.parse('/expected'));
        MockTransports.http.expectPattern('GET', '/expected');
        final request = transport.Request();
        // ignore: unawaited_futures
        request.get(uri: Uri.parse('/other'));
        // ignore: deprecated_member_use_from_same_package
        MockPlainTextRequest mockRequest = request;
        await mockRequest.onSent;
        expect(MockTransports.http.numPendingRequests, equals(1));

        await MockTransports.reset();

        // Would have been handled by either of the handlers, but should no
        // longer be:
        final request2 = transport.Request();
        // ignore: unawaited_futures
        request2.delete(uri: requestUri);
        // ignore: deprecated_member_use_from_same_package
        MockPlainTextRequest mockRequest2 = request2;
        await mockRequest2.onSent;

        // Would have been expected, but should no longer be:
        final request3 = transport.Request();
        // ignore: unawaited_futures
        request3.get(uri: Uri.parse('/expected'));
        // ignore: deprecated_member_use_from_same_package
        MockPlainTextRequest mockRequest3 = request3;
        await mockRequest3.onSent;

        expect(MockTransports.http.numPendingRequests, equals(2));
        await MockTransports.reset();
      });

      group('verifyNoOutstandingExceptions()', () {
        test(
            'does not throw if no pending requests and no unfulfilled expectations',
            () {
          MockTransports.http.verifyNoOutstandingExceptions();
        });

        test('throws if requests are pending', () async {
          final request = transport.Request();
          // ignore: unawaited_futures
          request.get(uri: requestUri);
          // ignore: deprecated_member_use_from_same_package
          MockPlainTextRequest mockRequest = request;
          await mockRequest.onSent;
          expect(() {
            MockTransports.http.verifyNoOutstandingExceptions();
          }, throwsStateError);

          await MockTransports.reset();
        });

        test('throws if expectation is unfulfilled', () async {
          MockTransports.http.expect('GET', requestUri);
          expect(() {
            MockTransports.http.verifyNoOutstandingExceptions();
          }, throwsStateError);

          await MockTransports.reset();
        });
      });

      group('when()', () {
        test(
            'registers a handler for all requests with matching URI and method',
            () async {
          final ok = MockResponse.ok();
          MockTransports.http.when(requestUri, (_) async => ok, method: 'GET');
          // ignore: unawaited_futures
          transport.Http.get(Uri.parse('/wrong')); // Wrong URI.
          // ignore: unawaited_futures
          transport.Http.delete(requestUri); // Wrong method.
          await transport.Http.get(requestUri); // Matches.
          await transport.Http.get(requestUri); // Matches again.
          expect(MockTransports.http.numPendingRequests, equals(2));

          await MockTransports.reset();
        });

        test(
            'registers a handler for all requests with matching URI and ANY method',
            () async {
          final ok = MockResponse.ok();
          MockTransports.http.when(requestUri, (_) async => ok);
          // ignore: unawaited_futures
          transport.Http.get(Uri.parse('/wrong')); // Wrong URI.
          await transport.Http.delete(requestUri); // Matches.
          await transport.Http.get(requestUri); // Matches.
          await transport.Http.get(requestUri); // Matches again.
          expect(MockTransports.http.numPendingRequests, equals(1));

          await MockTransports.reset();
        });

        test('supports all standard methods', () async {
          final ok = MockResponse.ok();
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

          await transport.Http.delete(requestUri);
          await transport.Http.get(requestUri);
          await transport.Http.head(requestUri);
          await transport.Http.options(requestUri);
          await transport.Http.patch(requestUri);
          await transport.Http.post(requestUri);
          await transport.Http.put(requestUri);
        });

        test('supports custom method', () async {
          final ok = MockResponse.ok();
          MockTransports.http.when(requestUri, (_) async => ok, method: 'COPY');
          await transport.Http.send('COPY', requestUri);
        });

        test('registers handler that throws to cause request failure',
            () async {
          MockTransports.http.when(requestUri, (_) async => throw Exception());
          expect(transport.Http.get(requestUri),
              throwsA(isA<transport.RequestException>()));
        });

        test('registers a handler that can be canceled', () async {
          final ok = MockResponse.ok();
          final handler = MockTransports.http.when(requestUri, (_) async => ok);
          await transport.Http.get(requestUri);
          handler.cancel();
          // ignore: unawaited_futures
          transport.Http.get(requestUri);
          await nextTick();
          expect(MockTransports.http.numPendingRequests, equals(1));

          await MockTransports.reset();
        });

        test('canceling a handler does nothing if handler no longer exists',
            () async {
          MockHttpHandler oldHandler = MockTransports.http
              .when(requestUri, (_) async => MockResponse.notFound());
          MockTransports.http.when(requestUri, (_) async => MockResponse.ok());
          expect(() {
            oldHandler.cancel();
          }, returnsNormally);
          await transport.Http.get(requestUri);

          // Test the same, but with a specific method.
          oldHandler = MockTransports.http.when(
              requestUri, (_) async => MockResponse.notFound(),
              method: 'DELETE');
          MockTransports.http.when(requestUri, (_) async => MockResponse.ok(),
              method: 'DELETE');
          expect(() {
            oldHandler.cancel();
          }, returnsNormally);
          await transport.Http.get(requestUri);
        });

        test('canceling a handler does nothing if handler was reset', () async {
          MockHttpHandler oldHandler = MockTransports.http
              .when(requestUri, (_) async => MockResponse.ok());
          await MockTransports.reset();
          expect(() {
            oldHandler.cancel();
          }, returnsNormally);

          // ignore: unawaited_futures
          transport.Http.get(requestUri);
          await nextTick();
          expect(MockTransports.http.numPendingRequests, equals(1));

          await MockTransports.reset();
        });
      });

      group('whenPattern()', () {
        test(
            'registers a handler for all requests with a matching URI and method',
            () async {
          final ok = MockResponse.ok();
          MockTransports.http.whenPattern(
              requestUri.toString(), (_a, _b) async => ok,
              method: 'GET');
          // ignore: unawaited_futures
          transport.Http.get(Uri.parse('/wrong')); // Wrong URI.
          // ignore: unawaited_futures
          transport.Http.delete(requestUri); // Wrong method.
          await transport.Http.get(requestUri); // Matches.
          await transport.Http.get(requestUri); // Matches again.
          expect(MockTransports.http.numPendingRequests, equals(2));

          await MockTransports.reset();
        });

        test(
            'registers a handler for all requests with a matching URI and ANY method',
            () async {
          final ok = MockResponse.ok();
          MockTransports.http
              .whenPattern(requestUri.toString(), (_a, _b) async => ok);
          // ignore: unawaited_futures
          transport.Http.get(Uri.parse('/wrong')); // Wrong URI.
          await transport.Http.delete(requestUri); // Matches.
          await transport.Http.get(requestUri); // Matches.
          await transport.Http.get(requestUri); // Matches again.
          expect(MockTransports.http.numPendingRequests, equals(1));

          await MockTransports.reset();
        });

        test('registers a handler that throws to cause request failure',
            () async {
          MockTransports.http.whenPattern(
              requestUri.toString(), (_a, _b) async => throw Exception());
          expect(transport.Http.get(requestUri),
              throwsA(isA<transport.RequestException>()));
        });

        test(
            'registers a handler for all requests with a partially matching URI',
            () async {
          final pattern = RegExp('https:\/\/(google|github)\.com.*');
          final ok = MockResponse.ok();
          MockTransports.http.whenPattern(pattern, (_a, _b) async => ok);
          // ignore: unawaited_futures
          transport.Http.get(Uri.parse('/wrong')); // Wrong URI.
          await transport.Http.get(Uri.parse('https://google.com'));
          await transport.Http.get(
              Uri.parse('https://github.com/Workiva/w_transport'));
          expect(MockTransports.http.numPendingRequests, equals(1));

          await MockTransports.reset();
        });

        test('handler should recieve the Match instance from the pattern test',
            () async {
          final pattern = RegExp('https:\/\/(google|github)\.com');
          final matches = <Match>[];
          MockTransports.http.whenPattern(pattern, (_, match) async {
            matches.add(match);
            return MockResponse.ok();
          });
          await transport.Http.get(Uri.parse('https://google.com'));
          await transport.Http.get(Uri.parse('https://github.com'));

          expect(matches[0].group(0), equals('https://google.com'));
          expect(matches[0].group(1), equals('google'));

          expect(matches[1].group(0), equals('https://github.com'));
          expect(matches[1].group(1), equals('github'));
        });

        test('registers a handler that can be canceled', () async {
          final ok = MockResponse.ok();
          final handler = MockTransports.http
              .whenPattern(requestUri.toString(), (_a, _b) async => ok);
          await transport.Http.get(requestUri);
          handler.cancel();
          // ignore: unawaited_futures
          transport.Http.get(requestUri);
          await nextTick();
          expect(MockTransports.http.numPendingRequests, equals(1));

          await MockTransports.reset();
        });

        test('canceling a handler does nothing if handler no longer exists',
            () async {
          MockHttpHandler oldHandler = MockTransports.http.whenPattern(
              requestUri.toString(), (_a, _b) async => MockResponse.notFound());
          MockTransports.http.whenPattern(
              requestUri.toString(), (_a, _b) async => MockResponse.ok());
          expect(() {
            oldHandler.cancel();
          }, returnsNormally);
          await transport.Http.get(requestUri);

          // Test the same, but with a specific method.
          oldHandler = MockTransports.http.whenPattern(
              requestUri.toString(), (_a, _b) async => MockResponse.notFound(),
              method: 'DELETE');
          MockTransports.http.whenPattern(
              requestUri.toString(), (_a, _b) async => MockResponse.ok(),
              method: 'DELETE');
          expect(() {
            oldHandler.cancel();
          }, returnsNormally);
          await transport.Http.get(requestUri);
        });

        test('canceling a handler does nothing if handler was reset', () async {
          MockHttpHandler oldHandler = MockTransports.http.whenPattern(
              requestUri.toString(), (_a, _b) async => MockResponse.ok());
          await MockTransports.reset();
          expect(() {
            oldHandler.cancel();
          }, returnsNormally);

          // ignore: unawaited_futures
          transport.Http.get(requestUri);
          await nextTick();
          expect(MockTransports.http.numPendingRequests, equals(1));

          await MockTransports.reset();
        });
      });
    });

    group('MockHttpInternal', () {
      group('hasHandlerForRequest()', () {
        test('returns true if there is a matching expectation', () async {
          MockTransports.http.expect('GET', requestUri);
          expect(MockHttpInternal.hasHandlerForRequest('GET', requestUri, {}),
              isTrue);
          await MockTransports.reset();
        });

        test('returns true if there is a matching handler', () async {
          MockTransports.http.when(
              requestUri, (FinalizedRequest request) async => MockResponse.ok(),
              method: 'GET');
          expect(MockHttpInternal.hasHandlerForRequest('GET', requestUri, {}),
              isTrue);
          await MockTransports.reset();
        });

        test('returns false if there are no matching expectations nor handlers',
            () {
          expect(MockHttpInternal.hasHandlerForRequest('GET', requestUri, {}),
              isFalse);
        });
      });
    });
  });
}
