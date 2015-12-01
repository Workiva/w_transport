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

library w_transport.test.integration.http.common_request.suite;

import 'dart:async';
import 'dart:convert';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';

import '../../integration_paths.dart';

void runCommonRequestSuite() {
  group('Common Request API', () {
    _runCommonRequestSuiteFor('FormRequest', ({bool withBody: false}) {
      if (!withBody) return new FormRequest();
      return new FormRequest()..fields['field'] = 'value';
    });
    _runCommonRequestSuiteFor('JsonRequest', ({bool withBody: false}) {
      if (!withBody) return new JsonRequest();
      return new JsonRequest()
        ..body = [
          {'field': 'value'}
        ];
    });
    _runCommonRequestSuiteFor('MultipartRequest', ({bool withBody}) {
      // Multipart requests can't be empty.
      return new MultipartRequest()..fields['field'] = 'value';
    });
    _runCommonRequestSuiteFor('Request', ({bool withBody: false}) {
      if (!withBody) return new Request();
      return new Request()..body = 'body';
    });
    _runCommonRequestSuiteFor('StreamedRequest', ({bool withBody: false}) {
      if (!withBody) return new StreamedRequest();
      return new StreamedRequest()
        ..body = new Stream.fromIterable([UTF8.encode('bytes')])
        ..contentLength = UTF8.encode('bytes').length;
    });
  });
}

