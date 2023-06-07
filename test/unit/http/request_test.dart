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
import 'dart:async';
import 'dart:convert';

import 'package:test/test.dart';
import 'package:w_transport/mock.dart';
import 'package:w_transport/w_transport.dart' as transport;
import 'package:w_transport/w_transport.dart';

import '../../naming.dart';

void main() {
  final naming = Naming()
    ..testType = testTypeUnit
    ..topic = topicHttp;

  group(naming.toString(), () {
    setUp(() async {
      await MockTransports.reset();
      configureWTransportForTest();
    });

    tearDown(() {
      MockTransports.verifyNoOutstandingExceptions();
    });

    transport.FormRequest formReqFactory({bool? withBody = false}) {
      if (!withBody!) return transport.FormRequest();
      return transport.FormRequest()..fields['field'] = 'value';
    }

    transport.JsonRequest jsonReqFactory({bool? withBody = false}) {
      if (!withBody!) return transport.JsonRequest();
      return transport.JsonRequest()
        ..body = [
          {'field': 'value'}
        ];
    }

    transport.MultipartRequest multipartReqFactory({bool? withBody}) {
      // Multipart requests can't be empty.
      return transport.MultipartRequest()..fields['field'] = 'value';
    }

    transport.Request reqFactory({bool? withBody = false}) {
      if (!withBody!) return transport.Request();
      return transport.Request()..body = 'body';
    }

    transport.StreamedRequest streamedReqFactory({bool? withBody = false}) {
      if (!withBody!) return transport.StreamedRequest();
      return transport.StreamedRequest()
        ..body = Stream.fromIterable([utf8.encode('bytes')])
        ..contentLength = utf8.encode('bytes').length;
    }

    _runCommonRequestSuiteFor('FormRequest', formReqFactory);
    _runCommonRequestSuiteFor('JsonRequest', jsonReqFactory);
    _runCommonRequestSuiteFor('MultipartRequest', multipartReqFactory);
    _runCommonRequestSuiteFor('Request', reqFactory);
    _runCommonRequestSuiteFor('StreamedRequest', streamedReqFactory);

    _runAutoRetryTestSuiteFor('FormRequest', formReqFactory);
    _runAutoRetryTestSuiteFor('JsonRequest', jsonReqFactory);
    _runAutoRetryTestSuiteFor('MultipartRequest', multipartReqFactory);
    _runAutoRetryTestSuiteFor('Request', reqFactory);

    test('clone() of request from client', () async {
      final requestUri = Uri.parse('/mock/request');

      // Hold the requests long enough to let the client cancel them on close
      MockTransports.http.when(requestUri, (request) async {
        await Future.delayed(Duration(seconds: 10));
        return MockResponse.ok();
      }, method: 'GET');

      final client = transport.HttpClient();
      final clientReqs = <transport.BaseRequest>[
        client.newFormRequest(),
        client.newJsonRequest(),
        client.newMultipartRequest()..fields['f1'] = 'v1',
        client.newRequest()
      ];
      for (final orig in clientReqs) {
        final clone = orig.clone()!..uri = requestUri;
        expect(clone.get(), throwsA(predicate((dynamic exception) {
          return exception is transport.RequestException &&
              exception.toString().contains('client was closed');
        })));
      }
      client.close();
    });

    test('RetryBackOff.duration (deprecated) should be forwarded to `interval`',
        () {
      final interval = Duration(seconds: 10);

      final exponentialBackOff = transport.RetryBackOff.exponential(interval);
      // ignore: deprecated_member_use_from_same_package
      expect(exponentialBackOff.duration, equals(interval));
      // ignore: deprecated_member_use_from_same_package
      expect(exponentialBackOff.duration, equals(exponentialBackOff.interval));

      final fixedBackOff = transport.RetryBackOff.fixed(interval);
      // ignore: deprecated_member_use_from_same_package
      expect(fixedBackOff.duration, equals(interval));
      // ignore: deprecated_member_use_from_same_package
      expect(fixedBackOff.duration, equals(exponentialBackOff.interval));

      final noBackOff = transport.RetryBackOff.none();
      // ignore: deprecated_member_use_from_same_package
      expect(noBackOff.duration, isNull);
      // ignore: deprecated_member_use_from_same_package
      expect(noBackOff.duration, equals(noBackOff.interval));
    });
  });
}

