library w_transport.test.integration.http.form_request.suite;

import 'dart:convert';

import 'package:http_parser/http_parser.dart';
import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';

import 'package:w_transport/src/http/utils.dart' as http_utils;

import '../integration_config.dart';

void runFormRequestSuite(HttpIntegrationConfig config) {
  group('FormRequest', () {
    test('content-length should be set automatically', () async {
      // Empty request.
      FormRequest emptyRequest = new FormRequest();
      Response response =
          await emptyRequest.post(uri: config.reflectEndpointUri);
      int contentLength =
          int.parse(response.body.asJson()['headers']['content-length']);
      expect(contentLength, equals(0),
          reason: 'Empty form request\'s content-length should be 0.');

      // Non-empty request.
      FormRequest nonEmptyRequest = new FormRequest()
        ..uri = config.reflectEndpointUri
        ..fields['field1'] = 'value1'
        ..fields['field2'] = 'value2';
      response = await nonEmptyRequest.post();
      contentLength =
          int.parse(response.body.asJson()['headers']['content-length']);
      expect(contentLength, greaterThan(0),
          reason:
              'Non-empty form request\'s content-length should be greater than 0.');
    });

    test('content-type should be set automatically', () async {
      FormRequest request = new FormRequest()
        ..uri = config.reflectEndpointUri
        ..fields['field'] = 'value';
      Response response = await request.post();
      MediaType contentType = new MediaType.parse(
          response.body.asJson()['headers']['content-type']);
      expect(contentType.mimeType, equals('application/x-www-form-urlencoded'));
    });

    test('UTF8', () async {
      FormRequest request = new FormRequest()
        ..uri = config.echoEndpointUri
        ..encoding = UTF8
        ..fields['field1'] = 'value1'
        ..fields['field2'] = 'ç®å';
      Response response = await request.post();
      expect(response.encoding.name, equals(UTF8.name));
      Map echo = http_utils.queryToMap(response.body.asString(),
          encoding: response.encoding);
      expect(echo, containsPair('field1', 'value1'));
      expect(echo, containsPair('field2', 'ç®å'));
    });

    test('LATIN1', () async {
      FormRequest request = new FormRequest()
        ..uri = config.echoEndpointUri
        ..encoding = LATIN1
        ..fields['field1'] = 'value1'
        ..fields['field2'] = 'ç®å';
      Response response = await request.post();
      expect(response.encoding.name, equals(LATIN1.name));
      Map echo = http_utils.queryToMap(response.body.asString(),
          encoding: response.encoding);
      expect(echo, containsPair('field1', 'value1'));
      expect(echo, containsPair('field2', 'ç®å'));
    });

    test('ASCII', () async {
      FormRequest request = new FormRequest()
        ..uri = config.echoEndpointUri
        ..encoding = ASCII
        ..fields['field1'] = 'value1'
        ..fields['field2'] = 'value2';
      Response response = await request.post();
      expect(response.encoding.name, equals(ASCII.name));
      Map echo = http_utils.queryToMap(response.body.asString(),
          encoding: response.encoding);
      expect(echo, containsPair('field1', 'value1'));
      expect(echo, containsPair('field2', 'value2'));
    });
  });
}