void _runCommonRequestSuiteFor(
    String name, BaseRequest requestFactory({bool withBody})) {
  group(name, () {
    var headers = {
      'authorization': 'test',
      'x-custom': 'value',
      'x-tokens': 'token1, token2'
    };

    test('"done" should complete when the request succeeds', () async {
      BaseRequest request = requestFactory();
      request.post(uri: IntegrationPaths.reflectEndpointUri);
      await request.done;
    });

    test('"done" should complete when the request is canceled', () async {
      BaseRequest request = requestFactory();

      try {
        Future future = request.post(uri: IntegrationPaths.timeoutEndpointUri);
        await new Future.delayed(new Duration(milliseconds: 5));
        request.abort();
        await future;
      } on RequestException {}

      await request.done;
    });

    test('"done" should complete when the request fails', () async {
      BaseRequest request = requestFactory();
      try {
        await request.post(uri: IntegrationPaths.fourOhFourEndpointUri);
      } on RequestException {}
      await request.done;
    });

    test('DELETE (streamed)', () async {
      BaseRequest request = requestFactory();
      StreamedResponse response =
          await request.streamDelete(uri: IntegrationPaths.downloadEndpointUri);
      expect(response.status, equals(200));
      expect(await response.body.byteStream.isEmpty, isFalse);
    });

    test('GET (streamed)', () async {
      BaseRequest request = requestFactory();
      StreamedResponse response =
          await request.streamGet(uri: IntegrationPaths.downloadEndpointUri);
      expect(response.status, equals(200));
      expect(await response.body.byteStream.isEmpty, isFalse);
    });

    test('HEAD (streamed)', () async {
      BaseRequest request = requestFactory();
      StreamedResponse response =
          await request.streamHead(uri: IntegrationPaths.downloadEndpointUri);
      expect(response.status, equals(200));
    });

    test('OPTIONS (streamed)', () async {
      BaseRequest request = requestFactory();
      StreamedResponse response = await request.streamOptions(
          uri: IntegrationPaths.downloadEndpointUri);
      expect(response.status, equals(200));
      expect(await response.body.byteStream.isEmpty, isFalse);
    });

    test('PATCH (streamed)', () async {
      BaseRequest request = requestFactory();
      StreamedResponse response =
          await request.streamPatch(uri: IntegrationPaths.downloadEndpointUri);
      expect(response.status, equals(200));
      expect(await response.body.byteStream.isEmpty, isFalse);
    });

    test('POST (streamed)', () async {
      BaseRequest request = requestFactory();
      StreamedResponse response =
          await request.streamPost(uri: IntegrationPaths.downloadEndpointUri);
      expect(response.status, equals(200));
      expect(await response.body.byteStream.isEmpty, isFalse);
    });

    test('PUT (streamed)', () async {
      BaseRequest request = requestFactory();
      StreamedResponse response =
          await request.streamPut(uri: IntegrationPaths.downloadEndpointUri);
      expect(response.status, equals(200));
      expect(await response.body.byteStream.isEmpty, isFalse);
    });

    test('custom HTTP method (streamed)', () async {
      BaseRequest request = requestFactory();
      StreamedResponse response = await request.streamSend('COPY',
          uri: IntegrationPaths.downloadEndpointUri);
      expect(response.status, equals(200));
      expect(await response.body.byteStream.isEmpty, isFalse);
    });

    test('DELETE request', () async {
      BaseRequest request = requestFactory();
      Response response =
          await request.delete(uri: IntegrationPaths.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('DELETE'));
    });

    test('DELETE request with headers', () async {
      BaseRequest request = requestFactory()
        ..uri = IntegrationPaths.reflectEndpointUri
        ..headers = new Map.from(headers);
      Response response = await request.delete();
      expect(response.status, equals(200));

      var json = response.body.asJson();
      expect(json['method'], equals('DELETE'));
      expect(json['headers'],
          containsPair('authorization', request.headers['authorization']));
      expect(json['headers'],
          containsPair('x-custom', request.headers['x-custom']));
      expect(json['headers'],
          containsPair('x-tokens', request.headers['x-tokens']));
    });

    test('GET request', () async {
      BaseRequest request = requestFactory();
      Response response =
          await request.get(uri: IntegrationPaths.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('GET'));
    });

    test('GET request with headers', () async {
      BaseRequest request = requestFactory()
        ..uri = IntegrationPaths.reflectEndpointUri
        ..headers = new Map.from(headers);
      Response response = await request.get();
      expect(response.status, equals(200));

      var json = response.body.asJson();
      expect(json['method'], equals('GET'));
      expect(json['headers'],
          containsPair('authorization', request.headers['authorization']));
      expect(json['headers'],
          containsPair('x-custom', request.headers['x-custom']));
      expect(json['headers'],
          containsPair('x-tokens', request.headers['x-tokens']));
    });

    test('HEAD request', () async {
      BaseRequest request = requestFactory();
      Response response =
          await request.head(uri: IntegrationPaths.reflectEndpointUri);
      expect(response.status, equals(200));
    });

    test('HEAD request with headers', () async {
      BaseRequest request = requestFactory()
        ..uri = IntegrationPaths.reflectEndpointUri
        ..headers = new Map.from(headers);
      Response response = await request.head();
      expect(response.status, equals(200));
    });

    test('OPTIONS request', () async {
      BaseRequest request = requestFactory();
      Response response =
          await request.options(uri: IntegrationPaths.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('OPTIONS'));
    });

    test('OPTIONS request with headers', () async {
      BaseRequest request = requestFactory()
        ..uri = IntegrationPaths.reflectEndpointUri
        ..headers = new Map.from(headers);
      Response response = await request.options();
      expect(response.status, equals(200));

      var json = response.body.asJson();
      expect(json['method'], equals('OPTIONS'));
      expect(json['headers'],
          containsPair('authorization', request.headers['authorization']));
      expect(json['headers'],
          containsPair('x-custom', request.headers['x-custom']));
      expect(json['headers'],
          containsPair('x-tokens', request.headers['x-tokens']));
    });

    test('PATCH request', () async {
      BaseRequest request = requestFactory();
      Response response =
          await request.patch(uri: IntegrationPaths.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('PATCH'));
    });

    test('PATCH request with headers', () async {
      BaseRequest request = requestFactory()
        ..uri = IntegrationPaths.reflectEndpointUri
        ..headers = new Map.from(headers);
      Response response = await request.patch();
      expect(response.status, equals(200));

      var json = response.body.asJson();
      expect(json['method'], equals('PATCH'));
      expect(json['headers'],
          containsPair('authorization', request.headers['authorization']));
      expect(json['headers'],
          containsPair('x-custom', request.headers['x-custom']));
      expect(json['headers'],
          containsPair('x-tokens', request.headers['x-tokens']));
    });

    test('POST request', () async {
      BaseRequest request = requestFactory();
      Response response =
          await request.post(uri: IntegrationPaths.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('POST'));
    });

    test('POST request with headers', () async {
      BaseRequest request = requestFactory()
        ..uri = IntegrationPaths.reflectEndpointUri
        ..headers = new Map.from(headers);
      Response response = await request.post();
      expect(response.status, equals(200));

      var json = response.body.asJson();
      expect(json['method'], equals('POST'));
      expect(json['headers'],
          containsPair('authorization', request.headers['authorization']));
      expect(json['headers'],
          containsPair('x-custom', request.headers['x-custom']));
      expect(json['headers'],
          containsPair('x-tokens', request.headers['x-tokens']));
    });

    test('PUT request', () async {
      BaseRequest request = requestFactory();
      Response response =
          await request.put(uri: IntegrationPaths.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('PUT'));
    });

    test('PUT request with headers', () async {
      BaseRequest request = requestFactory()
        ..uri = IntegrationPaths.reflectEndpointUri
        ..headers = new Map.from(headers);
      Response response = await request.put();
      expect(response.status, equals(200));

      var json = response.body.asJson();
      expect(json['method'], equals('PUT'));
      expect(json['headers'],
          containsPair('authorization', request.headers['authorization']));
      expect(json['headers'],
          containsPair('x-custom', request.headers['x-custom']));
      expect(json['headers'],
          containsPair('x-tokens', request.headers['x-tokens']));
    });

    test('upload progress stream', () async {
      Completer uploadProgressListenedTo = new Completer();
      BaseRequest request = requestFactory(withBody: true)
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
      Completer downloadProgressListenedTo = new Completer();
      BaseRequest request = requestFactory()
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
      BaseRequest request = requestFactory()
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
      BaseRequest request = requestFactory()..uri = IntegrationPaths.hostUri;
      request.abort();
      expect(request.get(), throwsA(predicate((exception) {
        return exception is RequestException &&
            exception.toString().contains('canceled');
      })));
    });

    test(
        'request cancellation after dispatch but prior to resolution should cause request to fail',
        () async {
      BaseRequest request = requestFactory()
        ..uri = IntegrationPaths.timeoutEndpointUri;
      Future future = request.get();

      // Wait a sufficient amount of time to allow the request to open.
      // Since we're hitting a timeout endpoint, it shouldn't complete.
      await new Future.delayed(new Duration(seconds: 1));

      // Abort the request now that it is in flight.
      request.abort();
      expect(future, throwsA(new isInstanceOf<RequestException>()));
    });

    test('timeoutThreshold does nothing if request completes in time',
        () async {
      BaseRequest request = requestFactory()
        ..timeoutThreshold = new Duration(seconds: 5);
      await request.get(uri: IntegrationPaths.pingEndpointUri);
    });

    test('timeoutThreshold cancels the request if exceeded', () async {
      BaseRequest request = requestFactory()
        ..timeoutThreshold = new Duration(milliseconds: 250);
      expect(request.get(uri: IntegrationPaths.timeoutEndpointUri),
          throwsA(predicate((error) {
        return error is RequestException && error.error is TimeoutException;
      })));
    });
  });
}
