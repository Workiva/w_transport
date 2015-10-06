library w_transport.test.integration.http.plain_text_request.suite;

import 'dart:convert';

import 'package:http_parser/http_parser.dart';
import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';

import 'package:w_transport/src/http/utils.dart' as http_utils;

import '../integration_config.dart';

void runPlainTextRequestSuite(HttpIntegrationConfig config) {
  group('Request', () {

    test('contentLength should be set automatically', () async {
      Request emptyRequest = new Request();
      Response response = await emptyRequest.post(uri: config.reflectEndpointUri);
      var contentLength = int.parse(response.body.asJson()['headers']['content-length']);
      expect(contentLength, equals(0), reason: 'Empty plain-text request\'s content-length should be 0.');

      Request nonEmptyRequest = new Request()
        ..uri = config.reflectEndpointUri
        ..body = 'data';
      response = await nonEmptyRequest.post();
      contentLength = int.parse(response.body.asJson()['headers']['content-length']);
      expect(contentLength, greaterThan(0), reason: 'Non-empty plain-text request\'s content-length should be greater than 0.');
    });

    test('content-type should be set automatically', () async {
      Request request = new Request()
        ..uri = config.reflectEndpointUri
        ..body = 'data';
      Response response = await request.post();
      MediaType contentType = new MediaType.parse(response.body.asJson()['headers']['content-type']);
      expect(contentType.mimeType, equals('text/plain'));
    });

    test('UTF8', () async {
      Request request = new Request()
        ..uri = config.echoEndpointUri
        ..encoding = UTF8
        ..body = 'dataç®å';
      Response response = await request.post();
      expect(response.encoding.name, equals(UTF8.name));
      expect(response.body.asString(), equals('dataç®å'));
    });

    test('LATIN1', () async {
      Request request = new Request()
        ..uri = config.echoEndpointUri
        ..encoding = LATIN1
        ..body = 'dataç®å';
      Response response = await request.post();
      expect(response.encoding.name, equals(LATIN1.name));
      expect(response.body.asString(), equals('dataç®å'));
    });

    test('ASCII', () async {
      Request request = new Request()
        ..uri = config.echoEndpointUri
        ..encoding = ASCII
        ..body = 'data';
      Response response = await request.post();
      expect(response.encoding.name, equals(ASCII.name));
      expect(response.body.asString(), equals('data'));
    });

  });
}