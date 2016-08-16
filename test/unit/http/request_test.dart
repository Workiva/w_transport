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
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/mock.dart';

import '../../naming.dart';

void main() {
  Naming naming = new Naming()
    ..testType = testTypeUnit
    ..topic = topicHttp;

  group(naming.toString(), () {
    formReqFactory({bool withBody: false}) {
      if (!withBody) return new FormRequest();
      return new FormRequest()..fields['field'] = 'value';
    }

    jsonReqFactory({bool withBody: false}) {
      if (!withBody) return new JsonRequest();
      return new JsonRequest()
        ..body = [
          {'field': 'value'}
        ];
    }

    multipartReqFactory({bool withBody}) {
      // Multipart requests can't be empty.
      return new MultipartRequest()..fields['field'] = 'value';
    }

    reqFactory({bool withBody: false}) {
      if (!withBody) return new Request();
      return new Request()..body = 'body';
    }

    streamedReqFactory({bool withBody: false}) {
      if (!withBody) return new StreamedRequest();
      return new StreamedRequest()
        ..body = new Stream.fromIterable([UTF8.encode('bytes')])
        ..contentLength = UTF8.encode('bytes').length;
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
      Uri requestUri = Uri.parse('/mock/request');

      // Hold the requests long enough to let the client cancel them on close
      MockTransports.http.when(requestUri, (request) async {
        await new Future.delayed(new Duration(seconds: 10));
      }, method: 'GET');

      var client = new HttpClient();
      var clientReqs = [
        client.newFormRequest(),
        client.newJsonRequest(),
        client.newMultipartRequest()..fields['f1'] = 'v1',
        client.newRequest()
      ];
      for (BaseRequest orig in clientReqs) {
        BaseRequest clone = orig.clone()..uri = requestUri;
        expect(clone.get(), throwsA(predicate((exception) {
          return exception is RequestException &&
              exception.toString().contains('client was closed');
        })));
      }
      client.close();
    });
  });
}

