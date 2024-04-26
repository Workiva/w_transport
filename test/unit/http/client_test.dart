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

import 'package:test/test.dart';
import 'package:w_transport/mock.dart';
import 'package:w_transport/w_transport.dart' as transport;

import '../../naming.dart';

abstract class ReqIntMixin implements transport.HttpInterceptor {
  @override
  Future<transport.RequestPayload> interceptRequest(
      transport.RequestPayload payload) async {
    payload.request.headers['x-intercepted'] = 'true';
    return payload;
  }
}

abstract class RespIntMixin implements transport.HttpInterceptor {
  @override
  Future<transport.ResponsePayload> interceptResponse(
      transport.ResponsePayload payload) async {
    final response = payload.response! as transport.Response;
    final newHeaders = Map<String, String>.from(response.headers);
    newHeaders['x-intercepted'] = 'true';
    payload.response = transport.Response.fromString(payload.response!.status,
        payload.response!.statusText, newHeaders, response.body.asString());
    return payload;
  }
}

class ReqInt extends transport.HttpInterceptor with ReqIntMixin {}

class RespInt extends transport.HttpInterceptor with RespIntMixin {}

class ReqRespInt extends transport.HttpInterceptor
    with ReqIntMixin, RespIntMixin {}

class AsyncInt extends transport.HttpInterceptor {
  @override
  Future<transport.RequestPayload> interceptRequest(
      transport.RequestPayload payload) async {
    await Future.delayed(Duration(milliseconds: 500));
    payload.request.updateQuery({'interceptor': 'asyncint'});
    return payload;
  }

  @override
  Future<transport.ResponsePayload> interceptResponse(
      transport.ResponsePayload payload) async {
    await Future.delayed(Duration(milliseconds: 500));
    final response = payload.response! as transport.Response;
    final headers = Map<String, String>.from(response.headers);
    headers['x-interceptor'] =
        payload.request.uri.queryParameters['interceptor'] ?? '';
    payload.response = transport.Response.fromString(payload.response!.status,
        payload.response!.statusText, headers, response.body.asString());
    return payload;
  }
}

// ignore: deprecated_member_use_from_same_package
Iterable<transport.BaseRequest> createAllRequestTypes(transport.Client client) {
  return <transport.BaseRequest>[
    client.newFormRequest(),
    client.newJsonRequest(),
    client.newMultipartRequest(),
    client.newRequest(),
    client.newStreamedRequest(),
  ];
}

void main() {
  final naming = Naming()
    ..testType = testTypeUnit
    ..topic = topicHttp;

  group(naming.toString(), () {
    setUp(() {
      MockTransports.install();
    });

    tearDown(() async {
      MockTransports.verifyNoOutstandingExceptions();
      await MockTransports.uninstall();
    });

    group('Client', () {
      // ignore: deprecated_member_use_from_same_package
      _runHttpClientSuite(() => transport.Client());
    });

    group('HttpClient', () {
      _runHttpClientSuite(() => transport.HttpClient());
    });
  });
}

