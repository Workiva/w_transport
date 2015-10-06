library w_transport.test.integration.http.streamed_request.suite;

import 'dart:async';
import 'dart:convert';

import 'package:http_parser/http_parser.dart';
import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';

import 'package:w_transport/src/http/utils.dart' as http_utils;

import '../integration_config.dart';

void runStreamedRequestSuite(HttpIntegrationConfig config) {
  group('StreamedRequest', () {
    test('contentLength should NOT be set automatically', () async {
      StreamedRequest emptyRequest = new StreamedRequest()
        ..uri = config.reflectEndpointUri
        ..contentLength = 0;
      Response response =
          await emptyRequest.post(uri: config.reflectEndpointUri);
      var contentLength =
          int.parse(response.body.asJson()['headers']['content-length']);
      expect(contentLength, equals(0),
          reason:
              'Empty streamed plain-text request\'s content-length should be 0.');

      List<List<int>> chunks = [
        UTF8.encode('chunk1'),
        UTF8.encode('chunk2'),
        UTF8.encode('chunk3')
      ];
      int size = 0;
      chunks.forEach((chunk) {
        size += chunk.length;
      });
      StreamedRequest nonEmptyRequest = new StreamedRequest()
        ..uri = config.reflectEndpointUri
        ..body = new Stream.fromIterable(chunks)
        ..contentLength = size;
      response = await nonEmptyRequest.post();
      contentLength =
          int.parse(response.body.asJson()['headers']['content-length']);
      expect(contentLength, equals(size),
          reason:
              'Non-empty streamed plain-text request\'s content-length should be greater than 0.');
    });

    test('content-type should be set automatically', () async {
      StreamedRequest request = new StreamedRequest()
        ..uri = config.reflectEndpointUri
        ..body = new Stream.fromIterable([])
        ..contentLength = 0;
      Response response = await request.post();
      MediaType contentType = new MediaType.parse(
          response.body.asJson()['headers']['content-type']);
      expect(contentType.mimeType, equals('text/plain'));
    });

    test('UTF8', () async {
      StreamedRequest request = new StreamedRequest()
        ..uri = config.echoEndpointUri
        ..encoding = UTF8
        ..body = new Stream.fromIterable([UTF8.encode('dataç®å')]);
      Response response = await request.post();
      expect(response.encoding.name, equals(UTF8.name));
      expect(response.body.asString(), equals('dataç®å'));
    });

    test('LATIN1', () async {
      StreamedRequest request = new StreamedRequest()
        ..uri = config.echoEndpointUri
        ..encoding = LATIN1
        ..body = new Stream.fromIterable([LATIN1.encode('dataç®å')]);
      Response response = await request.post();
      expect(response.encoding.name, equals(LATIN1.name));
      expect(response.body.asString(), equals('dataç®å'));
    });

    test('ASCII', () async {
      StreamedRequest request = new StreamedRequest()
        ..uri = config.echoEndpointUri
        ..encoding = ASCII
        ..body = new Stream.fromIterable([ASCII.encode('data')]);
      Response response = await request.post();
      expect(response.encoding.name, equals(ASCII.name));
      expect(response.body.asString(), equals('data'));
    });
  });
}