void _runCommonRequestSuiteFor(
    String name, BaseRequest requestFactory({bool withBody})) {
  group(name, () {
    Uri requestUri = Uri.parse('/mock/request');
    Map requestHeaders = {'x-custom': 'header'};

    setUp(() {
      MockTransports.reset();
      configureWTransportForTest();
    });

    tearDown(() {
      MockTransports.verifyNoOutstandingExceptions();
    });

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

    test('DELETE (streamed)', () async {
      MockTransports.http.expect('DELETE', requestUri);
      await requestFactory().streamDelete(uri: requestUri);
    });

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
      Completer dataCompleter = new Completer();
      MockTransports.http.when(requestUri, (FinalizedRequest request) async {
        if (request.body is HttpBody) {
          dataCompleter.complete((request.body as HttpBody).asString());
        } else {
          dataCompleter.complete(
              UTF8.decode(await (request.body as StreamedHttpBody).toBytes()));
        }

        return new MockResponse.ok();
      });
      await requestFactory(withBody: true).post(uri: requestUri);
      expect(await dataCompleter.future, isNotEmpty);
    });

    test('headers given to dispatch method should be merged with existing ones',
        () async {
      MockTransports.http.expect('GET', requestUri,
          headers: {'x-one': '1', 'x-two': '2', 'x-three': '3'});
      BaseRequest request = requestFactory()
        ..headers = {'x-one': '1', 'x-two': '0'}
        ..uri = requestUri;
      await request.get(headers: {'x-two': '2', 'x-three': '3'});
    });

    test('request cancellation prior to dispatch should cancel request',
        () async {
      BaseRequest request = requestFactory();
      request.abort();
      expect(request.get(uri: requestUri),
          throwsA(new isInstanceOf<RequestException>()));
    });

    test(
        'request cancellation after dispatch but prior to resolution should cancel request',
        () async {
      BaseRequest request = requestFactory();
      Future future = request.get(uri: requestUri);
      await new Future.delayed(new Duration(milliseconds: 500));
      request.abort();
      expect(future, throwsA(new isInstanceOf<RequestException>()));
    });

    test('request cancellation after request has succeeded should do nothing',
        () async {
      MockTransports.http.expect('GET', requestUri);
      BaseRequest request = requestFactory();
      await request.get(uri: requestUri);
      request.abort();
    });

    test('request cancellation after request has failed should do nothing',
        () async {
      MockTransports.http.expect('GET', requestUri, failWith: new Exception());
      BaseRequest request = requestFactory();
      Future future = request.get(uri: requestUri);
      expect(future, throwsA(new isInstanceOf<RequestException>()));
      try {
        await future;
      } catch (e) {}
      request.abort();
    });

    test('request cancellation should accept a custom error', () async {
      BaseRequest request = requestFactory();
      request.abort(new Exception('custom error'));
      expect(request.get(uri: requestUri), throwsA(predicate((error) {
        return error is RequestException &&
            error.toString().contains('custom error');
      })));
    });

    test('request cancellation should do nothing if already called', () async {
      var request = requestFactory();
      request.abort();
      expect(() {
        request.abort();
      }, returnsNormally);
      expect(request.get(uri: requestUri),
          throwsA(new isInstanceOf<RequestException>()));
    });

    test('should wrap an unexpected exception in RequestException', () async {
      BaseRequest request = requestFactory();
      MockTransports.http.causeFailureOnOpen(request);
      expect(request.get(uri: requestUri),
          throwsA(new isInstanceOf<RequestException>()));
    });

    test('should throw if status code is non-200', () async {
      MockTransports.http.expect('GET', requestUri,
          respondWith: new MockResponse.internalServerError());
      BaseRequest request = requestFactory();
      expect(request.get(uri: requestUri),
          throwsA(new isInstanceOf<RequestException>()));
    });

    test('headers should be unmodifiable once sent', () async {
      MockTransports.http.expect('GET', requestUri);
      BaseRequest request = requestFactory()
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
      BaseRequest request = requestFactory();
      await request.get(uri: requestUri);
      expect(() {
        request.withCredentials = true;
      }, throwsStateError);
    });

    test('request can only be sent once', () async {
      MockTransports.http.expect('GET', requestUri);
      BaseRequest request = requestFactory();
      Future first = request.get(uri: requestUri);
      expect(request.get(uri: requestUri), throwsStateError);
      await first;
    });

    test('isDone should be false prior to request completion', () async {
      MockTransports.http.expect('GET', requestUri);
      var request = requestFactory();
      var future = request.get(uri: requestUri);
      expect(request.isDone, isFalse);
      await future;
    });

    test('isDone should be true after completion', () async {
      MockTransports.http.expect('GET', requestUri);
      var request = requestFactory();
      await request.get(uri: requestUri);
      expect(request.isDone, isTrue);
    });

    test('isDone should be true after failure', () async {
      MockTransports.http
          .expect('GET', requestUri, respondWith: new MockResponse.notFound());
      var request = requestFactory();
      var future = request.get(uri: requestUri);
      expect(future, throws);
      await future.catchError((_) {});
      expect(request.isDone, isTrue);
    });

    test('isDone should be true after cancellation', () async {
      var request = requestFactory();
      var future = request.get(uri: requestUri);
      request.abort();
      await future.catchError((_) {});
      expect(request.isDone, isTrue);
    });

    test('requestInterceptor allows async modification of request', () async {
      MockTransports.http
          .expect('GET', requestUri, headers: {'x-intercepted': 'true'});
      BaseRequest request = requestFactory();
      request.requestInterceptor = (BaseRequest request) async {
        request.headers['x-intercepted'] = 'true';
      };
      await request.get(uri: requestUri);
    });

    test(
        'if requestInterceptor throws, the request should fail with that exception',
        () async {
      BaseRequest request = requestFactory();
      var exception = new Exception('interceptor failure');

      request.requestInterceptor = (BaseRequest request) async {
        throw exception;
      };
      expect(request.get(uri: Uri.parse('/test')), throwsA(equals(exception)));
    });

    test('setting requestInterceptor throws if request has been sent',
        () async {
      MockTransports.http.expect('GET', requestUri);
      BaseRequest request = requestFactory();
      await request.get(uri: requestUri);
      expect(() {
        request.requestInterceptor = (request) async {};
      }, throwsStateError);
    });

    test('responseInterceptor gets FinalizedRequest', () async {
      MockTransports.http.expect('GET', requestUri);
      BaseRequest request = requestFactory();
      request.responseInterceptor =
          (FinalizedRequest request, response, [exception]) async {
        expect(request.method, equals('GET'));
        expect(request.uri, equals(requestUri));
      };
      await request.get(uri: requestUri);
    });

    test('responseInterceptor gets BaseResponse', () async {
      MockResponse mockResponse = new MockResponse.ok(body: 'original');
      MockTransports.http.expect('GET', requestUri, respondWith: mockResponse);
      BaseRequest request = requestFactory();
      request.responseInterceptor =
          (request, BaseResponse response, [exception]) async {
        expect(response, new isInstanceOf<Response>());
        expect((response as Response).body.asString(), equals('original'));
      };
      await request.get(uri: requestUri);
    });

    test('responseInterceptor gets no RequestException on successful request',
        () async {
      MockTransports.http.expect('GET', requestUri);
      BaseRequest request = requestFactory();
      request.responseInterceptor = (request, response, [exception]) async {
        expect(exception, isNull);
      };
      await request.get(uri: requestUri);
    });

    test('responseInterceptor gets RequestException on failed request',
        () async {
      MockTransports.http
          .expect('GET', requestUri, failWith: new Exception('mock failure'));
      BaseRequest request = requestFactory();
      request.responseInterceptor =
          (request, response, [RequestException exception]) async {
        expect(exception, isNotNull);
        expect(exception.toString(), contains('mock failure'));
      };
      expect(request.get(uri: requestUri), throws);
    });

    test('responseInterceptor allows replacement of BaseResponse', () async {
      MockResponse mockResponse = new MockResponse.ok(body: 'original');
      MockTransports.http.expect('GET', requestUri, respondWith: mockResponse);
      BaseRequest request = requestFactory();
      request.responseInterceptor =
          (request, BaseResponse response, [exception]) async {
        return new Response.fromString(
            response.status, response.statusText, response.headers, 'modified');
      };
      Response response = await request.get(uri: requestUri);
      expect(response.body.asString(), equals('modified'));
    });

    test(
        'if responseInterceptor throws, the error should be wrapped in a RequestException',
        () async {
      MockTransports.http.expect('GET', requestUri);
      BaseRequest request = requestFactory();
      request.responseInterceptor = (request, response, [exception]) async {
        throw new Exception('interceptor failure');
      };
      expect(request.get(uri: requestUri), throwsA(predicate((error) {
        return error is RequestException &&
            error.toString().contains('interceptor failure');
      })));
    });

    test('setting responseInterceptor throws if request has been sent',
        () async {
      MockTransports.http.expect('GET', requestUri);
      BaseRequest request = requestFactory();
      await request.get(uri: requestUri);
      expect(() {
        request.responseInterceptor = (request, response, [exception]) async {};
      }, throwsStateError);
    });

    test(
        'should not double-wrap exception when applying responseInterceptor after failure',
        () async {
      var error = new Error();
      MockTransports.http.expect('GET', requestUri, failWith: error);
      BaseRequest request = requestFactory();
      request.responseInterceptor =
          (request, response, [exception]) async => response;
      expect(request.get(uri: requestUri), throwsA(predicate((exception) {
        return exception is RequestException &&
            identical(exception.error, error);
      })));
    });

    test('timeoutThreshold is not enforced if not set', () async {
      BaseRequest request = requestFactory();
      Future future = request.get(uri: requestUri);
      await new Future.delayed(new Duration(milliseconds: 250));
      MockTransports.http.completeRequest(request);
      await future;
    });

    test('timeoutThreshold does nothing if request completes in time',
        () async {
      BaseRequest request = requestFactory()
        ..timeoutThreshold = new Duration(milliseconds: 500);
      Future future = request.get(uri: requestUri);
      await new Future.delayed(new Duration(milliseconds: 250));
      MockTransports.http.completeRequest(request);
      await future;
    });

    test('timeoutThreshold cancels the request if exceeded', () async {
      BaseRequest request = requestFactory()
        ..timeoutThreshold = new Duration(milliseconds: 500);
      expect(request.get(uri: requestUri), throwsA(predicate((error) {
        return error is RequestException && error.error is TimeoutException;
      })));
    });

    test(
        'timeoutThreshold cancels the request if exceeded but not if it has already been canceled',
        () async {
      BaseRequest request = requestFactory()
        ..timeoutThreshold = new Duration(milliseconds: 500);
      var future = request.get(uri: requestUri);
      await new Future.delayed(new Duration(milliseconds: 250));
      request.abort();
      expect(future, throwsA(predicate((error) {
        return error is RequestException && error.error is! TimeoutException;
      })));
    });

    test('configure() should throw if called after request has been sent',
        () async {
      MockTransports.http.expect('GET', requestUri);
      BaseRequest request = requestFactory();
      await request.get(uri: requestUri);
      expect(() {
        request.configure((_) {});
      }, throwsStateError);
    });

    test('toString()', () async {
      MockTransports.http.expect('GET', requestUri);
      BaseRequest request = requestFactory();
      await request.get(uri: requestUri);
      expect(request.toString(), contains('GET'));
      expect(request.toString(), contains(requestUri.toString()));
      expect(request.toString(), contains(request.contentType.toString()));
    });
  });
}