// ignore: deprecated_member_use_from_same_package
void _runHttpClientSuite(transport.Client getClient()) {
  // ignore: deprecated_member_use_from_same_package
  late transport.Client client;

  setUp(() {
    client = getClient();
  });

  test('newFormRequest() should create a new request', () async {
    expect(client.newFormRequest(), isA<transport.FormRequest>());
  });

  test('newFormRequest() should throw if closed', () async {
    client.close();
    expect(client.newFormRequest, throwsStateError);
  });

  test('newJsonRequest() should create a new request', () async {
    expect(client.newJsonRequest(), isA<transport.JsonRequest>());
  });

  test('newJsonRequest() should throw if closed', () async {
    client.close();
    expect(client.newJsonRequest, throwsStateError);
  });

  test('newMultipartRequest() should create a new request', () async {
    expect(client.newMultipartRequest(), isA<transport.MultipartRequest>());
  });

  test('newMultipartRequest() should throw if closed', () async {
    client.close();
    expect(client.newMultipartRequest, throwsStateError);
  });

  test('newRequest() should create a new request', () async {
    expect(client.newRequest(), isA<transport.Request>());
  });

  test('newRequest() should throw if closed', () async {
    client.close();
    expect(client.newRequest, throwsStateError);
  });

  test('newStreamedRequest() should create a new request', () async {
    expect(client.newStreamedRequest(), isA<transport.StreamedRequest>());
  });

  test('newStreamedRequest() should throw if closed', () async {
    client.close();
    expect(client.newStreamedRequest, throwsStateError);
  });

  test('complete request', () async {
    final uri = Uri.parse('/test');
    MockTransports.http.expect('GET', uri);
    await client.newRequest().get(uri: uri);
  });

  test('baseUri should be inherited by all requests', () async {
    final baseUri = Uri.parse('https://example.com/base/path');
    client.baseUri = baseUri;
    for (final request in createAllRequestTypes(client)) {
      expect(request.uri, equals(baseUri));
    }
  });

  test('headers should be inherited by all requests', () async {
    final headers = <String, String>{
      'x-custom1': 'value',
      'x-custom2': 'value2'
    };
    client.headers = headers;
    expect(client.headers, equals(headers));
    for (final request in createAllRequestTypes(client)) {
      final uri = Uri.parse('/test');
      MockTransports.http.expect('GET', uri, headers: headers);
      if (request is transport.MultipartRequest) {
        request.fields['f'] = 'v';
      }
      await request.get(uri: uri);
    }
  });

  test('timeoutThreshold should be inherited by all requests', () async {
    final tt = Duration(seconds: 1);
    client.timeoutThreshold = tt;
    expect(client.timeoutThreshold, equals(tt));
    for (final request in createAllRequestTypes(client)) {
      expect(request.timeoutThreshold, equals(tt));
    }
  });

  test('withCredentials should be inherited by all requests', () async {
    client.withCredentials = true;
    expect(client.withCredentials, isTrue);
    for (final request in createAllRequestTypes(client)) {
      final uri = Uri.parse('/test');
      final c = Completer<Null>();
      MockTransports.http.when(() => uri, (FinalizedRequest request) async {
        request.withCredentials
            ? c.complete()
            : c.completeError(Exception('withCredentials should be true'));
        return MockResponse.ok();
      }, method: 'GET');
      if (request is transport.MultipartRequest) {
        request.fields['f'] = 'v';
      }
      await request.get(uri: uri);
      await c.future;
    }
  });

  test('autoRetry should be inherited by all requests', () async {
    client.autoRetry
      ..backOff = const transport.RetryBackOff.fixed(Duration(seconds: 2))
      ..enabled = true
      ..forHttpMethods = ['GET']
      ..forStatusCodes = [404]
      ..forTimeouts = false
      ..maxRetries = 4
      ..test = (request, response, willRetry) async => true;

    for (final request in createAllRequestTypes(client)) {
      expect(request.autoRetry.backOff.interval,
          equals(client.autoRetry.backOff.interval));
      expect(request.autoRetry.backOff.method,
          equals(client.autoRetry.backOff.method));
      expect(request.autoRetry.enabled, equals(client.autoRetry.enabled));
      expect(request.autoRetry.forHttpMethods,
          equals(client.autoRetry.forHttpMethods));
      expect(request.autoRetry.forStatusCodes,
          equals(client.autoRetry.forStatusCodes));
      expect(
          request.autoRetry.forTimeouts, equals(client.autoRetry.forTimeouts));
      expect(request.autoRetry.maxRetries, equals(client.autoRetry.maxRetries));
      expect(request.autoRetry.test, equals(client.autoRetry.test));
    }
  });

  test('addInterceptor() single interceptor (request only)', () async {
    client.addInterceptor(ReqInt());
    for (final request in createAllRequestTypes(client)) {
      final uri = Uri.parse('/test');
      MockTransports.http
          .expect('GET', uri, headers: {'x-intercepted': 'true'});
      if (request is transport.MultipartRequest) {
        request.fields['f'] = 'v';
      }
      await request.get(uri: uri);
    }
  });

  test('addInterceptor() single interceptor (response only)', () async {
    client.addInterceptor(RespInt());
    for (final request in createAllRequestTypes(client)) {
      final uri = Uri.parse('/test');
      MockTransports.http.expect('GET', uri);
      if (request is transport.MultipartRequest) {
        request.fields['f'] = 'v';
      }
      final response = await request.get(uri: uri);
      expect(response.headers, containsPair('x-intercepted', 'true'));
    }
  });

  test('addInterceptor() single interceptor', () async {
    client.addInterceptor(ReqRespInt());
    for (final request in createAllRequestTypes(client)) {
      final uri = Uri.parse('/test');
      MockTransports.http
          .expect('GET', uri, headers: {'x-intercepted': 'true'});
      if (request is transport.MultipartRequest) {
        request.fields['f'] = 'v';
      }
      final response = await request.get(uri: uri);
      expect(response.headers, containsPair('x-intercepted', 'true'));
    }
  });

  test('addInterceptor() multiple interceptors', () async {
    client
      ..addInterceptor(ReqRespInt())
      ..addInterceptor(AsyncInt());
    for (final request in createAllRequestTypes(client)) {
      final uri = Uri.parse('/test');
      final augmentedUri =
          uri.replace(queryParameters: {'interceptor': 'asyncint'});
      MockTransports.http
          .expect('GET', augmentedUri, headers: {'x-intercepted': 'true'});
      if (request is transport.MultipartRequest) {
        request.fields['f'] = 'v';
      }
      final response = await request.get(uri: uri);
      expect(response.headers, containsPair('x-intercepted', 'true'));
      expect(response.headers, containsPair('x-interceptor', 'asyncint'));
    }
  });

  test('close()', () async {
    final future = client.newRequest().get(uri: Uri.parse('/test'));
    client.close();
    expect(future, throwsA(isA<transport.RequestException>()));
  });
}
