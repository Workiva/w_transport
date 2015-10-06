library w_transport.test.integration.http.common_request.suite;

import 'dart:async';
import 'dart:convert';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';

import '../integration_config.dart';

void runCommonRequestSuite(HttpIntegrationConfig config) {
  group('Common Request API', () {
    _runCommonRequestSuiteFor(config, 'FormRequest', ({bool withBody: false}) {
      if (!withBody) return new FormRequest();
      return new FormRequest()..fields['field'] = 'value';
    });
    _runCommonRequestSuiteFor(config, 'JsonRequest', ({bool withBody: false}) {
      if (!withBody) return new JsonRequest();
      return new JsonRequest()
        ..body = [
          {'field': 'value'}
        ];
    });
    _runCommonRequestSuiteFor(config, 'MultipartRequest', ({bool withBody}) {
      // Multipart requests can't be empty.
      return new MultipartRequest()..fields['field'] = 'value';
    });
    _runCommonRequestSuiteFor(config, 'Request', ({bool withBody: false}) {
      if (!withBody) return new Request();
      return new Request()..body = 'body';
    });
    _runCommonRequestSuiteFor(config, 'StreamedRequest', (
        {bool withBody: false}) {
      if (!withBody) return new StreamedRequest();
      return new StreamedRequest()
        ..body = new Stream.fromIterable([UTF8.encode('bytes')])
        ..contentLength = UTF8.encode('bytes').length;
    });
  });
}

void _runCommonRequestSuiteFor(HttpIntegrationConfig config, String name,
    BaseRequest requestFactory({bool withBody})) {
  group(name, () {
    var headers = {
      'authorization': 'test',
      'x-custom': 'value',
      'x-tokens': 'token1, token2'
    };

    test('"done" should complete when the request succeeds', () async {
      BaseRequest request = requestFactory();
      request.post(uri: config.reflectEndpointUri);
      await request.done;
    });

    test('"done" should complete when the request is canceled', () async {
      BaseRequest request = requestFactory();

      try {
        Future future = request.post(uri: config.timeoutEndpointUri);
        await new Future.delayed(new Duration(milliseconds: 5));
        request.abort();
        await future;
      } on RequestException {}

      await request.done;
    });

    test('"done" should complete when the request fails', () async {
      BaseRequest request = requestFactory();
      try {
        await request.post(uri: config.fourOhFourEndpointUri);
      } on RequestException {}
      await request.done;
    });

    test('DELETE request', () async {
      BaseRequest request = requestFactory();
      Response response = await request.delete(uri: config.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('DELETE'));
    });

    test('DELETE request with headers', () async {
      BaseRequest request = requestFactory()
        ..uri = config.reflectEndpointUri
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
      Response response = await request.get(uri: config.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('GET'));
    });

    test('GET request with headers', () async {
      BaseRequest request = requestFactory()
        ..uri = config.reflectEndpointUri
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
      Response response = await request.head(uri: config.reflectEndpointUri);
      expect(response.status, equals(200));
    });

    test('HEAD request with headers', () async {
      BaseRequest request = requestFactory()
        ..uri = config.reflectEndpointUri
        ..headers = new Map.from(headers);
      Response response = await request.head();
      expect(response.status, equals(200));
    });

    test('OPTIONS request', () async {
      BaseRequest request = requestFactory();
      Response response = await request.options(uri: config.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('OPTIONS'));
    });

    test('OPTIONS request with headers', () async {
      BaseRequest request = requestFactory()
        ..uri = config.reflectEndpointUri
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
      Response response = await request.patch(uri: config.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('PATCH'));
    });

    test('PATCH request with headers', () async {
      BaseRequest request = requestFactory()
        ..uri = config.reflectEndpointUri
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
      Response response = await request.post(uri: config.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('POST'));
    });

    test('POST request with headers', () async {
      BaseRequest request = requestFactory()
        ..uri = config.reflectEndpointUri
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
      Response response = await request.put(uri: config.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('PUT'));
    });

    test('PUT request with headers', () async {
      BaseRequest request = requestFactory()
        ..uri = config.reflectEndpointUri
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
        ..uri = config.reflectEndpointUri;
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
      BaseRequest request = requestFactory()..uri = config.downloadEndpointUri;
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
        ..uri = config.fourOhFourEndpointUri;
      expect(
          request.get(),
          throwsA(predicate((exception) {
            return exception != null &&
                exception is RequestException &&
                exception.method == 'GET' &&
                exception.uri == config.fourOhFourEndpointUri;
          }, 'throws a RequestException')));
    });

    test('request cancellation prior to dispatch should cause request to fail',
        () async {
      BaseRequest request = requestFactory()..uri = config.hostUri;
      request.abort();
      expect(request.get(), throwsA(predicate((exception) {
        return exception is RequestException &&
            exception.toString().contains('canceled');
      })));
    });

    test(
        'request cancellation after dispatch but prior to resolution should cause request to fail',
        () async {
      BaseRequest request = requestFactory()..uri = config.timeoutEndpointUri;
      Future future = request.get();

      // Wait a sufficient amount of time to allow the request to open.
      // Since we're hitting a timeout endpoint, it shouldn't complete.
      await new Future.delayed(new Duration(seconds: 1));

      // Abort the request now that it is in flight.
      request.abort();
      expect(future, throwsA(new isInstanceOf<RequestException>()));
    });
  });
}