_runAutoRetryTestSuiteFor(
    String name, BaseRequest requestFactory({bool withBody})) {
  group(name, () {
    Uri requestUri = Uri.parse('/mock/request');

    setUp(() {
      MockTransports.reset();
      configureWTransportForTest();
    });

    tearDown(() {
      MockTransports.verifyNoOutstandingExceptions();
    });

    test('clone()', () {
      var headers = {'x-custom': 'header'};
      var reqInt = (request) async {};
      var respInt = (request, response, [exception]) async {};
      var tt = new Duration(seconds: 10);
      var encoding = LATIN1;

      BaseRequest orig = requestFactory()
        ..autoRetry.enabled = true
        ..headers = headers
        ..requestInterceptor = reqInt
        ..responseInterceptor = respInt
        ..timeoutThreshold = tt
        ..uri = requestUri
        ..withCredentials = true;
      if (orig is! MultipartRequest) {
        orig.encoding = encoding;
      }

      BaseRequest clone = orig.clone();
      expect(identical(clone.autoRetry, orig.autoRetry), isTrue);
      expect(clone.headers, equals(headers));
      expect(clone.requestInterceptor, equals(reqInt));
      expect(clone.responseInterceptor, equals(respInt));
      expect(clone.timeoutThreshold, equals(tt));
      expect(clone.uri, equals(requestUri));
      if (orig is! MultipartRequest) {
        expect(clone.encoding, equals(encoding));
      }
    });

    group('retry', () {
      test('disabled', () async {
        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.internalServerError());
        BaseRequest request = requestFactory();
        expect(request.get(uri: requestUri),
            throwsA(new isInstanceOf<RequestException>()));
        await request.done;
        expect(request.autoRetry.numAttempts, equals(1));
        expect(request.autoRetry.failures.length, equals(1));
      });

      test('no retries', () async {
        MockTransports.http.expect('GET', requestUri);

        BaseRequest request = requestFactory();
        request.autoRetry
          ..enabled = true
          ..maxRetries = 2;

        await request.get(uri: requestUri);
        expect(request.autoRetry.numAttempts, equals(1));
        expect(request.autoRetry.failures, isEmpty);
      });

      test('1 successful retry', () async {
        // 1st request = 500, 2nd request = 200
        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri);

        BaseRequest request = requestFactory();
        request.autoRetry
          ..enabled = true
          ..maxRetries = 2;

        await request.get(uri: requestUri);
        expect(request.autoRetry.numAttempts, equals(2));
        expect(request.autoRetry.failures.length, equals(1));
      });

      test('1 failed retry, 1 successful retry', () async {
        // 1st two requests = 500, 3rd request = 200
        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri);

        BaseRequest request = requestFactory();
        request.autoRetry
          ..enabled = true
          ..maxRetries = 2;

        await request.get(uri: requestUri);
        expect(request.autoRetry.numAttempts, equals(3));
        expect(request.autoRetry.failures.length, equals(2));
      });

      test('maximum retries exceeded', () async {
        // All 3 requests 500
        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.internalServerError());

        BaseRequest request = requestFactory();
        request.autoRetry
          ..enabled = true
          ..maxRetries = 2;

        expect(request.get(uri: requestUri),
            throwsA(new isInstanceOf<RequestException>()));
        await request.done;
        expect(request.autoRetry.numAttempts, equals(3));
        expect(request.autoRetry.failures.length, equals(3));
      });

      test('1 failed retry that is not eligible for retry', () async {
        // 1st request = 500, 2nd request = 404, no 3rd request because 404
        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.notFound());

        BaseRequest request = requestFactory();
        request.autoRetry
          ..enabled = true
          ..maxRetries = 2;

        expect(request.get(uri: requestUri), throws);
        await request.done;
        expect(request.autoRetry.numAttempts, equals(2));
        expect(request.autoRetry.failures.length, equals(2));
      });

      test('request ineligible for retry due to HTTP method', () async {
        // 1st request = POST, so no retry
        MockTransports.http.expect('POST', requestUri,
            respondWith: new MockResponse.internalServerError());

        BaseRequest request = requestFactory();
        request.autoRetry
          ..enabled = true
          ..maxRetries = 2;

        expect(request.post(uri: requestUri), throws);
        await request.done;
        expect(request.autoRetry.numAttempts, equals(1));
        expect(request.autoRetry.failures.length, equals(1));
      });

      test('request ineligible for retry due to response status code',
          () async {
        // 1st request = 404, so no retry
        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.notFound());

        BaseRequest request = requestFactory();
        request.autoRetry
          ..enabled = true
          ..maxRetries = 2;

        expect(request.get(uri: requestUri), throws);
        await request.done;
        expect(request.autoRetry.numAttempts, equals(1));
        expect(request.autoRetry.failures.length, equals(1));
      });

      test('request ineligible for retry due to custom test', () async {
        // 1st request has a header that tells our custom test to not retry
        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.internalServerError(
                headers: {'x-retry': 'no'}));

        BaseRequest request = requestFactory();
        request.autoRetry
          ..enabled = true
          ..maxRetries = 2
          ..test = (request, BaseResponse response, willRetry) async =>
              response.headers['x-retry'] == 'yes';

        expect(request.get(uri: requestUri), throws);
        await request.done;
        expect(request.autoRetry.numAttempts, equals(1));
        expect(request.autoRetry.failures.length, equals(1));
      });

      test('retries only 500, 502, 503, 504 by default', () async {
        Future expectNumRetries(int num, {shouldSucceed: true}) async {
          BaseRequest request = requestFactory();
          request.autoRetry
            ..enabled = true
            ..maxRetries = num;

          if (shouldSucceed) {
            await request.get(uri: requestUri);
          } else {
            expect(request.get(uri: requestUri), throws);
          }
          await request.done;
          expect(request.autoRetry.numAttempts, equals(num + 1));
        }

        MockTransports.http
            .expect('GET', requestUri, respondWith: new MockResponse(500));
        MockTransports.http.expect('GET', requestUri);
        await expectNumRetries(1);

        MockTransports.http
            .expect('GET', requestUri, respondWith: new MockResponse(502));
        MockTransports.http.expect('GET', requestUri);
        await expectNumRetries(1);

        MockTransports.http
            .expect('GET', requestUri, respondWith: new MockResponse(503));
        MockTransports.http.expect('GET', requestUri);
        await expectNumRetries(1);

        MockTransports.http
            .expect('GET', requestUri, respondWith: new MockResponse(504));
        MockTransports.http.expect('GET', requestUri);
        await expectNumRetries(1);

        MockTransports.http
            .expect('GET', requestUri, respondWith: new MockResponse(404));
        await expectNumRetries(0, shouldSucceed: false);
      });

      test('retries only GET, HEAD, OPTIONS by default', () async {
        Future expectNumRetries(String method, int num,
            {shouldSucceed: true}) async {
          BaseRequest request = requestFactory();
          request.autoRetry
            ..enabled = true
            ..maxRetries = num;

          if (shouldSucceed) {
            await request.send(method, uri: requestUri);
          } else {
            expect(request.send(method, uri: requestUri), throws);
          }

          await request.done;
          expect(request.autoRetry.numAttempts, equals(num + 1));
        }

        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri);
        await expectNumRetries('GET', 1);

        MockTransports.http.expect('HEAD', requestUri,
            respondWith: new MockResponse.internalServerError());
        MockTransports.http.expect('HEAD', requestUri);
        await expectNumRetries('HEAD', 1);

        MockTransports.http.expect('OPTIONS', requestUri,
            respondWith: new MockResponse.internalServerError());
        MockTransports.http.expect('OPTIONS', requestUri);
        await expectNumRetries('OPTIONS', 1);

        MockTransports.http.expect('DELETE', requestUri,
            respondWith: new MockResponse.internalServerError());
        await expectNumRetries('DELETE', 0, shouldSucceed: false);

        MockTransports.http.expect('PATCH', requestUri,
            respondWith: new MockResponse.internalServerError());
        await expectNumRetries('PATCH', 0, shouldSucceed: false);

        MockTransports.http.expect('POST', requestUri,
            respondWith: new MockResponse.internalServerError());
        await expectNumRetries('POST', 0, shouldSucceed: false);

        MockTransports.http.expect('PUT', requestUri,
            respondWith: new MockResponse.internalServerError());
        await expectNumRetries('PUT', 0, shouldSucceed: false);
      });

      test('custom status code', () async {
        // 1st request = 408 (request timeout), 2nd request = 200
        MockTransports.http
            .expect('GET', requestUri, respondWith: new MockResponse(408));
        MockTransports.http.expect('GET', requestUri);

        BaseRequest request = requestFactory();
        request.autoRetry
          ..enabled = true
          ..maxRetries = 2
          ..forStatusCodes = [408];

        await request.get(uri: requestUri);
        expect(request.autoRetry.numAttempts, equals(2));
        expect(request.autoRetry.failures.length, equals(1));
      });

      test('custom HTTP method', () async {
        // 1st request = DELETE 500, 2nd request = 200
        MockTransports.http.expect('DELETE', requestUri,
            respondWith: new MockResponse.internalServerError());
        MockTransports.http.expect('DELETE', requestUri);

        BaseRequest request = requestFactory();
        request.autoRetry
          ..enabled = true
          ..maxRetries = 2
          ..forHttpMethods = ['DELETE'];

        await request.delete(uri: requestUri);
        expect(request.autoRetry.numAttempts, equals(2));
        expect(request.autoRetry.failures.length, equals(1));
      });

      test('custom retry eligibility test', () async {
        // 1st request = 500, 2nd request = 200
        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri);

        BaseRequest request = requestFactory();
        request.autoRetry
          ..enabled = true
          ..maxRetries = 2
          ..test = (request, response, willRetry) async => willRetry;

        await request.get(uri: requestUri);
        expect(request.autoRetry.numAttempts, equals(2));
        expect(request.autoRetry.failures.length, equals(1));
      });

      test('custom retry eligibility test defers to rest of configuration',
          () async {
        // 1st request = 404
        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.notFound());

        BaseRequest request = requestFactory();
        request.autoRetry
          ..enabled = true
          ..maxRetries = 2
          ..test = (request, response, willRetry) async => willRetry;

        expect(request.get(uri: requestUri),
            throwsA(new isInstanceOf<RequestException>()));
        await request.done;
        expect(request.autoRetry.numAttempts, equals(1));
        expect(request.autoRetry.failures.length, equals(1));
      });

      test(
          'request cancellation during a retry attempt should cancel the retry',
          () async {
        // 1st request = 500, 2nd request hangs indefinitely
        int c = 0;
        MockTransports.http.when(requestUri, (request) async {
          if (++c == 1) {
            return new MockResponse.internalServerError();
          } else {
            await new Future.delayed(new Duration(seconds: 10));
          }
        }, method: 'GET');

        BaseRequest request = requestFactory();
        request.autoRetry
          ..enabled = true
          ..maxRetries = 2;

        Future future = request.get(uri: requestUri);
        await new Future.delayed(new Duration(milliseconds: 500));
        request.abort();
        expect(future, throwsA(predicate((exception) {
          return exception is RequestException &&
              exception.toString().contains('Request canceled');
        })));
      });

      test('request timeout should be retried by default', () async {
        // 1st request = hangs until timeout, 2nd request succeeds
        int c = 0;
        MockTransports.http.when(requestUri, (request) async {
          if (++c == 1) {
            await new Future.delayed(new Duration(seconds: 1));
          } else {
            return new MockResponse.ok();
          }
        }, method: 'GET');

        BaseRequest request = requestFactory();
        request.timeoutThreshold = new Duration(milliseconds: 250);
        request.autoRetry
          ..enabled = true
          ..maxRetries = 2;

        await request.get(uri: requestUri);
        expect(request.autoRetry.numAttempts, equals(2));
      });

      test('request timeout should not be retried if disabled', () async {
        // 1st request = hangs until timeout
        MockTransports.http.when(requestUri, (request) async {
          await new Future.delayed(new Duration(seconds: 1));
        }, method: 'GET');

        BaseRequest request = requestFactory();
        request.timeoutThreshold = new Duration(milliseconds: 250);
        request.autoRetry
          ..enabled = true
          ..forTimeouts = false
          ..maxRetries = 2;

        var future = request.get(uri: requestUri);
        expect(future, throwsA(new isInstanceOf<RequestException>()));
        await future.catchError((_) {});
        expect(request.autoRetry.numAttempts, equals(1));
      });

      test('no retry back-off by default', () async {
        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri);

        BaseRequest request = requestFactory();
        request.autoRetry
          ..enabled = true
          ..maxRetries = 3;
        request.get(uri: requestUri);

        // Wait an arbitrarily short amount of time to allow all retries to
        // complete with confidence that no back-off occurred.
        await new Future.delayed(new Duration(milliseconds: 20));
        expect(request.autoRetry.numAttempts, equals(4));
      });

      test('fixed retry back-off', () async {
        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri);

        BaseRequest request = requestFactory();
        request.autoRetry
          ..enabled = true
          ..maxRetries = 3
          ..backOff = new RetryBackOff.fixed(new Duration(milliseconds: 50),
              withJitter: false);
        request.get(uri: requestUri);

        // < 50ms = 1 attempt
        // < 100ms = 2 attempts
        // < 150ms = 3 attempts
        // >= 150ms = 4 attempts
        await new Future.delayed(new Duration(milliseconds: 25));
        expect(request.autoRetry.numAttempts, equals(1));
        await new Future.delayed(new Duration(milliseconds: 50));
        expect(request.autoRetry.numAttempts, equals(2));
        await new Future.delayed(new Duration(milliseconds: 50));
        expect(request.autoRetry.numAttempts, equals(3));
        await new Future.delayed(new Duration(milliseconds: 50));
        expect(request.autoRetry.numAttempts, equals(4));
      });

      test('fixed retry back-off with jitter', () async {
        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri);

        BaseRequest request = requestFactory();
        request.autoRetry
          ..enabled = true
          ..maxRetries = 3
          ..backOff = new RetryBackOff.fixed(new Duration(milliseconds: 15),
              withJitter: true);
        request.get(uri: requestUri);

        // 1st attempt = immediate
        // 2nd attempt = +0 to 15s
        // 3rd attempt = +0 to 15s
        // 4th attempt = +0 to 15s
        await new Future.delayed(new Duration(milliseconds: 100));
        expect(request.autoRetry.numAttempts, equals(4));
      });

      test('exponential retry back-off', () async {
        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri);

        BaseRequest request = requestFactory();
        request.autoRetry
          ..enabled = true
          ..maxRetries = 3
          ..backOff = new RetryBackOff.exponential(
              new Duration(milliseconds: 25),
              withJitter: false);
        request.get(uri: requestUri);

        // 1st attempt = immediate
        // 2nd attempt = +50s (25*2^1)
        // 3rd attempt = +100s (25*2^2)
        // 4th attempt = +200s (25*2^3)
        await new Future.delayed(new Duration(milliseconds: 1));
        expect(request.autoRetry.numAttempts, equals(1));
        await new Future.delayed(new Duration(milliseconds: 60));
        expect(request.autoRetry.numAttempts, equals(2));
        await new Future.delayed(new Duration(milliseconds: 120));
        expect(request.autoRetry.numAttempts, equals(3));
        await new Future.delayed(new Duration(milliseconds: 240));
        expect(request.autoRetry.numAttempts, equals(4));
      });

      test('exponential retry back-off with jitter', () async {
        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.internalServerError());
        MockTransports.http.expect('GET', requestUri);

        BaseRequest request = requestFactory();
        request.autoRetry
          ..enabled = true
          ..maxRetries = 3
          ..backOff = new RetryBackOff.exponential(
              new Duration(milliseconds: 25),
              withJitter: true);
        request.get(uri: requestUri);

        // 1st attempt = immediate
        // 2nd attempt = +0 to 50s (25*2^1)
        // 3rd attempt = +0 to 100s (25*2^2) + 2nd attempt
        // 4th attempt = +0 to 200s (25*2^3) + 3rd attempt
        await new Future.delayed(new Duration(milliseconds: 500));
        expect(request.autoRetry.numAttempts, equals(4));
      });

      test('RequestException should detail all attempts', () async {
        // 1st = 400, 2nd = 403, 3rd = 500, 4th = error, 5th = timeout
        int c = 0;
        MockTransports.http.when(requestUri, (request) async {
          switch (++c) {
            case 1:
              return new MockResponse.badRequest();
            case 2:
              return new MockResponse.forbidden();
            case 3:
              return new MockResponse.internalServerError();
            case 4:
              await new Future.delayed(new Duration(seconds: 1));
              return new MockResponse.notImplemented();
            case 5:
              throw new Exception('Unexpected failure.');
          }
        });

        BaseRequest request = requestFactory()
          ..timeoutThreshold = new Duration(milliseconds: 100);
        request.autoRetry
          ..enabled = true
          ..maxRetries = 4
          ..test = (request, response, willRetry) async => true;

        expect(request.get(uri: requestUri), throwsA(predicate((error) {
          var reqEx = error as RequestException;
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
        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.badRequest());
        MockTransports.http.expect('GET', requestUri);
        BaseRequest request = requestFactory();
        await request.get(uri: requestUri).catchError((_) {});
        await request.retry();
      });

      test('manual retry() throws if not yet sent', () async {
        BaseRequest request = requestFactory();
        expect(request.retry, throwsStateError);
      });

      test('manual retry() throws if not yet complete', () async {
        MockTransports.http
            .when(requestUri, (request) => new Completer().future);
        BaseRequest request = requestFactory();
        request.get(uri: requestUri);
        await new Future.delayed(new Duration(milliseconds: 10));
        expect(request.retry, throwsStateError);
      });

      test('manual retry() throws if did not fail', () async {
        MockTransports.http.expect('GET', requestUri);
        BaseRequest request = requestFactory();
        await request.get(uri: requestUri);
        expect(request.retry, throwsStateError);
      });

      test('manual streamRetry()', () async {
        MockTransports.http.expect('GET', requestUri,
            respondWith: new MockResponse.badRequest());
        MockTransports.http.expect('GET', requestUri);
        BaseRequest request = requestFactory();
        await request.get(uri: requestUri).catchError((_) {});
        await request.streamRetry();
      });

      test('manual streamRetry() throws if not yet sent', () async {
        BaseRequest request = requestFactory();
        expect(request.streamRetry, throwsStateError);
      });

      test('manual streamRetry() throws if not yet complete', () async {
        MockTransports.http
            .when(requestUri, (request) => new Completer().future);
        BaseRequest request = requestFactory();
        request.get(uri: requestUri);
        await new Future.delayed(new Duration(milliseconds: 10));
        expect(request.streamRetry, throwsStateError);
      });

      test('manual streamRetry() throws if did not fail', () async {
        MockTransports.http.expect('GET', requestUri);
        BaseRequest request = requestFactory();
        await request.get(uri: requestUri);
        expect(request.streamRetry, throwsStateError);
      });
    });
  });
}
