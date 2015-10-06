library w_transport.test.integration.http.json_request.suite;

import 'dart:convert';

import 'package:http_parser/http_parser.dart';
import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';

import 'package:w_transport/src/http/utils.dart' as http_utils;

import '../integration_config.dart';

void runJsonRequestSuite(HttpIntegrationConfig config) {
  group('JsonRequest', () {
    test('contentLength should be set automatically', () async {
      JsonRequest emptyRequest = new JsonRequest();
      Response response =
          await emptyRequest.post(uri: config.reflectEndpointUri);
      int contentLength =
          int.parse(response.body.asJson()['headers']['content-length']);
      expect(contentLength, equals(0),
          reason: 'Empty JSON request\'s content-length should be 0.');

      JsonRequest nonEmptyRequest = new JsonRequest()
        ..uri = config.reflectEndpointUri
        ..body = {'field1': 'value1', 'field2': 'value2'};
      response = await nonEmptyRequest.post();
      contentLength =
          int.parse(response.body.asJson()['headers']['content-length']);
      expect(contentLength, greaterThan(0),
          reason:
              'Non-empty JSON request\'s content-length should be greater than 0.');
    });

    test('content-type should be set automatically', () async {
      JsonRequest request = new JsonRequest()
        ..uri = config.reflectEndpointUri
        ..body = {'field1': 'value1', 'field2': 'value2'};
      Response response = await request.post();
      MediaType contentType = new MediaType.parse(
          response.body.asJson()['headers']['content-type']);
      expect(contentType.mimeType, equals('application/json'));
    });

    test('UTF8', () async {
      JsonRequest request = new JsonRequest()
        ..uri = config.echoEndpointUri
        ..encoding = UTF8
        ..body = {'field1': 'value1', 'field2': 'ç®å'};
      Response response = await request.post();
      expect(response.encoding.name, equals(UTF8.name));
      expect(response.body.asJson(), containsPair('field1', 'value1'));
      expect(response.body.asJson(), containsPair('field2', 'ç®å'));
    });

    test('LATIN1', () async {
      JsonRequest request = new JsonRequest()
        ..uri = config.echoEndpointUri
        ..encoding = LATIN1
        ..body = {'field1': 'value1', 'field2': 'ç®å'};
      Response response = await request.post();
      expect(response.encoding.name, equals(LATIN1.name));
      expect(response.body.asJson(), containsPair('field1', 'value1'));
      expect(response.body.asJson(), containsPair('field2', 'ç®å'));
    });

    test('ASCII', () async {
      JsonRequest request = new JsonRequest()
        ..uri = config.echoEndpointUri
        ..encoding = ASCII
        ..body = {'field1': 'value1', 'field2': 'value2'};
      Response response = await request.post();
      expect(response.encoding.name, equals(ASCII.name));
      expect(response.body.asJson(), containsPair('field1', 'value1'));
      expect(response.body.asJson(), containsPair('field2', 'value2'));
    });
  });
}
