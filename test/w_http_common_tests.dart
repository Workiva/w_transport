library w_transport.integration.w_http_common_tests;

import 'dart:async';
import 'dart:convert';

import 'package:test/test.dart';

import './w_http_utils.dart';


/// These are HTTP integration tests that should work from client or server.
/// These will not pass if run on their own!
void run(String usage, dynamic newRequest(), Future<String> getResponseText(resp)) {

  void setReqPath(req, String path) {
    req.uri = Uri.parse('http://localhost:8024').replace(path: path);
  }

  group('WRequest ($usage)', () {

    dynamic http;

    setUp(() {
      http = newRequest()..uri = Uri.parse('http://localhost:8024');
    });

    test('should successfully send an HTTP request', httpTest((store) async {
      setReqPath(http, '/test/http/ping');
      var response = store(await http.get());
      expect(response.status, equals(200));
    }));

    group('request methods', () {

      setUp(() {
        setReqPath(http, '/test/http/reflect');
      });

      test('should support a DELETE method', httpTest((store) async {
        var response = store(await http.delete());
        expect(response.status, equals(200));
        expect(JSON.decode(await getResponseText(response))['method'], equals('DELETE'));
      }));

      test('should support a GET method', httpTest((store) async {
        var response = store(await http.get());
        expect(response.status, equals(200));
        expect(JSON.decode(await getResponseText(response))['method'], equals('GET'));
      }));

      test('should support a OPTIONS method', httpTest((store) async {
        var response = store(await http.options());
        expect(response.status, equals(200));
        expect(JSON.decode(await getResponseText(response))['method'], equals('OPTIONS'));
      }));

      test('should support a PATCH method', httpTest((store) async {
        var response = store(await http.patch());
        expect(response.status, equals(200));
        expect(JSON.decode(await getResponseText(response))['method'], equals('PATCH'));
      }));

      test('should support a POST method', httpTest((store) async {
        var response = store(await http.post());
        expect(response.status, equals(200));
        expect(JSON.decode(await getResponseText(response))['method'], equals('POST'));
      }));

      test('should support a PUT method', httpTest((store) async {
        var response = store(await http.put());
        expect(response.status, equals(200));
        expect(JSON.decode(await getResponseText(response))['method'], equals('PUT'));
      }));

    });

    group('request data', () {

      setUp(() {
        setReqPath(http, '/test/http/reflect');
        http.data = 'data';
      });

      test('should be supported on a PATCH request', httpTest((store) async {
        var response = store(await http.patch());
        expect(response.status, equals(200));
        expect(JSON.decode(await getResponseText(response))['body'], equals('data'));
      }));

      test('should be supported on a POST request', httpTest((store) async {
        var response = store(await http.post());
        expect(response.status, equals(200));
        expect(JSON.decode(await getResponseText(response))['body'], equals('data'));
      }));

      test('should be supported on a PUT request', httpTest((store) async {
        var response = store(await http.put());
        expect(response.status, equals(200));
        expect(JSON.decode(await getResponseText(response))['body'], equals('data'));
      }));

    });

    group('request headers', () {

      setUp(() {
        setReqPath(http, '/test/http/reflect');
        http.headers = {
            'content-type': 'application/json',
            'x-tokens': 'token1, token2',
        };
        http.headers['authorization'] = 'test';
      });

      test('should be supported on a DELETE request', httpTest((store) async {
        var response = store(await http.delete());
        expect(response.status, equals(200));
        Map responseJson = JSON.decode(await getResponseText(response));
        expect(responseJson['headers']['content-type'], equals('application/json'));
        expect(responseJson['headers']['authorization'], equals('test'));
        expect(responseJson['headers']['x-tokens'], equals('token1, token2'));
      }));

      test('should be supported on a GET request', httpTest((store) async {
        var response = store(await http.get());
        expect(response.status, equals(200));
        Map responseJson = JSON.decode(await getResponseText(response));
        expect(responseJson['headers']['content-type'], equals('application/json'));
        expect(responseJson['headers']['authorization'], equals('test'));
        expect(responseJson['headers']['x-tokens'], equals('token1, token2'));
      }));

      test('should be supported on a OPTIONS request', httpTest((store) async {
        var response = store(await http.options());
        expect(response.status, equals(200));
        Map responseJson = JSON.decode(await getResponseText(response));
        expect(responseJson['headers']['content-type'], equals('application/json'));
        expect(responseJson['headers']['authorization'], equals('test'));
        expect(responseJson['headers']['x-tokens'], equals('token1, token2'));
      }));

      test('should be supported on a PATCH request', httpTest((store) async {
        var response = store(await http.patch());
        expect(response.status, equals(200));
        Map responseJson = JSON.decode(await getResponseText(response));
        expect(responseJson['headers']['content-type'], equals('application/json'));
        expect(responseJson['headers']['authorization'], equals('test'));
        expect(responseJson['headers']['x-tokens'], equals('token1, token2'));
      }));

      test('should be supported on a POST request', httpTest((store) async {
        var response = store(await http.post());
        expect(response.status, equals(200));
        Map responseJson = JSON.decode(await getResponseText(response));
        expect(responseJson['headers']['content-type'], equals('application/json'));
        expect(responseJson['headers']['authorization'], equals('test'));
        expect(responseJson['headers']['x-tokens'], equals('token1, token2'));
      }));

      test('should be supported on a PUT request', httpTest((store) async {
        var response = store(await http.put());
        expect(response.status, equals(200));
        Map responseJson = JSON.decode(await getResponseText(response));
        expect(responseJson['headers']['content-type'], equals('application/json'));
        expect(responseJson['headers']['authorization'], equals('test'));
        expect(responseJson['headers']['x-tokens'], equals('token1, token2'));
      }));

    });

  });
}