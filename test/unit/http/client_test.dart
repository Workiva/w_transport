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
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/mock.dart';

import '../../naming.dart';

abstract class ReqIntMixin implements HttpInterceptor {
  @override
  Future<RequestPayload> interceptRequest(RequestPayload payload) async {
    payload.request.headers['x-intercepted'] = 'true';
    return payload;
  }
}

abstract class RespIntMixin implements HttpInterceptor {
  @override
  Future<ResponsePayload> interceptResponse(ResponsePayload payload) async {
    final newHeaders = new Map<String, String>.from(payload.response.headers);
    newHeaders['x-intercepted'] = 'true';
    Response response = payload.response;
    payload.response = new Response.fromString(payload.response.status,
        payload.response.statusText, newHeaders, response.body.asString());
    return payload;
  }
}

class ReqInt extends HttpInterceptor with ReqIntMixin {}

class RespInt extends HttpInterceptor with RespIntMixin {}

class ReqRespInt extends HttpInterceptor with ReqIntMixin, RespIntMixin {}

class AsyncInt extends HttpInterceptor {
  @override
  Future<RequestPayload> interceptRequest(RequestPayload payload) async {
    await new Future.delayed(new Duration(milliseconds: 500));
    payload.request.updateQuery({'interceptor': 'asyncint'});
    return payload;
  }

  @override
  Future<ResponsePayload> interceptResponse(ResponsePayload payload) async {
    await new Future.delayed(new Duration(milliseconds: 500));
    final headers = new Map<String, String>.from(payload.response.headers);
    Response response = payload.response;
    headers['x-interceptor'] =
        payload.request.uri.queryParameters['interceptor'];
    payload.response = new Response.fromString(payload.response.status,
        payload.response.statusText, headers, response.body.asString());
    return payload;
  }
}

Iterable<BaseRequest> createAllRequestTypes(Client client) {
  return <BaseRequest>[
    client.newFormRequest(),
    client.newJsonRequest(),
    client.newMultipartRequest(),
    client.newRequest(),
    client.newStreamedRequest(),
  ];
}

void main() {
  final naming = new Naming()
    ..testType = testTypeUnit
    ..topic = topicHttp;

  group(naming.toString(), () {
    setUp(() async {
      configureWTransportForTest();
      await MockTransports.reset();
    });

    group('Client', () {
      _runHttpClientSuite(() => new Client());
    });

    group('HttpClient', () {
      _runHttpClientSuite(() => new HttpClient());
    });
  });
}

void _runHttpClientSuite(Client getClient()) {
  Client client;

  setUp(() {
    client = getClient();
  });

  test('newFormRequest() should create a new request', () async {
    expect(client.newFormRequest(), new isInstanceOf<FormRequest>());
  });

  test('newFormRequest() should throw if closed', () async {
    client.close();
    expect(client.newFormRequest, throwsStateError);
  });

  test('newJsonRequest() should create a new request', () async {
    expect(client.newJsonRequest(), new isInstanceOf<JsonRequest>());
  });

  test('newJsonRequest() should throw if closed', () async {
    client.close();
    expect(client.newJsonRequest, throwsStateError);
  });

  test('newMultipartRequest() should create a new request', () async {
    expect(client.newMultipartRequest(), new isInstanceOf<MultipartRequest>());
  });

  test('newMultipartRequest() should throw if closed', () async {
    client.close();
    expect(client.newMultipartRequest, throwsStateError);
  });

  test('newRequest() should create a new request', () async {
    expect(client.newRequest(), new isInstanceOf<Request>());
  });

  test('newRequest() should throw if closed', () async {
    client.close();
    expect(client.newRequest, throwsStateError);
  });

  test('newStreamedRequest() should create a new request', () async {
    expect(client.newStreamedRequest(), new isInstanceOf<StreamedRequest>());
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
      if (request is MultipartRequest) {
        request.fields['f'] = 'v';
      }
      await request.get(uri: uri);
    }
  });

  test('timeoutThreshold should be inherited by all requests', () async {
    final tt = new Duration(seconds: 1);
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
      final c = new Completer<Null>();
      MockTransports.http.when(uri, (FinalizedRequest request) async {
        request.withCredentials
            ? c.complete()
            : c.completeError(new Exception('withCredentials should be true'));
        return new MockResponse.ok();
      }, method: 'GET');
      if (request is MultipartRequest) {
        request.fields['f'] = 'v';
      }
      await request.get(uri: uri);
      await c.future;
    }
  });

  test('autoRetry should be inherited by all requests', () async {
    client.autoRetry
      ..backOff = const RetryBackOff.fixed(const Duration(seconds: 2))
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
    client.addInterceptor(new ReqInt());
    for (final request in createAllRequestTypes(client)) {
      final uri = Uri.parse('/test');
      MockTransports.http
          .expect('GET', uri, headers: {'x-intercepted': 'true'});
      if (request is MultipartRequest) {
        request.fields['f'] = 'v';
      }
      await request.get(uri: uri);
    }
  });

  test('addInterceptor() single interceptor (response only)', () async {
    client.addInterceptor(new RespInt());
    for (final request in createAllRequestTypes(client)) {
      final uri = Uri.parse('/test');
      MockTransports.http.expect('GET', uri);
      if (request is MultipartRequest) {
        request.fields['f'] = 'v';
      }
      final response = await request.get(uri: uri);
      expect(response.headers, containsPair('x-intercepted', 'true'));
    }
  });

  test('addInterceptor() single interceptor', () async {
    client.addInterceptor(new ReqRespInt());
    for (final request in createAllRequestTypes(client)) {
      final uri = Uri.parse('/test');
      MockTransports.http
          .expect('GET', uri, headers: {'x-intercepted': 'true'});
      if (request is MultipartRequest) {
        request.fields['f'] = 'v';
      }
      final response = await request.get(uri: uri);
      expect(response.headers, containsPair('x-intercepted', 'true'));
    }
  });

  test('addInterceptor() multiple interceptors', () async {
    client..addInterceptor(new ReqRespInt())..addInterceptor(new AsyncInt());
    for (final request in createAllRequestTypes(client)) {
      final uri = Uri.parse('/test');
      final augmentedUri =
          uri.replace(queryParameters: {'interceptor': 'asyncint'});
      MockTransports.http
          .expect('GET', augmentedUri, headers: {'x-intercepted': 'true'});
      if (request is MultipartRequest) {
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
    expect(future, throws);
  });
}
