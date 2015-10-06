library w_transport.test.integration.http.http_static.suite;

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';

import '../integration_config.dart';

void runHttpStaticSuite(HttpIntegrationConfig config) {
  group('Http static methods', () {

    var headers = {
      'authorization': 'test',
      'x-custom': 'value',
      'x-tokens': 'token1, token2'
    };

    test('DELETE request', () async {
      Response response = await Http.delete(config.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('DELETE'));
    });

    test('DELETE request with headers', () async {
      Response response = await Http.delete(config.reflectEndpointUri, headers: new Map.from(headers));
      expect(response.status, equals(200));

      var json = response.body.asJson();
      expect(json['method'], equals('DELETE'));
      expect(json['headers'], containsPair('authorization', headers['authorization']));
      expect(json['headers'], containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('GET request', () async {
      Response response = await Http.get(config.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('GET'));
    });

    test('GET request with headers', () async {
      Response response = await Http.get(config.reflectEndpointUri, headers: new Map.from(headers));
      expect(response.status, equals(200));

      var json = response.body.asJson();
      expect(json['method'], equals('GET'));
      expect(json['headers'],
      containsPair('authorization', headers['authorization']));
      expect(json['headers'],
      containsPair('x-custom', headers['x-custom']));
      expect(
          json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('HEAD request', () async {
      Response response = await Http.head(config.reflectEndpointUri);
      expect(response.status, equals(200));
    });

    test('HEAD request with headers', () async {
      Response response = await Http.head(config.reflectEndpointUri, headers: new Map.from(headers));
      expect(response.status, equals(200));
    });

    test('OPTIONS request', () async {
      Response response = await Http.options(config.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('OPTIONS'));
    });

    test('OPTIONS request with headers', () async {
      Response response = await Http.options(config.reflectEndpointUri, headers: new Map.from(headers));
      expect(response.status, equals(200));

      var json = response.body.asJson();
      expect(json['method'], equals('OPTIONS'));
      expect(json['headers'],
      containsPair('authorization', headers['authorization']));
      expect(json['headers'],
      containsPair('x-custom', headers['x-custom']));
      expect(
          json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('PATCH request', () async {
      Response response = await Http.patch(config.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('PATCH'));
    });

    test('PATCH request with headers', () async {
      Response response = await Http.patch(config.reflectEndpointUri, headers: new Map.from(headers));
      expect(response.status, equals(200));

      var json = response.body.asJson();
      expect(json['method'], equals('PATCH'));
      expect(json['headers'],
      containsPair('authorization', headers['authorization']));
      expect(json['headers'],
      containsPair('x-custom', headers['x-custom']));
      expect(
          json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('PATCH request with body', () async {
      Response response = await Http.patch(config.echoEndpointUri, body: 'body');
      expect(response.body.asString(), equals('body'));
    });

    test('POST request', () async {
      Response response = await Http.post(config.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('POST'));
    });

    test('POST request with headers', () async {
      Response response = await Http.post(config.reflectEndpointUri, headers: new Map.from(headers));
      expect(response.status, equals(200));

      var json = response.body.asJson();
      expect(json['method'], equals('POST'));
      expect(json['headers'],
      containsPair('authorization', headers['authorization']));
      expect(json['headers'],
      containsPair('x-custom', headers['x-custom']));
      expect(
          json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('POST request with body', () async {
      Response response = await Http.post(config.echoEndpointUri, body: 'body');
      expect(response.body.asString(), equals('body'));
    });

    test('PUT request', () async {
      Response response = await Http.put(config.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('PUT'));
    });

    test('PUT request with headers', () async {
      Response response = await Http.put(config.reflectEndpointUri, headers: new Map.from(headers));
      expect(response.status, equals(200));

      var json = response.body.asJson();
      expect(json['method'], equals('PUT'));
      expect(json['headers'],
      containsPair('authorization', headers['authorization']));
      expect(json['headers'],
      containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('PUT request with body', () async {
      Response response = await Http.put(config.echoEndpointUri, body: 'body');
      expect(response.body.asString(), equals('body'));
    });

    test('custom HTTP method request', () async {
      Response response = await Http.send('COPY', config.reflectEndpointUri);
      expect(response.status, equals(200));
      expect(response.body.asJson()['method'], equals('COPY'));
    });

    test('custom HTTP method request with headers', () async {
      Response response = await Http.send('COPY', config.reflectEndpointUri, headers: new Map.from(headers));
      expect(response.status, equals(200));

      var json = response.body.asJson();
      expect(json['method'], equals('COPY'));
      expect(json['headers'],
      containsPair('authorization', headers['authorization']));
      expect(json['headers'],
      containsPair('x-custom', headers['x-custom']));
      expect(json['headers'], containsPair('x-tokens', headers['x-tokens']));
    });

    test('custom HTTP method request with body', () async {
      Response response = await Http.send('COPY', config.echoEndpointUri, body: 'body');
      expect(response.body.asString(), equals('body'));
    });
  });
}