void _runCommonRequestSuiteFor(String name,
    transport.BaseRequest Function({bool? withBody}) requestFactory) {
  group(name, () {
    final requestUri = Uri.parse('/mock/request');
    final requestHeaders = <String, String>{'x-custom': 'header'};

    test('DELETE', () async {
      MockTransports.http.expect('DELETE', requestUri);
      await requestFactory().delete(uri: requestUri);
    });

    test('DELETE with headers', () async {
      MockTransports.http.expect('DELETE', requestUri, headers: requestHeaders);
      await requestFactory().delete(uri: requestUri, headers: requestHeaders);
    });

    test('GET', () async {
      MockTransports.http.expect('GET', requestUri);
      await requestFactory().get(uri: requestUri);
    });

    test('GET with headers', () async {
      MockTransports.http.expect('GET', requestUri, headers: requestHeaders);
      await requestFactory().get(uri: requestUri, headers: requestHeaders);
    });

    test('HEAD', () async {
      MockTransports.http.expect('HEAD', requestUri);
      await requestFactory().head(uri: requestUri);
    });

    test('HEAD with headers', () async {
      MockTransports.http.expect('HEAD', requestUri, headers: requestHeaders);
      await requestFactory().head(uri: requestUri, headers: requestHeaders);
    });

    test('OPTIONS', () async {
      MockTransports.http.expect('OPTIONS', requestUri);
      await requestFactory().options(uri: requestUri);
    });

    test('OPTIONS with headers', () async {
      MockTransports.http
          .expect('OPTIONS', requestUri, headers: requestHeaders);
      await requestFactory().options(uri: requestUri, headers: requestHeaders);
    });

    test('PATCH', () async {
      MockTransports.http.expect('PATCH', requestUri);
      await requestFactory().patch(uri: requestUri);
    });

    test('PATCH with headers', () async {
      MockTransports.http.expect('PATCH', requestUri, headers: requestHeaders);
      await requestFactory().patch(uri: requestUri, headers: requestHeaders);
    });

    test('POST', () async {
      MockTransports.http.expect('POST', requestUri);
      await requestFactory().post(uri: requestUri);
    });

    test('POST with headers', () async {
      MockTransports.http.expect('POST', requestUri, headers: requestHeaders);
      await requestFactory().post(uri: requestUri, headers: requestHeaders);
    });

    test('PUT', () async {
      MockTransports.http.expect('PUT', requestUri);
      await requestFactory().put(uri: requestUri);
    });

    test('PUT with headers', () async {
      MockTransports.http.expect('PUT', requestUri, headers: requestHeaders);
      await requestFactory().put(uri: requestUri, headers: requestHeaders);
    });

    test('custom HTTP method', () async {
      MockTransports.http.expect('COPY', requestUri);
      await requestFactory().send('COPY', uri: requestUri);
    });

    test('custom HTTP method with headers', () async {
      MockTransports.http.expect('COPY', requestUri, headers: requestHeaders);
      await requestFactory()
          .send('COPY', uri: requestUri, headers: requestHeaders);
    });

    // test('DELETE (streamed)', () async {
    //   MockTransports.http.expect('DELETE', requestUri);
    //   await requestFactory().streamDelete(uri: requestUri);
    // });

    test('GET (streamed)', () async {
      MockTransports.http.expect('GET', requestUri);
      await requestFactory().streamGet(uri: requestUri);
    });

    test('HEAD (streamed)', () async {
      MockTransports.http.expect('HEAD', requestUri);
      await requestFactory().streamHead(uri: requestUri);
    });

    test('OPTIONS (streamed)', () async {
      MockTransports.http.expect('OPTIONS', requestUri);
      await requestFactory().streamOptions(uri: requestUri);
    });

    test('PATCH (streamed)', () async {
      MockTransports.http.expect('PATCH', requestUri);
      await requestFactory().streamPatch(uri: requestUri);
    });

    test('POST (streamed)', () async {
      MockTransports.http.expect('POST', requestUri);
      await requestFactory().streamPost(uri: requestUri);
    });

    test('PUT (streamed)', () async {
      MockTransports.http.expect('PUT', requestUri);
      await requestFactory().streamPut(uri: requestUri);
    });

    test('custom HTTP method (streamed)', () async {
      MockTransports.http.expect('COPY', requestUri);
      await requestFactory().streamSend('COPY', uri: requestUri);
    });

    test('URI should be required', () async {
      expect(requestFactory().get(), throwsStateError);
    });

    test(
        'URI and data should be accepted as parameters to a request dispatch method',
        () async {
      final dataCompleter = Completer<String>();
      MockTransports.http.when(requestUri, (FinalizedRequest request) async {
        if (request.body is transport.HttpBody) {
          transport.HttpBody body = request.body as HttpBody;
          dataCompleter.complete(body.asString());
        } else {
          transport.StreamedHttpBody body = request.body as StreamedHttpBody;
          dataCompleter.complete(utf8.decode(await body.toBytes()));
        }

        return MockResponse.ok();
      });
      await requestFactory(withBody: true).post(uri: requestUri);
      expect(await dataCompleter.future, isNotEmpty);
    });

    test('headers given to dispatch method should be merged with existing ones',
        () async {
      MockTransports.http.expect('GET', requestUri,
          headers: {'x-one': '1', 'x-two': '2', 'x-three': '3'});
      final request = requestFactory()
        ..headers = {'x-one': '1', 'x-two': '0'}
        ..uri = requestUri;
      await request.get(headers: {'x-two': '2', 'x-three': '3'});
    });

    test(
        'request cancellation after dispatch but prior to resolution should cancel request',
        () async {
      final request = requestFactory();
      final future = request.get(uri: requestUri);
      await Future.delayed(Duration(milliseconds: 100));
      request.abort();
      expect(future, throwsA(isA<transport.RequestException>()));
      try {
        await future;
        fail('Expected RequestException, but future completed successfully.');
      } catch (error) {
        expect(error, isA<transport.RequestException>());
      }
      expect(request.isDone, isTrue,
          reason: 'canceled request should be marked as "done"');
      expect(request.done, completes,
          reason:
              'canceled request should trigger completion of `done` future');
    });

    test('request cancellation after request has succeeded should do nothing',
        () async {
      MockTransports.http.expect('GET', requestUri);
      final request = requestFactory();
      await request.get(uri: requestUri);
      request.abort();
    });

    test('request cancellation after request has failed should do nothing',
        () async {
      MockTransports.http.expect('GET', requestUri, failWith: Exception());
      final request = requestFactory();
      final future = request.get(uri: requestUri);
      expect(future, throwsA(isA<transport.RequestException>()));
      try {
        await future;
      } catch (_) {}
      request.abort();
    });

    test('request cancellation should accept a custom error', () async {
      final request = requestFactory();
      request.abort(Exception('custom error'));
      expect(request.get(uri: requestUri), throwsA(predicate((dynamic error) {
        return error is transport.RequestException &&
            error.toString().contains('custom error');
      })));
    });

    test('request cancellation should do nothing if already called', () async {
      final request = requestFactory();
      request.abort();
      expect(() {
        request.abort();
      }, returnsNormally);
      expect(request.get(uri: requestUri),
          throwsA(isA<transport.RequestException>()));
    });

    test('request cancellations should not be retried', () async {
      final request = requestFactory();
      request.autoRetry!
        ..enabled = true
        ..test = (request, response, willRetry) async => true;
      final future = request.get(uri: requestUri);
      await Future.delayed(Duration(milliseconds: 100));
      request.abort();
      expect(future, throwsA(predicate((dynamic error) {
        return error is transport.RequestException &&
            error.request!.autoRetry!.numAttempts == 1;
      })));
    });

    test('should wrap an unexpected exception in RequestException', () async {
      final request = requestFactory();
      MockTransports.http.causeFailureOnOpen(request);
      expect(request.get(uri: requestUri),
          throwsA(isA<transport.RequestException>()));
    });

    test('should throw if status code is non-200', () async {
      MockTransports.http.expect('GET', requestUri,
          respondWith: MockResponse.internalServerError());
      final request = requestFactory();
      expect(request.get(uri: requestUri),
          throwsA(isA<transport.RequestException>()));
    });

    test('headers should be unmodifiable once sent', () async {
      MockTransports.http.expect('GET', requestUri);
      final request = requestFactory()
        ..uri = requestUri
        ..headers = {'x-custom': 'value'};
      await request.get();
      expect(() {
        request.headers['x-custom'] = 'changed';
      }, throwsUnsupportedError);
      expect(() {
        request.headers = {'x-custom': 'new'};
      }, throwsStateError);
    });

    test('withCredentials flag should be unmodifiable once sent', () async {
      MockTransports.http.expect('GET', requestUri);
      final request = requestFactory();
      await request.get(uri: requestUri);
      expect(() {
        request.withCredentials = true;
      }, throwsStateError);
    });

    test('request can only be sent once', () async {
      MockTransports.http.expect('GET', requestUri);
      final request = requestFactory();
      final first = request.get(uri: requestUri);
      expect(request.get(uri: requestUri), throwsStateError);
      await first;
    });

    test('isDone should be false prior to request completion', () async {
      MockTransports.http.expect('GET', requestUri);
      final request = requestFactory();
      final future = request.get(uri: requestUri);
      expect(request.isDone, isFalse);
      await future;
    });

    test('isDone should be true after completion', () async {
      MockTransports.http.expect('GET', requestUri);
      final request = requestFactory();
      await request.get(uri: requestUri);
      expect(request.isDone, isTrue);
    });

    test('isDone should be true after failure', () async {
      MockTransports.http
          .expect('GET', requestUri, respondWith: MockResponse.notFound());
      final request = requestFactory();
      final future = request.get(uri: requestUri);
      expect(future, throwsA(isA<transport.RequestException>()));
      try {
        await future;
        fail('Expected RequestException, but future completed successfully.');
      } catch (error) {
        expect(error, isA<transport.RequestException>());
      }
      expect(request.isDone, isTrue);
    });

    test('isDone should be true after cancellation', () async {
      final request = requestFactory();
      final future = request.get(uri: requestUri);
      request.abort();
      try {
        await future;
        fail('Expected RequestException, but future completed successfully.');
      } catch (error) {
        expect(error, isA<transport.RequestException>());
      }
      expect(request.isDone, isTrue);
    });

    test('requestInterceptor allows async modification of request', () async {
      MockTransports.http
          .expect('GET', requestUri, headers: {'x-intercepted': 'true'});
      final request = requestFactory();
      request.requestInterceptor = (transport.BaseRequest request) async {
        request.headers['x-intercepted'] = 'true';
      };
      await request.get(uri: requestUri);
    });

    test(
        'if requestInterceptor throws, the request should fail with that exception',
        () async {
      final request = requestFactory();
      final exception = Exception('interceptor failure');

      request.requestInterceptor = (transport.BaseRequest request) async {
        throw exception;
      };
      expect(request.get(uri: Uri.parse('/test')), throwsA(equals(exception)));
    });

    test('setting requestInterceptor throws if request has been sent',
        () async {
      MockTransports.http.expect('GET', requestUri);
      final request = requestFactory();
      await request.get(uri: requestUri);
      expect(() {
        request.requestInterceptor = (request) async {};
      }, throwsStateError);
    });

    test('responseInterceptor gets FinalizedRequest', () async {
      MockTransports.http.expect('GET', requestUri);
      final request = requestFactory();
      request.responseInterceptor =
          (FinalizedRequest request, response, [exception]) async {
        expect(request.method, equals('GET'));
        expect(request.uri, equals(requestUri));
        return response;
      };
      await request.get(uri: requestUri);
    });

    test('responseInterceptor gets BaseResponse', () async {
      final mockResponse = MockResponse.ok(body: 'original');
      MockTransports.http.expect('GET', requestUri, respondWith: mockResponse);
      final request = requestFactory();
      request.responseInterceptor =
          (request, transport.BaseResponse? response, [exception]) async {
        expect(response, isA<transport.Response>());
        transport.Response standardResponse = response as Response;
        expect(standardResponse.body!.asString(), equals('original'));
        return standardResponse;
      };
      await request.get(uri: requestUri);
    });

    test('responseInterceptor gets no RequestException on successful request',
        () async {
      MockTransports.http.expect('GET', requestUri);
      final request = requestFactory();
      request.responseInterceptor = (request, response, [exception]) async {
        expect(exception, isNull);
        return response;
      };
      await request.get(uri: requestUri);
    });

    test('responseInterceptor gets RequestException on failed request',
        () async {
      MockTransports.http
          .expect('GET', requestUri, failWith: Exception('mock failure'));
      final request = requestFactory();
      request.responseInterceptor =
          (request, response, [transport.RequestException? exception]) async {
        expect(exception, isNotNull);
        expect(exception.toString(), contains('mock failure'));
        return MockResponse.ok();
      };
      expect(request.get(uri: requestUri),
          throwsA(isA<transport.RequestException>()));
    });

    test('responseInterceptor allows replacement of BaseResponse', () async {
      final mockResponse = MockResponse.ok(body: 'original');
      MockTransports.http.expect('GET', requestUri, respondWith: mockResponse);
      final request = requestFactory();
      request.responseInterceptor =
          (request, transport.BaseResponse? response, [exception]) async {
        return transport.Response.fromString(response!.status,
            response.statusText, response.headers!, 'modified');
      };
      final response = await request.get(uri: requestUri);
      expect(response.body!.asString(), equals('modified'));
    });

    test(
        'if responseInterceptor throws, the error should be wrapped in a RequestException',
        () async {
      MockTransports.http.expect('GET', requestUri);
      final request = requestFactory();
      request.responseInterceptor = (request, response, [exception]) async {
        throw Exception('interceptor failure');
      };
      expect(request.get(uri: requestUri), throwsA(predicate((dynamic error) {
        return error is transport.RequestException &&
            error.toString().contains('interceptor failure');
      })));
    });

    test('setting responseInterceptor throws if request has been sent',
        () async {
      MockTransports.http.expect('GET', requestUri);
      final request = requestFactory();
      await request.get(uri: requestUri);
      expect(() {
        request.responseInterceptor =
            (request, response, [exception]) async => MockResponse.ok();
      }, throwsStateError);
    });

    test(
        'should not double-wrap exception when applying responseInterceptor after failure',
        () async {
      final error = Error();
      MockTransports.http.expect('GET', requestUri, failWith: error);
      final request = requestFactory();
      request.responseInterceptor =
          (request, response, [exception]) async => response;
      expect(request.get(uri: requestUri),
          throwsA(predicate((dynamic exception) {
        return exception is transport.RequestException &&
            identical(exception.error, error);
      })));
    });

    test('timeoutThreshold is not enforced if not set', () async {
      final request = requestFactory();
      final future = request.get(uri: requestUri);
      await Future.delayed(Duration(milliseconds: 250));
      // ignore: deprecated_member_use_from_same_package
      MockTransports.http.completeRequest(request);
      await future;
    });

    test('timeoutThreshold does nothing if request completes in time',
        () async {
      final request = requestFactory()
        ..timeoutThreshold = Duration(milliseconds: 500);
      final future = request.get(uri: requestUri);
      await Future.delayed(Duration(milliseconds: 250));
      // ignore: deprecated_member_use_from_same_package
      MockTransports.http.completeRequest(request);
      await future;
    });

    test('timeoutThreshold cancels the request if exceeded', () async {
      final request = requestFactory()
        ..timeoutThreshold = Duration(milliseconds: 500);
      expect(request.get(uri: requestUri), throwsA(predicate((dynamic error) {
        return error is transport.RequestException &&
            error.error is TimeoutException;
      })));
    });

    test(
        'timeoutThreshold cancels the request if exceeded but not if it has already been canceled',
        () async {
      final request = requestFactory()
        ..timeoutThreshold = Duration(milliseconds: 500);
      final future = request.get(uri: requestUri);
      await Future.delayed(Duration(milliseconds: 250));
      request.abort();
      expect(future, throwsA(predicate((dynamic error) {
        return error is transport.RequestException &&
            error.error is! TimeoutException;
      })));
    });

    test('configure() should throw if called after request has been sent',
        () async {
      MockTransports.http.expect('GET', requestUri);
      final request = requestFactory();
      await request.get(uri: requestUri);
      expect(() {
        request.configure((_) {});
      }, throwsStateError);
    });

    test('toString()', () async {
      MockTransports.http.expect('GET', requestUri);
      final request = requestFactory();
      await request.get(uri: requestUri);
      expect(request.toString(), contains('GET'));
      expect(request.toString(), contains(requestUri.toString()));
      expect(request.toString(), contains(request.contentType.toString()));
    });
  });
}

