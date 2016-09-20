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

import 'dart:async';
import 'dart:convert';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';

import '../../integration_paths.dart';

void runCommonRequestSuite() {
  group('Common Request API', () {
    FormRequest formReqFactory({bool withBody: false}) {
      if (!withBody) return new FormRequest();
      return new FormRequest()..fields['field'] = 'value';
    }

    JsonRequest jsonReqFactory({bool withBody: false}) {
      if (!withBody) return new JsonRequest();
      return new JsonRequest()
        ..body = [
          {'field': 'value'}
        ];
    }

    MultipartRequest multipartReqFactory({bool withBody}) {
      // Multipart requests can't be empty.
      return new MultipartRequest()..fields['field'] = 'value';
    }

    Request reqFactory({bool withBody: false}) {
      if (!withBody) return new Request();
      return new Request()..body = 'body';
    }

    StreamedRequest streamedReqFactory({bool withBody: false}) {
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
    _runAutoRetryTestSuiteFor('JsonRequest', formReqFactory);
    _runAutoRetryTestSuiteFor('MultipartRequest', formReqFactory);
    _runAutoRetryTestSuiteFor('Request', formReqFactory);
  });
}

void _runCommonRequestSuiteFor(
    String name, BaseRequest requestFactory({bool withBody})) {
  group(name, () {
    final headers = <String, String>{
      'authorization': 'test',
      'x-custom': 'value',
      'x-tokens': 'token1, token2'
    };

    test('"done" should complete when the request succeeds', () async {
      final request = requestFactory();
      // ignore: unawaited_futures
      request.post(uri: IntegrationPaths.reflectEndpointUri);
      await request.done;
    });

    test('"done" should complete when the request is canceled', () async {
      final request = requestFactory();

      try {
        final future = request.post(uri: IntegrationPaths.timeoutEndpointUri);
        await new Future.delayed(new Duration(milliseconds: 5));
        request.abort();
        await future;
      } on RequestException catch (_) {}

      await request.done;
    });

    test('"done" should complete when the request fails', () async {
      final request = requestFactory();
      try {
        await request.post(uri: IntegrationPaths.fourOhFourEndpointUri);
      } on RequestException catch (_) {}
      await request.done;
    });

    test('DELETE (streamed)', () async {
      final request = requestFactory();
      final response =
          await request.streamDelete(uri: IntegrationPaths.downloadEndpointUri);
      expect(response.status, equals(200));
      expect(await response.body.byteStream.isEmpty, isFalse);
    });

    test('GET (streamed)', () async {
      final request = requestFactory();
      final response =
          await request.streamGet(uri: IntegrationPaths.downloadEndpointUri);
      expect(response.status, equals(200));
      expect(await response.body.byteStream.isEmpty, isFalse);
    });

    test('HEAD (streamed)', () async {
      final request = requestFactory();
      final response =
          await request.streamHead(uri: IntegrationPaths.downloadEndpointUri);
      expect(response.status, equals(200));
    });

    test('OPTIONS (streamed)', () async {
      final request = requestFactory();
      final response = await request.streamOptions(
          uri: IntegrationPaths.downloadEndpointUri);
      expect(response.status, equals(200));
      expect(await response.body.byteStream.isEmpty, isFalse);
    });

    test('PATCH (streamed)', () async {
      final request = requestFactory();
      final response =
          await request.streamPatch(uri: IntegrationPaths.downloadEndpointUri);
      expect(response.status, equals(200));
      expect(await response.body.byteStream.isEmpty, isFalse);
    });

    test('POST (streamed)', () async {
      final request = requestFactory();
      final response =
          await request.streamPost(uri: IntegrationPaths.downloadEndpointUri);
      expect(response.status, equals(200));
      expect(await response.body.byteStream.isEmpty, isFalse);
    });

    test('PUT (streamed)', () async {
      final request = requestFactory();
      final response =
          await request.streamPut(uri: IntegrationPaths.downloadEndpointUri);
      expect(response.status, equals(200));
      expect(await response.body.byteStream.isEmpty, isFalse);
    });

    test('custom HTTP method (streamed)', () async {
      final request = requestFactory();
      final response = await request.streamSend('COPY',
          uri: IntegrationPaths.downloadEndpointUri);
      expect(response.status, equals(200));
      expect(await response.body.byteStream.isEmpty, isFalse);
    });

    test('DELETE request', () async {
      final request = requestFactory();
      final response =
          await request.delete(uri: IntegrationPaths.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('DELETE'));
    });

    test('DELETE request with headers', () async {
      final request = requestFactory()
        ..uri = IntegrationPaths.reflectEndpointUri
        ..headers = new Map<String, String>.from(headers);
      final response = await request.delete();
      expect(response.status, equals(200));

      final json = response.body.asJson();
      expect(json['method'], equals('DELETE'));
      expect(json['headers'],
          containsPair('authorization', request.headers['authorization']));
      expect(json['headers'],
          containsPair('x-custom', request.headers['x-custom']));
      expect(json['headers'],
          containsPair('x-tokens', request.headers['x-tokens']));
    });

    test('GET request', () async {
      final request = requestFactory();
      final response =
          await request.get(uri: IntegrationPaths.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('GET'));
    });

    test('GET request with headers', () async {
      final request = requestFactory()
        ..uri = IntegrationPaths.reflectEndpointUri
        ..headers = new Map<String, String>.from(headers);
      final response = await request.get();
      expect(response.status, equals(200));

      final json = response.body.asJson();
      expect(json['method'], equals('GET'));
      expect(json['headers'],
          containsPair('authorization', request.headers['authorization']));
      expect(json['headers'],
          containsPair('x-custom', request.headers['x-custom']));
      expect(json['headers'],
          containsPair('x-tokens', request.headers['x-tokens']));
    });

    test('HEAD request', () async {
      final request = requestFactory();
      final response =
          await request.head(uri: IntegrationPaths.reflectEndpointUri);
      expect(response.status, equals(200));
    });

    test('HEAD request with headers', () async {
      final request = requestFactory()
        ..uri = IntegrationPaths.reflectEndpointUri
        ..headers = new Map<String, String>.from(headers);
      final response = await request.head();
      expect(response.status, equals(200));
    });

    test('OPTIONS request', () async {
      final request = requestFactory();
      final response =
          await request.options(uri: IntegrationPaths.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('OPTIONS'));
    });

    test('OPTIONS request with headers', () async {
      final request = requestFactory()
        ..uri = IntegrationPaths.reflectEndpointUri
        ..headers = new Map<String, String>.from(headers);
      final response = await request.options();
      expect(response.status, equals(200));

      final json = response.body.asJson();
      expect(json['method'], equals('OPTIONS'));
      expect(json['headers'],
          containsPair('authorization', request.headers['authorization']));
      expect(json['headers'],
          containsPair('x-custom', request.headers['x-custom']));
      expect(json['headers'],
          containsPair('x-tokens', request.headers['x-tokens']));
    });

    test('PATCH request', () async {
      final request = requestFactory();
      final response =
          await request.patch(uri: IntegrationPaths.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('PATCH'));
    });

    test('PATCH request with headers', () async {
      final request = requestFactory()
        ..uri = IntegrationPaths.reflectEndpointUri
        ..headers = new Map<String, String>.from(headers);
      final response = await request.patch();
      expect(response.status, equals(200));

      final json = response.body.asJson();
      expect(json['method'], equals('PATCH'));
      expect(json['headers'],
          containsPair('authorization', request.headers['authorization']));
      expect(json['headers'],
          containsPair('x-custom', request.headers['x-custom']));
      expect(json['headers'],
          containsPair('x-tokens', request.headers['x-tokens']));
    });

    test('POST request', () async {
      final request = requestFactory();
      final response =
          await request.post(uri: IntegrationPaths.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('POST'));
    });

    test('POST request with headers', () async {
      final request = requestFactory()
        ..uri = IntegrationPaths.reflectEndpointUri
        ..headers = new Map<String, String>.from(headers);
      final response = await request.post();
      expect(response.status, equals(200));

      final json = response.body.asJson();
      expect(json['method'], equals('POST'));
      expect(json['headers'],
          containsPair('authorization', request.headers['authorization']));
      expect(json['headers'],
          containsPair('x-custom', request.headers['x-custom']));
      expect(json['headers'],
          containsPair('x-tokens', request.headers['x-tokens']));
    });

    test('PUT request', () async {
      final request = requestFactory();
      final response =
          await request.put(uri: IntegrationPaths.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('PUT'));
    });

    test('PUT request with headers', () async {
      final request = requestFactory()
        ..uri = IntegrationPaths.reflectEndpointUri
        ..headers = new Map<String, String>.from(headers);
      final response = await request.put();
      expect(response.status, equals(200));

      final json = response.body.asJson();
      expect(json['method'], equals('PUT'));
      expect(json['headers'],
          containsPair('authorization', request.headers['authorization']));
      expect(json['headers'],
          containsPair('x-custom', request.headers['x-custom']));
      expect(json['headers'],
          containsPair('x-tokens', request.headers['x-tokens']));
    });

    test('upload progress stream', () async {
      final uploadProgressListenedTo = new Completer<Null>();
      final request = requestFactory(withBody: true)
        ..uri = IntegrationPaths.reflectEndpointUri;
      request.uploadProgress.listen((RequestProgress progress) {
        if (progress.percent > 0 && !uploadProgressListenedTo.isCompleted) {
          uploadProgressListenedTo.complete();
        }
      });
      await request.post();
      await uploadProgressListenedTo.future;
    });

    test('download progress stream', () async {
      final downloadProgressListenedTo = new Completer<Null>();
      final request = requestFactory()
        ..uri = IntegrationPaths.downloadEndpointUri;
      request.downloadProgress.listen((RequestProgress progress) {
        if (progress.percent > 0 && !downloadProgressListenedTo.isCompleted) {
          downloadProgressListenedTo.complete();
        }
      });
      await request.get();
      await downloadProgressListenedTo.future;
    });

    test('should throw RequestException on failed requests', () async {
      final request = requestFactory()
        ..uri = IntegrationPaths.fourOhFourEndpointUri;
      expect(
          request.get(),
          throwsA(predicate((exception) {
            return exception != null &&
                exception is RequestException &&
                exception.method == 'GET' &&
                exception.uri == IntegrationPaths.fourOhFourEndpointUri;
          }, 'throws a RequestException')));
    });

    test('request cancellation prior to dispatch should cause request to fail',
        () async {
      final request = requestFactory()..uri = IntegrationPaths.hostUri;
      request.abort();
      expect(request.get(), throwsA(predicate((exception) {
        return exception is RequestException &&
            exception.toString().contains('canceled');
      })));
    });

    test(
        'request cancellation after dispatch but prior to resolution should cause request to fail',
        () async {
      final request = requestFactory()
        ..uri = IntegrationPaths.timeoutEndpointUri;
      final future = request.get();

      // Wait a sufficient amount of time to allow the request to open.
      // Since we're hitting a timeout endpoint, it shouldn't complete.
      await new Future.delayed(new Duration(seconds: 1));

      // Abort the request now that it is in flight.
      request.abort();
      expect(future, throwsA(new isInstanceOf<RequestException>()));
    });

    test('timeoutThreshold does nothing if request completes in time',
        () async {
      final request = requestFactory()
        ..timeoutThreshold = new Duration(seconds: 5);
      await request.get(uri: IntegrationPaths.pingEndpointUri);
    });

    test('timeoutThreshold cancels the request if exceeded', () async {
      final request = requestFactory()
        ..timeoutThreshold = new Duration(milliseconds: 250);
      expect(request.get(uri: IntegrationPaths.timeoutEndpointUri),
          throwsA(predicate((error) {
        return error is RequestException && error.error is TimeoutException;
      })));
    });
  });
}

void _runAutoRetryTestSuiteFor(
    String name, BaseRequest requestFactory({bool withBody})) {
  group(name, () {
    group('auto retry', () {
      test('disabled', () async {
        final request = requestFactory();

        defineResponseChain(request, [500]);

        expect(request.get(), throwsA(new isInstanceOf<RequestException>()));
        await request.done;
        expect(request.autoRetry.numAttempts, equals(1));
        expect(request.autoRetry.failures.length, equals(1));
      });

      test('no retries', () async {
        final request = requestFactory();
        request.autoRetry
          ..enabled = true
          ..maxRetries = 2;

        defineResponseChain(request, [200]);

        await request.get();
        expect(request.autoRetry.numAttempts, equals(1));
        expect(request.autoRetry.failures, isEmpty);
      });

      test('1 successful retry', () async {
        final request = requestFactory();
        request.autoRetry
          ..enabled = true
          ..maxRetries = 2;

        defineResponseChain(request, [500, 200]);

        await request.get();
        expect(request.autoRetry.numAttempts, equals(2));
        expect(request.autoRetry.failures.length, equals(1));
      });

      test('1 failed retry, 1 successful retry', () async {
        final request = requestFactory();
        request.autoRetry
          ..enabled = true
          ..maxRetries = 2;

        defineResponseChain(request, [500, 500, 200]);

        await request.get();
        expect(request.autoRetry.numAttempts, equals(3));
        expect(request.autoRetry.failures.length, equals(2));
      });

      test('maximum retries exceeded', () async {
        final request = requestFactory();
        request.autoRetry
          ..enabled = true
          ..maxRetries = 2;

        defineResponseChain(request, [500, 500, 500]);

        expect(request.get(), throwsA(new isInstanceOf<RequestException>()));
        await request.done;
        expect(request.autoRetry.numAttempts, equals(3));
        expect(request.autoRetry.failures.length, equals(3));
      });
    });
  });
}

void defineResponseChain(BaseRequest request, List<int> statusCodes) {
  request
    ..uri = IntegrationPaths.customEndpointUri
    ..requestInterceptor = (BaseRequest request) {
      request.updateQuery({'status': statusCodes.removeAt(0).toString()});
    };
}
