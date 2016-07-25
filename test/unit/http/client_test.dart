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
library w_transport.test.unit.http.client_test;

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
    var newHeaders = new Map.from(payload.response.headers);
    newHeaders['x-intercepted'] = 'true';
    payload.response = new Response.fromString(
        payload.response.status,
        payload.response.statusText,
        newHeaders,
        (payload.response as Response).body.asString());
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
    var headers = new Map.from(payload.response.headers);
    headers['x-interceptor'] =
        payload.request.uri.queryParameters['interceptor'];
    payload.response = new Response.fromString(
        payload.response.status,
        payload.response.statusText,
        headers,
        (payload.response as Response).body.asString());
    return payload;
  }
}

Iterable<BaseRequest> createAllRequestTypes(Client client) {
  return [
    client.newFormRequest(),
    client.newJsonRequest(),
    client.newMultipartRequest(),
    client.newRequest(),
    client.newStreamedRequest(),
  ];
}

void main() {
  Naming naming = new Naming()
    ..testType = testTypeUnit
    ..topic = topicHttp;

  group(naming.toString(), () {
    group('Client', () {
      setUp(() {
        configureWTransportForTest();
        MockTransports.reset();
      });

      test('newFormRequest() should create a new request', () async {
        Client client = new Client();
        expect(client.newFormRequest(), new isInstanceOf<FormRequest>());
      });

      test('newFormRequest() should throw if closed', () async {
        Client client = new Client();
        client.close();
        expect(client.newFormRequest, throwsStateError);
      });

      test('newJsonRequest() should create a new request', () async {
        Client client = new Client();
        expect(client.newJsonRequest(), new isInstanceOf<JsonRequest>());
      });

      test('newJsonRequest() should throw if closed', () async {
        Client client = new Client();
        client.close();
        expect(client.newJsonRequest, throwsStateError);
      });

      test('newMultipartRequest() should create a new request', () async {
        Client client = new Client();
        expect(
            client.newMultipartRequest(), new isInstanceOf<MultipartRequest>());
      });

      test('newMultipartRequest() should throw if closed', () async {
        Client client = new Client();
        client.close();
        expect(client.newMultipartRequest, throwsStateError);
      });

      test('newRequest() should create a new request', () async {
        Client client = new Client();
        expect(client.newRequest(), new isInstanceOf<Request>());
      });

      test('newRequest() should throw if closed', () async {
        Client client = new Client();
        client.close();
        expect(client.newRequest, throwsStateError);
      });

      test('newStreamedRequest() should create a new request', () async {
        Client client = new Client();
        expect(
            client.newStreamedRequest(), new isInstanceOf<StreamedRequest>());
      });

      test('newStreamedRequest() should throw if closed', () async {
        Client client = new Client();
        client.close();
        expect(client.newStreamedRequest, throwsStateError);
      });

      test('complete request', () async {
        Client client = new Client();
        Uri uri = Uri.parse('/test');
        MockTransports.http.expect('GET', uri);
        await client.newRequest().get(uri: uri);
      });

      test('baseUri should be inherited by all requests', () async {
        var baseUri = Uri.parse('https://example.com/base/path');
        Client client = new Client()..baseUri = baseUri;
        for (var request in createAllRequestTypes(client)) {
          expect(request.uri, equals(baseUri));
        }
      });

      test('headers should be inherited by all requests', () async {
        var headers = {'x-custom1': 'value', 'x-custom2': 'value2'};
        Client client = new Client()..headers = headers;
        expect(client.headers, equals(headers));
        for (var request in createAllRequestTypes(client)) {
          Uri uri = Uri.parse('/test');
          MockTransports.http.expect('GET', uri, headers: headers);
          if (request is MultipartRequest) {
            request.fields['f'] = 'v';
          }
          await request.get(uri: uri);
        }
      });

      test('timeoutThreshold should be inherited by all requests', () async {
        Duration tt = new Duration(seconds: 1);
        Client client = new Client()..timeoutThreshold = tt;
        expect(client.timeoutThreshold, equals(tt));
        for (var request in createAllRequestTypes(client)) {
          expect(request.timeoutThreshold, equals(tt));
        }
      });

      test('withCredentials should be inherited by all requests', () async {
        Client client = new Client()..withCredentials = true;
        expect(client.withCredentials, isTrue);
        for (var request in createAllRequestTypes(client)) {
          Uri uri = Uri.parse('/test');
          Completer c = new Completer();
          MockTransports.http.when(uri, (FinalizedRequest request) async {
            request.withCredentials
                ? c.complete()
                : c.completeError(
                    new Exception('withCredentials should be true'));
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
        Client client = new Client();
        client.autoRetry
          ..backOff = const RetryBackOff.fixed(const Duration(seconds: 2))
          ..enabled = true
          ..forHttpMethods = ['GET']
          ..forStatusCodes = [404]
          ..forTimeouts = false
          ..maxRetries = 4
          ..test = (request, response, willRetry) async => true;

        for (var request in createAllRequestTypes(client)) {
          expect(request.autoRetry.backOff.interval,
              equals(client.autoRetry.backOff.interval));
          expect(request.autoRetry.backOff.method,
              equals(client.autoRetry.backOff.method));
          expect(request.autoRetry.enabled, equals(client.autoRetry.enabled));
          expect(request.autoRetry.forHttpMethods,
              equals(client.autoRetry.forHttpMethods));
          expect(request.autoRetry.forStatusCodes,
              equals(client.autoRetry.forStatusCodes));
          expect(request.autoRetry.forTimeouts,
              equals(client.autoRetry.forTimeouts));
          expect(request.autoRetry.maxRetries,
              equals(client.autoRetry.maxRetries));
          expect(request.autoRetry.test, equals(client.autoRetry.test));
        }
      });

      test('addInterceptor() single interceptor (request only)', () async {
        Client client = new Client()..addInterceptor(new ReqInt());
        for (BaseRequest request in createAllRequestTypes(client)) {
          Uri uri = Uri.parse('/test');
          MockTransports.http
              .expect('GET', uri, headers: {'x-intercepted': 'true'});
          if (request is MultipartRequest) {
            request.fields['f'] = 'v';
          }
          await request.get(uri: uri);
        }
      });

      test('addInterceptor() single interceptor (response only)', () async {
        Client client = new Client()..addInterceptor(new RespInt());
        for (BaseRequest request in createAllRequestTypes(client)) {
          Uri uri = Uri.parse('/test');
          MockTransports.http.expect('GET', uri);
          if (request is MultipartRequest) {
            request.fields['f'] = 'v';
          }
          Response response = await request.get(uri: uri);
          expect(response.headers, containsPair('x-intercepted', 'true'));
        }
      });

      test('addInterceptor() single interceptor', () async {
        Client client = new Client()..addInterceptor(new ReqRespInt());
        for (BaseRequest request in createAllRequestTypes(client)) {
          Uri uri = Uri.parse('/test');
          MockTransports.http
              .expect('GET', uri, headers: {'x-intercepted': 'true'});
          if (request is MultipartRequest) {
            request.fields['f'] = 'v';
          }
          Response response = await request.get(uri: uri);
          expect(response.headers, containsPair('x-intercepted', 'true'));
        }
      });

      test('addInterceptor() multiple interceptors', () async {
        Client client = new Client()
          ..addInterceptor(new ReqRespInt())
          ..addInterceptor(new AsyncInt());
        for (BaseRequest request in createAllRequestTypes(client)) {
          Uri uri = Uri.parse('/test');
          Uri augmentedUri =
              uri.replace(queryParameters: {'interceptor': 'asyncint'});
          MockTransports.http
              .expect('GET', augmentedUri, headers: {'x-intercepted': 'true'});
          if (request is MultipartRequest) {
            request.fields['f'] = 'v';
          }
          Response response = await request.get(uri: uri);
          expect(response.headers, containsPair('x-intercepted', 'true'));
          expect(response.headers, containsPair('x-interceptor', 'asyncint'));
        }
      });

      test('close()', () async {
        Client client = new Client();
        Future future = client.newRequest().get(uri: Uri.parse('/test'));
        client.close();
        expect(future, throws);
      });
    });
  });
}