void _runAutoRetryTestSuiteFor(String name,
    transport.BaseRequest Function({bool? withBody}) requestFactory) {
  group(name, () {
    final requestUri = Uri.parse('/mock/request');

    setUp(() async {
      await MockTransports.reset();
      configureWTransportForTest();
    });

    tearDown(() {
      MockTransports.verifyNoOutstandingExceptions();
    });

    test('clone()', () {
      Future<Null> reqInt(transport.BaseRequest request) async {}
      Future<transport.BaseResponse?> respInt(
              FinalizedRequest request, transport.BaseResponse? response,
              [transport.RequestException? exception]) async =>
          response;

      final headers = <String, String>{'x-custom': 'header'};
      const tt = Duration(seconds: 10);
      final encoding = latin1;

      final orig = requestFactory()
        ..autoRetry!.enabled = true
        ..headers = headers
        ..requestInterceptor = reqInt
        ..responseInterceptor = respInt
        ..timeoutThreshold = tt
        ..uri = requestUri
        ..withCredentials = true;
      if (orig is! transport.MultipartRequest) {
        orig.encoding = encoding;
      }

      final clone = orig.clone()!;
      expect(identical(clone.autoRetry, orig.autoRetry), isTrue);
      expect(clone.headers, equals(headers));
      expect(clone.requestInterceptor, equals(reqInt));
      expect(clone.responseInterceptor, equals(respInt));
      expect(clone.timeoutThreshold, equals(tt));
      expect(clone.uri, equals(requestUri));
      if (orig is! transport.MultipartRequest) {
        expect(clone.encoding, equals(encoding));
      }
    });

    group('retry', () {
      test('disabled', () async {
        MockTransports.http.expect('GET', requestUri,
            respondWith: MockResponse.internalServerError());
        final request = requestFactory();
        expect(request.get(uri: requestUri),
            throwsA(isA<transport.RequestException>()));
        await request.done;
        expect(request.autoRetry!.numAttempts, equals(1));
        expect(request.autoRetry!.failures.length, equals(1));
      });

      test('no retries', () async {
        MockTransports.http.expect('GET', requestUri);

        final request = requestFactory();
        request.autoRetry!
          ..enabled = true
          ..maxRetries = 2;

        await request.get(uri: requestUri);
        expect(request.autoRetry!.numAttempts, equals(1));
        expect(request.autoRetry!.failures, isEmpty);
      });

      test('1 successful retry', () async {
        // 1st request = 500, 2nd request = 200
        MockTransports.http.expect('GET', requestUri,
            respondWith: MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri);

        final request = requestFactory();
        request.autoRetry!
          ..enabled = true
          ..maxRetries = 2;

        await request.get(uri: requestUri);
        expect(request.autoRetry!.numAttempts, equals(2));
        expect(request.autoRetry!.failures.length, equals(1));
      });

      test('1 failed retry, 1 successful retry', () async {
        // 1st two requests = 500, 3rd request = 200
        MockTransports.http.expect('GET', requestUri,
            respondWith: MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri,
            respondWith: MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri);

        final request = requestFactory();
        request.autoRetry!
          ..enabled = true
          ..maxRetries = 2;

        await request.get(uri: requestUri);
        expect(request.autoRetry!.numAttempts, equals(3));
        expect(request.autoRetry!.failures.length, equals(2));
      });

      test('maximum retries exceeded', () async {
        // All 3 requests 500
        MockTransports.http.expect('GET', requestUri,
            respondWith: MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri,
            respondWith: MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri,
            respondWith: MockResponse.internalServerError());

        final request = requestFactory();
        request.autoRetry!
          ..enabled = true
          ..maxRetries = 2;

        expect(request.get(uri: requestUri),
            throwsA(isA<transport.RequestException>()));
        await request.done;
        expect(request.autoRetry!.numAttempts, equals(3));
        expect(request.autoRetry!.failures.length, equals(3));
      });

      test('1 failed retry that is not eligible for retry', () async {
        // 1st request = 500, 2nd request = 404, no 3rd request because 404
        MockTransports.http.expect('GET', requestUri,
            respondWith: MockResponse.internalServerError());
        MockTransports.http
            .expect('GET', requestUri, respondWith: MockResponse.notFound());

        final request = requestFactory();
        request.autoRetry!
          ..enabled = true
          ..maxRetries = 2;

        expect(request.get(uri: requestUri),
            throwsA(isA<transport.RequestException>()));
        await request.done;
        expect(request.autoRetry!.numAttempts, equals(2));
        expect(request.autoRetry!.failures.length, equals(2));
      });

      test('request ineligible for retry due to HTTP method', () async {
        // 1st request = POST, so no retry
        MockTransports.http.expect('POST', requestUri,
            respondWith: MockResponse.internalServerError());

        final request = requestFactory();
        request.autoRetry!
          ..enabled = true
          ..maxRetries = 2;

        expect(request.post(uri: requestUri),
            throwsA(isA<transport.RequestException>()));
        await request.done;
        expect(request.autoRetry!.numAttempts, equals(1));
        expect(request.autoRetry!.failures.length, equals(1));
      });

      test('request ineligible for retry due to response status code',
          () async {
        // 1st request = 404, so no retry
        MockTransports.http
            .expect('GET', requestUri, respondWith: MockResponse.notFound());

        final request = requestFactory();
        request.autoRetry!
          ..enabled = true
          ..maxRetries = 2;

        expect(request.get(uri: requestUri),
            throwsA(isA<transport.RequestException>()));
        await request.done;
        expect(request.autoRetry!.numAttempts, equals(1));
        expect(request.autoRetry!.failures.length, equals(1));
      });

      test('request ineligible for retry due to custom test', () async {
        // 1st request has a header that tells our custom test to not retry
        MockTransports.http.expect('GET', requestUri,
            respondWith:
                MockResponse.internalServerError(headers: {'x-retry': 'no'}));

        final request = requestFactory();
        request.autoRetry!
          ..enabled = true
          ..maxRetries = 2
          ..test =
              (request, transport.BaseResponse? response, willRetry) async =>
                  response!.headers!['x-retry'] == 'yes';

        expect(request.get(uri: requestUri),
            throwsA(isA<transport.RequestException>()));
        await request.done;
        expect(request.autoRetry!.numAttempts, equals(1));
        expect(request.autoRetry!.failures.length, equals(1));
      });

      test('retries only 500, 502, 503, 504 by default', () async {
        Future<Null> expectNumRetries(int num,
            {bool shouldSucceed = true}) async {
          final request = requestFactory();
          request.autoRetry!
            ..enabled = true
            ..maxRetries = num;

          if (shouldSucceed) {
            await request.get(uri: requestUri);
          } else {
            expect(request.get(uri: requestUri),
                throwsA(isA<transport.RequestException>()));
          }
          await request.done;
          expect(request.autoRetry!.numAttempts, equals(num + 1));
        }

        MockTransports.http
            .expect('GET', requestUri, respondWith: MockResponse(500));
        MockTransports.http.expect('GET', requestUri);
        await expectNumRetries(1);

        MockTransports.http
            .expect('GET', requestUri, respondWith: MockResponse(502));
        MockTransports.http.expect('GET', requestUri);
        await expectNumRetries(1);

        MockTransports.http
            .expect('GET', requestUri, respondWith: MockResponse(503));
        MockTransports.http.expect('GET', requestUri);
        await expectNumRetries(1);

        MockTransports.http
            .expect('GET', requestUri, respondWith: MockResponse(504));
        MockTransports.http.expect('GET', requestUri);
        await expectNumRetries(1);

        MockTransports.http
            .expect('GET', requestUri, respondWith: MockResponse(404));
        await expectNumRetries(0, shouldSucceed: false);
      });

      test('retries only GET, HEAD, OPTIONS by default', () async {
        Future<Null> expectNumRetries(String method, int num,
            {bool shouldSucceed = true}) async {
          final request = requestFactory();
          request.autoRetry!
            ..enabled = true
            ..maxRetries = num;

          if (shouldSucceed) {
            await request.send(method, uri: requestUri);
          } else {
            expect(request.send(method, uri: requestUri),
                throwsA(isA<transport.RequestException>()));
          }

          await request.done;
          expect(request.autoRetry!.numAttempts, equals(num + 1));
        }

        MockTransports.http.expect('GET', requestUri,
            respondWith: MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri);
        await expectNumRetries('GET', 1);

        MockTransports.http.expect('HEAD', requestUri,
            respondWith: MockResponse.internalServerError());
        MockTransports.http.expect('HEAD', requestUri);
        await expectNumRetries('HEAD', 1);

        MockTransports.http.expect('OPTIONS', requestUri,
            respondWith: MockResponse.internalServerError());
        MockTransports.http.expect('OPTIONS', requestUri);
        await expectNumRetries('OPTIONS', 1);

        MockTransports.http.expect('DELETE', requestUri,
            respondWith: MockResponse.internalServerError());
        await expectNumRetries('DELETE', 0, shouldSucceed: false);

        MockTransports.http.expect('PATCH', requestUri,
            respondWith: MockResponse.internalServerError());
        await expectNumRetries('PATCH', 0, shouldSucceed: false);

        MockTransports.http.expect('POST', requestUri,
            respondWith: MockResponse.internalServerError());
        await expectNumRetries('POST', 0, shouldSucceed: false);

        MockTransports.http.expect('PUT', requestUri,
            respondWith: MockResponse.internalServerError());
        await expectNumRetries('PUT', 0, shouldSucceed: false);
      });

      test('custom status code', () async {
        // 1st request = 408 (request timeout), 2nd request = 200
        MockTransports.http
            .expect('GET', requestUri, respondWith: MockResponse(408));
        MockTransports.http.expect('GET', requestUri);

        final request = requestFactory();
        request.autoRetry!
          ..enabled = true
          ..maxRetries = 2
          ..forStatusCodes = [408];

        await request.get(uri: requestUri);
        expect(request.autoRetry!.numAttempts, equals(2));
        expect(request.autoRetry!.failures.length, equals(1));
      });

      test('custom HTTP method', () async {
        // 1st request = DELETE 500, 2nd request = 200
        MockTransports.http.expect('DELETE', requestUri,
            respondWith: MockResponse.internalServerError());
        MockTransports.http.expect('DELETE', requestUri);

        final request = requestFactory();
        request.autoRetry!
          ..enabled = true
          ..maxRetries = 2
          ..forHttpMethods = ['DELETE'];

        await request.delete(uri: requestUri);
        expect(request.autoRetry!.numAttempts, equals(2));
        expect(request.autoRetry!.failures.length, equals(1));
      });

      test('custom retry eligibility test', () async {
        // 1st request = 500, 2nd request = 200
        MockTransports.http.expect('GET', requestUri,
            respondWith: MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri);

        final request = requestFactory();
        request.autoRetry!
          ..enabled = true
          ..maxRetries = 2
          ..test = (request, response, willRetry) async => willRetry;

        await request.get(uri: requestUri);
        expect(request.autoRetry!.numAttempts, equals(2));
        expect(request.autoRetry!.failures.length, equals(1));
      });

      test('custom retry eligibility test defers to rest of configuration',
          () async {
        // 1st request = 404
        MockTransports.http
            .expect('GET', requestUri, respondWith: MockResponse.notFound());

        final request = requestFactory();
        request.autoRetry!
          ..enabled = true
          ..maxRetries = 2
          ..test = (request, response, willRetry) async => willRetry;

        expect(request.get(uri: requestUri),
            throwsA(isA<transport.RequestException>()));
        await request.done;
        expect(request.autoRetry!.numAttempts, equals(1));
        expect(request.autoRetry!.failures.length, equals(1));
      });

      test(
          'request cancellation during a retry attempt should cancel the retry',
          () async {
        // 1st request = 500, 2nd request hangs indefinitely
        int c = 0;
        MockTransports.http.when(requestUri, (request) async {
          if (++c == 1) {
            return MockResponse.internalServerError();
          } else {
            await Future.delayed(Duration(seconds: 10));
            return MockResponse.ok();
          }
        }, method: 'GET');

        final request = requestFactory();
        request.autoRetry!
          ..enabled = true
          ..maxRetries = 2;

        final future = request.get(uri: requestUri);
        await Future.delayed(Duration(milliseconds: 500));
        request.abort();
        expect(future, throwsA(predicate((dynamic exception) {
          return exception is transport.RequestException &&
              exception.toString().contains('Request canceled');
        })));
      });

      test('request timeout should be retried by default', () async {
        // 1st request = hangs until timeout, 2nd request succeeds
        int c = 0;
        MockTransports.http.when(requestUri, (request) async {
          if (++c == 1) {
            await Future.delayed(Duration(seconds: 1));
          }
          return MockResponse.ok();
        }, method: 'GET');

        final request = requestFactory();
        request.timeoutThreshold = Duration(milliseconds: 250);
        request.autoRetry!
          ..enabled = true
          ..maxRetries = 2;

        await request.get(uri: requestUri);
        expect(request.autoRetry!.numAttempts, equals(2));
      });

      test(
          'request timeout should be retried by default increaseTimeoutOnRetry',
          () async {
        // 1st and 2nd request = hangs until timeout, 3nd request succeeds
        int c = 0;
        MockTransports.http.when(requestUri, (request) async {
          if (++c <= 2) {
            await Future.delayed(Duration(seconds: 1));
          }
          // The timeout should be 75ms by now, so even with this delay, should succeed.
          await Future.delayed(Duration(milliseconds: 60));
          return MockResponse.ok();
        }, method: 'GET');

        final request = requestFactory();
        request.timeoutThreshold = Duration(milliseconds: 25);
        request.autoRetry!
          ..enabled = true
          ..maxRetries = 2
          ..increaseTimeoutOnRetry = true;

        await request.get(uri: requestUri);
        expect(request.autoRetry!.numAttempts, equals(3));
      });

      test('request timeout should not be retried if disabled', () async {
        // 1st request = hangs until timeout
        MockTransports.http.when(requestUri, (request) async {
          await Future.delayed(Duration(seconds: 1));
          return MockResponse.ok();
        }, method: 'GET');

        final request = requestFactory();
        request.timeoutThreshold = Duration(milliseconds: 250);
        request.autoRetry!
          ..enabled = true
          ..forTimeouts = false
          ..maxRetries = 2;

        final future = request.get(uri: requestUri);
        expect(future, throwsA(isA<transport.RequestException>()));
        try {
          await future;
          fail('Expected RequestException, but future completed successfully.');
        } catch (error) {
          expect(error, isA<transport.RequestException>());
        }
        expect(request.autoRetry!.numAttempts, equals(1));
      });

      test('no retry back-off by default', () async {
        MockTransports.http.expect('GET', requestUri,
            respondWith: MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri,
            respondWith: MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri,
            respondWith: MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri);

        final request = requestFactory();
        request.autoRetry!
          ..enabled = true
          ..maxRetries = 3;

        // ignore: unawaited_futures
        request.get(uri: requestUri);

        // Wait an arbitrarily short amount of time to allow all retries to
        // complete with confidence that no back-off occurred.
        await Future.delayed(Duration(milliseconds: 20));
        expect(request.autoRetry!.numAttempts, equals(4));
      });

      test('fixed retry back-off', () async {
        MockTransports.http.expect('GET', requestUri,
            respondWith: MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri,
            respondWith: MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri,
            respondWith: MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri);

        final request = requestFactory();
        request.autoRetry!
          ..enabled = true
          ..maxRetries = 3
          ..backOff = transport.RetryBackOff.fixed(Duration(milliseconds: 50),
              withJitter: false);

        // ignore: unawaited_futures
        request.get(uri: requestUri);

        // < 50ms = 1 attempt
        // < 100ms = 2 attempts
        // < 150ms = 3 attempts
        // >= 150ms = 4 attempts
        await Future.delayed(Duration(milliseconds: 25));
        expect(request.autoRetry!.numAttempts, equals(1));
        await Future.delayed(Duration(milliseconds: 50));
        expect(request.autoRetry!.numAttempts, equals(2));
        await Future.delayed(Duration(milliseconds: 50));
        expect(request.autoRetry!.numAttempts, equals(3));
        await Future.delayed(Duration(milliseconds: 50));
        expect(request.autoRetry!.numAttempts, equals(4));
      });

      test('fixed retry back-off with jitter', () async {
        MockTransports.http.expect('GET', requestUri,
            respondWith: MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri,
            respondWith: MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri,
            respondWith: MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri);

        final request = requestFactory();
        request.autoRetry!
          ..enabled = true
          ..maxRetries = 3
          ..backOff = transport.RetryBackOff.fixed(Duration(milliseconds: 15),
              withJitter: true);
        // ignore: unawaited_futures
        request.get(uri: requestUri);

        // 1st attempt = immediate
        // 2nd attempt = +0 to 15s
        // 3rd attempt = +0 to 15s
        // 4th attempt = +0 to 15s
        await Future.delayed(Duration(milliseconds: 200));
        expect(request.autoRetry!.numAttempts, equals(4));
      });

      test('exponential retry back-off', () async {
        MockTransports.http.expect('GET', requestUri,
            respondWith: MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri,
            respondWith: MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri,
            respondWith: MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri);

        final request = requestFactory();
        request.autoRetry!
          ..enabled = true
          ..maxRetries = 3
          ..backOff = transport.RetryBackOff.exponential(
              Duration(milliseconds: 25),
              withJitter: false);

        // ignore: unawaited_futures
        request.get(uri: requestUri);

        // 1st attempt = immediate
        // 2nd attempt = +50s (25*2^1)
        // 3rd attempt = +100s (25*2^2)
        // 4th attempt = +200s (25*2^3)
        await Future.delayed(Duration(milliseconds: 1));
        expect(request.autoRetry!.numAttempts, equals(1));
        await Future.delayed(Duration(milliseconds: 60));
        expect(request.autoRetry!.numAttempts, equals(2));
        await Future.delayed(Duration(milliseconds: 120));
        expect(request.autoRetry!.numAttempts, equals(3));
        await Future.delayed(Duration(milliseconds: 240));
        expect(request.autoRetry!.numAttempts, equals(4));
      });

      test('exponential retry back-off with jitter', () async {
        MockTransports.http.expect('GET', requestUri,
            respondWith: MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri,
            respondWith: MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri,
            respondWith: MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri);

        final request = requestFactory();
        request.autoRetry!
          ..enabled = true
          ..maxRetries = 3
          ..backOff = transport.RetryBackOff.exponential(
              Duration(milliseconds: 25),
              withJitter: true);

        // ignore: unawaited_futures
        request.get(uri: requestUri);

        // 1st attempt = immediate
        // 2nd attempt = +0 to 50s (25*2^1)
        // 3rd attempt = +0 to 100s (25*2^2) + 2nd attempt
        // 4th attempt = +0 to 200s (25*2^3) + 3rd attempt
        await Future.delayed(Duration(milliseconds: 500));
        expect(request.autoRetry!.numAttempts, equals(4));
      });

      test('RequestException should detail all attempts', () async {
        // 1st = 400, 2nd = 403, 3rd = 500, 4th = error, 5th = timeout
        int c = 0;
        MockTransports.http.when(requestUri, (request) async {
          switch (++c) {
            case 1:
              return MockResponse.badRequest();
            case 2:
              return MockResponse.forbidden();
            case 3:
              return MockResponse.internalServerError();
            case 4:
              await Future.delayed(Duration(seconds: 1));
              return MockResponse.notImplemented();
            case 5:
              throw Exception('Unexpected failure.');
          }
          return MockResponse.ok();
        });

        final request = requestFactory()
          ..timeoutThreshold = Duration(milliseconds: 100);
        request.autoRetry!
          ..enabled = true
          ..maxRetries = 4
          ..test = (request, response, willRetry) async => true;

        expect(request.get(uri: requestUri),
            throwsA(predicate((transport.RequestException reqEx) {
          expect(reqEx.toString(), contains('Attempt #1: 400 BAD REQUEST'));
          expect(reqEx.toString(), contains('Attempt #2: 403 FORBIDDEN'));
          expect(reqEx.toString(),
              contains('Attempt #3: 500 INTERNAL SERVER ERROR'));
          expect(
              reqEx.toString(),
              contains(
                  'Attempt #4: (TimeoutException after 0:00:00.100000: Request took too long to complete.)'));
          expect(reqEx.toString(),
              contains('Attempt #5: (Exception: Unexpected failure.)'));
          return true;
        })));
      });

      test('manual retry()', () async {
        MockTransports.http
            .expect('GET', requestUri, respondWith: MockResponse.badRequest());
        MockTransports.http.expect('GET', requestUri);
        final request = requestFactory();
        // await request.get(uri: requestUri);
        try {
          await request.get(uri: requestUri);
        } catch (error) {
          expect(error, isA<transport.RequestException>());
        }
        await request.retry();
      });

      test('manual retry() throws if not yet sent', () async {
        final request = requestFactory();
        expect(request.retry, throwsStateError);
      });

      test('manual retry() throws if not yet complete', () async {
        MockTransports.http.when(requestUri,
            (request) => Completer<transport.BaseResponse>().future);
        final request = requestFactory();
        // ignore: unawaited_futures
        request.get(uri: requestUri);
        await Future.delayed(Duration(milliseconds: 10));
        expect(request.retry, throwsStateError);
      });

      test('manual retry() throws if did not fail', () async {
        MockTransports.http.expect('GET', requestUri);
        final request = requestFactory();
        await request.get(uri: requestUri);
        expect(request.retry, throwsStateError);
      });

      test('manual streamRetry()', () async {
        MockTransports.http
            .expect('GET', requestUri, respondWith: MockResponse.badRequest());
        MockTransports.http.expect('GET', requestUri);
        final request = requestFactory();
        try {
          await request.get(uri: requestUri);
        } catch (error) {
          expect(error, isA<transport.RequestException>());
        }
        await request.streamRetry();
      });

      test('manual streamRetry() throws if not yet sent', () async {
        final request = requestFactory();
        expect(request.streamRetry, throwsStateError);
      });

      test('manual streamRetry() throws if not yet complete', () async {
        MockTransports.http.when(requestUri,
            (request) => Completer<transport.BaseResponse>().future);
        final request = requestFactory();
        // ignore: unawaited_futures
        request.get(uri: requestUri);
        await Future.delayed(Duration(milliseconds: 10));
        expect(request.streamRetry, throwsStateError);
      });

      test('manual streamRetry() throws if did not fail', () async {
        MockTransports.http.expect('GET', requestUri);
        final request = requestFactory();
        await request.get(uri: requestUri);
        expect(request.streamRetry, throwsStateError);
      });
    });
  });
}
