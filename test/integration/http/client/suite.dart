library w_transport.test.integration.http.client.suite;

import 'dart:async';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';

import '../integration_config.dart';

void runClientSuite(HttpIntegrationConfig config) {
  group('Client', () {
    test('newFormRequest()', () async {
      Client client = new Client();
      FormRequest request = client.newFormRequest();
      await _testRequest(request, config);
      client.close();
    });

    test('newJsonRequest()', () async {
      Client client = new Client();
      JsonRequest request = client.newJsonRequest();
      await _testRequest(request, config);
      client.close();
    });

    test('newMultipartRequest()', () async {
      Client client = new Client();
      MultipartRequest request = client.newMultipartRequest();
      request.fields['key'] = 'value';
      await _testRequest(request, config);
      client.close();
    });

    test('newRequest()', () async {
      Client client = new Client();
      Request request = client.newRequest();
      await _testRequest(request, config);
      client.close();
    });

    test('newStreamedRequest()', () async {
      Client client = new Client();
      StreamedRequest request = client.newStreamedRequest();
      await _testRequest(request, config);
      client.close();
    });

    test('should support multiple concurrent requests', () async {
      Client client = new Client();
      List<Future> requests = [
        client.newFormRequest().post(uri: config.reflectEndpointUri),
        client.newJsonRequest().put(uri: config.reflectEndpointUri),
        (client.newMultipartRequest()..fields['f'] = 'v')
            .patch(uri: config.reflectEndpointUri),
        client.newRequest().get(uri: config.reflectEndpointUri),
        client.newStreamedRequest().delete(uri: config.reflectEndpointUri),
        client.newRequest().send('OPTIONS', uri: config.reflectEndpointUri),
      ];
      await Future.wait(requests);
    });

    test('close() should prevent new requests from being created', () async {
      Client client = new Client();
      client.close();
      expect(() {
        client.newRequest();
      }, throwsStateError);
    });

    test('close() should abort all in-flight requests', () async {
      Client client = new Client();

      // We will let this request finish before closing the client.
      Request willComplete = client.newRequest();
      await willComplete.get(uri: config.pingEndpointUri);

      // This request should be canceled before it times out.
      Request willNotComplete = client.newRequest();
      Future willThrow = willNotComplete.get(uri: config.timeoutEndpointUri);

      // Closing the client should not affect the completed request, but should
      // abort the pending request.
      client.close();

      expect(willThrow, throwsA(new isInstanceOf<RequestException>()));
    });
  });
}

_testRequest(BaseRequest request, HttpIntegrationConfig config) async {
  request.uri = config.reflectEndpointUri;
  request.headers = {'x-custom': 'value', 'x-tokens': 'token1, token2'};
  Response response = await request.get();
  expect(response.body.asJson()['method'], equals('GET'));
  expect(response.body.asJson()['headers'], containsPair('x-custom', 'value'));
  expect(response.body.asJson()['headers'],
      containsPair('x-tokens', 'token1, token2'));
}
