/*
 * Copyright 2015 Workiva Inc.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

library w_transport.test.w_http_common_tests;

import 'dart:convert';

import 'package:w_transport/w_http.dart';
import 'package:test/test.dart';

import './w_http_utils.dart';

/// These are HTTP integration tests that should work from client or server.
/// These will not pass if run on their own!
void run(String usage) {
  void setReqPath(WRequest req, String path) {
    req.uri = Uri.parse('http://localhost:8024').replace(path: path);
  }

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

    group('request methods', () {
      setUp(() {
        request.path = '/test/http/reflect';
      });

      test('should support a DELETE method', httpTest((store) async {
        var response = store(await request.delete());
        expect(response.status, equals(200));
        expect(JSON.decode(await response.text)['method'], equals('DELETE'));
      }));

      test('should support a GET method', httpTest((store) async {
        var response = store(await request.get());
        expect(response.status, equals(200));
        expect(JSON.decode(await response.text)['method'], equals('GET'));
      }));

      test('should support a OPTIONS method', httpTest((store) async {
        var response = store(await request.options());
        expect(response.status, equals(200));
        expect(JSON.decode(await response.text)['method'], equals('OPTIONS'));
      }));

      test('should support a PATCH method', httpTest((store) async {
        var response = store(await request.patch());
        expect(response.status, equals(200));
        expect(JSON.decode(await response.text)['method'], equals('PATCH'));
      }));

      test('should support a POST method', httpTest((store) async {
        var response = store(await request.post());
        expect(response.status, equals(200));
        expect(JSON.decode(await response.text)['method'], equals('POST'));
      }));

      test('should support a PUT method', httpTest((store) async {
        var response = store(await request.put());
        expect(response.status, equals(200));
        expect(JSON.decode(await response.text)['method'], equals('PUT'));
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
        expect(JSON.decode(await response.text)['body'], equals('data'));
      }));

      test('should be supported on a POST request', httpTest((store) async {
        var response = store(await request.post());
        expect(response.status, equals(200));
        expect(JSON.decode(await response.text)['body'], equals('data'));
      }));

      test('should be supported on a PUT request', httpTest((store) async {
        var response = store(await request.put());
        expect(response.status, equals(200));
        expect(JSON.decode(await response.text)['body'], equals('data'));
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
        Map responseJson = JSON.decode(await response.text);
        expect(responseJson['headers']['content-type'],
            equals('application/json'));
        expect(responseJson['headers']['authorization'], equals('test'));
        expect(responseJson['headers']['x-tokens'], equals('token1, token2'));
      }));

      test('should be supported on a GET request', httpTest((store) async {
        var response = store(await request.get());
        expect(response.status, equals(200));
        Map responseJson = JSON.decode(await response.text);
        expect(responseJson['headers']['content-type'],
            equals('application/json'));
        expect(responseJson['headers']['authorization'], equals('test'));
        expect(responseJson['headers']['x-tokens'], equals('token1, token2'));
      }));

      test('should be supported on a OPTIONS request', httpTest((store) async {
        var response = store(await request.options());
        expect(response.status, equals(200));
        Map responseJson = JSON.decode(await response.text);
        expect(responseJson['headers']['content-type'],
            equals('application/json'));
        expect(responseJson['headers']['authorization'], equals('test'));
        expect(responseJson['headers']['x-tokens'], equals('token1, token2'));
      }));

      test('should be supported on a PATCH request', httpTest((store) async {
        var response = store(await request.patch());
        expect(response.status, equals(200));
        Map responseJson = JSON.decode(await response.text);
        expect(responseJson['headers']['content-type'],
            equals('application/json'));
        expect(responseJson['headers']['authorization'], equals('test'));
        expect(responseJson['headers']['x-tokens'], equals('token1, token2'));
      }));

      test('should be supported on a POST request', httpTest((store) async {
        var response = store(await request.post());
        expect(response.status, equals(200));
        Map responseJson = JSON.decode(await response.text);
        expect(responseJson['headers']['content-type'],
            equals('application/json'));
        expect(responseJson['headers']['authorization'], equals('test'));
        expect(responseJson['headers']['x-tokens'], equals('token1, token2'));
      }));

      test('should be supported on a PUT request', httpTest((store) async {
        var response = store(await request.put());
        expect(response.status, equals(200));
        Map responseJson = JSON.decode(await response.text);
        expect(responseJson['headers']['content-type'],
            equals('application/json'));
        expect(responseJson['headers']['authorization'], equals('test'));
        expect(responseJson['headers']['x-tokens'], equals('token1, token2'));
      }));
    });
  });
}
