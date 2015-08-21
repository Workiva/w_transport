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

library w_transport.test.integration.w_http_common_tests;

import 'dart:async';
import 'dart:convert';

import 'package:w_transport/w_transport.dart';
import 'package:test/test.dart';

import '../utils.dart';

/// These are HTTP integration tests that should work from client or server.
/// These will not pass if run on their own!
void run(String usage) {
  group('WHttp ($usage) static methods', () {
    Uri uri;

    setUp(() {
      uri = Uri.parse('http://localhost:8024/test/http/reflect');
    });

    test('should be able to send a DELETE request', () async {
      WResponse response = await WHttp.delete(uri);
      expect(response.status, equals(200));
      Map data = JSON.decode(await response.asText());
      expect(data['method'], equals('DELETE'));
    });

    test('should be able to send a GET request', () async {
      WResponse response = await WHttp.get(uri);
      expect(response.status, equals(200));
      Map data = JSON.decode(await response.asText());
      expect(data['method'], equals('GET'));
    });

    test('should be able to send a HEAD request', () async {
      WResponse response = await WHttp.head(uri);
      expect(response.status, equals(200));
    });

    test('should be able to send a OPTIONS request', () async {
      WResponse response = await WHttp.options(uri);
      expect(response.status, equals(200));
      Map data = JSON.decode(await response.asText());
      expect(data['method'], equals('OPTIONS'));
    });

    test('should be able to send a PATCH request', () async {
      WResponse response = await WHttp.patch(uri);
      expect(response.status, equals(200));
      Map data = JSON.decode(await response.asText());
      expect(data['method'], equals('PATCH'));
    });

    test('should be able to send a POST request', () async {
      WResponse response = await WHttp.post(uri);
      expect(response.status, equals(200));
      Map data = JSON.decode(await response.asText());
      expect(data['method'], equals('POST'));
    });

    test('should be able to send a PUT request', () async {
      WResponse response = await WHttp.put(uri);
      expect(response.status, equals(200));
      Map data = JSON.decode(await response.asText());
      expect(data['method'], equals('PUT'));
    });
  });

  group('WHttp ($usage)', () {
    WHttp http;

    setUp(() {
      http = new WHttp();
    });

    test('should be able to create new requests', () async {
      expect(http.newRequest() is WRequest, isTrue);
      expect(http.newRequest() != http.newRequest(), isTrue);
    });

    test('should be able to close the client', () {
      http.close();
    });

    test('should throw if new request created after client is closed', () {
      http.close();
      expect(() {
        http.newRequest();
      }, throwsStateError);
    });
  });

  group('WHttpException ($usage)', () {
    test('should be thrown on failed requests', () async {
      Uri uri = Uri.parse('http://localhost:8024/test/http/404');
      WHttpException exception;
      try {
        await WHttp.get(uri);
      } on WHttpException catch (e) {
        exception = e;
      }
      expect(exception, isNotNull);
      expect(exception.method, equals('GET'));
      expect(exception.uri, equals(uri));
      expect(exception.toString().contains('WHttpException: '), isTrue);
    });
  });

  group('WRequest ($usage)', () {
    WRequest request;

    setUp(() {
      request = new WRequest()..uri = Uri.parse('http://localhost:8024');
    });

    test('should successfully send an HTTP request', httpTest((store) async {
      request.path = '/test/http/ping';
      var response = store(await request.get());
      expect(response.status, equals(200));
    }));

    test('should make the method property available', () async {
      request.path = '/test/http/ping';
      await request.get();
      expect(request.method, equals('GET'));
    });

    test('should be able to supply a URI and data when sending', () async {
      WResponse response = await request.post(
          request.uri.replace(path: '/test/http/reflect'), 'data');
      expect(response.status, equals(200));
      Map data = JSON.decode(await response.asText());
      expect(data['body'], equals('data'));
    });

    test('should throw if no URI supplied', () async {
      Error error;
      try {
        await new WRequest().get();
      } catch (e) {
        error = e;
      }
      expect(error, isNotNull);
      expect(error is StateError, isTrue);
    });

    group('request methods', () {
      setUp(() {
        request.path = '/test/http/reflect';
      });

      test('should support a DELETE method', httpTest((store) async {
        var response = store(await request.delete());
        expect(response.status, equals(200));
        expect(
            JSON.decode(await response.asText())['method'], equals('DELETE'));
      }));

      test('should support a GET method', httpTest((store) async {
        var response = store(await request.get());
        expect(response.status, equals(200));
        expect(JSON.decode(await response.asText())['method'], equals('GET'));
      }));

      test('should support a OPTIONS method', httpTest((store) async {
        var response = store(await request.options());
        expect(response.status, equals(200));
        expect(
            JSON.decode(await response.asText())['method'], equals('OPTIONS'));
      }));

      test('should support a PATCH method', httpTest((store) async {
        var response = store(await request.patch());
        expect(response.status, equals(200));
        expect(JSON.decode(await response.asText())['method'], equals('PATCH'));
      }));

      test('should support a POST method', httpTest((store) async {
        var response = store(await request.post());
        expect(response.status, equals(200));
        expect(JSON.decode(await response.asText())['method'], equals('POST'));
      }));

      test('should support a PUT method', httpTest((store) async {
        var response = store(await request.put());
        expect(response.status, equals(200));
        expect(JSON.decode(await response.asText())['method'], equals('PUT'));
      }));
    });

    group('request data', () {
      setUp(() {
        request.path = '/test/http/reflect';
        request.data = 'data';
      });

      test('should be supported on a PATCH request', httpTest((store) async {
        var response = store(await request.patch());
        expect(response.status, equals(200));
        expect(JSON.decode(await response.asText())['body'], equals('data'));
      }));

      test('should be supported on a POST request', httpTest((store) async {
        var response = store(await request.post());
        expect(response.status, equals(200));
        expect(JSON.decode(await response.asText())['body'], equals('data'));
      }));

      test('should be supported on a PUT request', httpTest((store) async {
        var response = store(await request.put());
        expect(response.status, equals(200));
        expect(JSON.decode(await response.asText())['body'], equals('data'));
      }));
    });

    group('request headers', () {
      setUp(() {
        request.path = '/test/http/reflect';
        request.headers = {
          'content-type': 'application/json',
          'x-tokens': 'token1, token2',
        };
        request.headers['authorization'] = 'test';
      });

      test('should be supported on a DELETE request', httpTest((store) async {
        var response = store(await request.delete());
        expect(response.status, equals(200));
        Map responseJson = JSON.decode(await response.asText());
        expect(responseJson['headers']['content-type'],
            equals('application/json'));
        expect(responseJson['headers']['authorization'], equals('test'));
        expect(responseJson['headers']['x-tokens'], equals('token1, token2'));
      }));

      test('should be supported on a GET request', httpTest((store) async {
        var response = store(await request.get());
        expect(response.status, equals(200));
        Map responseJson = JSON.decode(await response.asText());
        expect(responseJson['headers']['content-type'],
            equals('application/json'));
        expect(responseJson['headers']['authorization'], equals('test'));
        expect(responseJson['headers']['x-tokens'], equals('token1, token2'));
      }));

      test('should be supported on a OPTIONS request', httpTest((store) async {
        var response = store(await request.options());
        expect(response.status, equals(200));
        Map responseJson = JSON.decode(await response.asText());
        expect(responseJson['headers']['content-type'],
            equals('application/json'));
        expect(responseJson['headers']['authorization'], equals('test'));
        expect(responseJson['headers']['x-tokens'], equals('token1, token2'));
      }));

      test('should be supported on a PATCH request', httpTest((store) async {
        var response = store(await request.patch());
        expect(response.status, equals(200));
        Map responseJson = JSON.decode(await response.asText());
        expect(responseJson['headers']['content-type'],
            equals('application/json'));
        expect(responseJson['headers']['authorization'], equals('test'));
        expect(responseJson['headers']['x-tokens'], equals('token1, token2'));
      }));

      test('should be supported on a POST request', httpTest((store) async {
        var response = store(await request.post());
        expect(response.status, equals(200));
        Map responseJson = JSON.decode(await response.asText());
        expect(responseJson['headers']['content-type'],
            equals('application/json'));
        expect(responseJson['headers']['authorization'], equals('test'));
        expect(responseJson['headers']['x-tokens'], equals('token1, token2'));
      }));

      test('should be supported on a PUT request', httpTest((store) async {
        var response = store(await request.put());
        expect(response.status, equals(200));
        Map responseJson = JSON.decode(await response.asText());
        expect(responseJson['headers']['content-type'],
            equals('application/json'));
        expect(responseJson['headers']['authorization'], equals('test'));
        expect(responseJson['headers']['x-tokens'], equals('token1, token2'));
      }));
    });

    group('request cancellation', () {
      test('should be supported', () async {
        try {
          await request.get();
        } catch (e) {}
        request.abort();
      });

      test('should cause request to fail', () async {
        expect(
            () async {
              Future future = request.get();
              request.abort();
              try {
                await future;
              } catch (e) {
                expect(e.toString().contains('canceled'), isTrue);
                throw e;
              }
            }(),
            throwsA(new isInstanceOf<WHttpException>()));
      });

      test('should allow a custom exception', () async {
        expect(
            () async {
              Future future = request.get();
              request.abort(new Exception('Custom cancellation.'));
              try {
                await future;
              } catch (e) {
                expect(e.toString().contains('Custom cancellation'), isTrue);
                throw e;
              }
            }(),
            throwsA(new isInstanceOf<WHttpException>()));
      });
    });
  });

  group('WResponse ($usage)', () {
    WResponse response;

    setUp(() async {
      response =
          await WHttp.get(Uri.parse('http://localhost:8024/test/http/reflect'));
    });

    test('data should be available as a Future', () async {
      Object data = await response.asFuture();
      expect(data is List<int> || data is String, isTrue);
    });

    test('data should be available decoded to text', () async {
      String text = await response.asText();
      expect(text.isNotEmpty, isTrue);
    });

    test('data should be available as a Stream', () async {
      expect((await response.asStream().length) > 0, isTrue);
    });

    test('should cache data to allow multiple accesses', () async {
      Object data = await response.asFuture();
      expect(data is List<int> || data is String, isTrue);
      String text = await response.asText();
      expect(text.isNotEmpty, isTrue);
      expect((await response.asStream().length) > 0, isTrue);
    });

    test('should be able to update the data source', () async {
      response.update(new Stream.fromIterable([UTF8.encode('updated1')]));
      expect(await response.asText(), equals('updated1'));
      response.update('updated2');
      expect(await response.asText(), equals('updated2'));
    });
  });
}
