@TestOn('browser')
library w_transport.test.integration.http.multipart_request.browser_test;

import 'dart:html';
import 'dart:convert';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_browser.dart';

import 'package:w_transport/src/http/browser/multipart_request.dart';

import '../../../naming.dart';
import '../integration_config.dart';
import 'suite.dart';

void main() {
  var config = new HttpIntegrationConfig.browser();
  group(integrationHttpBrowser, () {
    setUp(() {
      configureWTransportForBrowser();
    });

    runMultipartRequestSuite(config);

    group('MultipartRequest', () {
      test('underlying HttpRequest configuration', () async {
        MultipartRequest request = new MultipartRequest()
          ..uri = config.reflectEndpointUri
          ..fields['field'] = 'value';
        request.configure((HttpRequest xhr) async {
          xhr.setRequestHeader('x-configured', 'true');
        });
        Response response = await request.get();
        expect(
            response.body.asJson()['headers']['x-configured'], equals('true'));
      });

      group('withCredentials', () {
        test('set to true (MultipartRequest)', () async {
          MultipartRequest request = new MultipartRequest()
            ..uri = config.pingEndpointUri
            ..fields['field'] = 'value'
            ..withCredentials = true;
          request.configure((HttpRequest xhr) async {
            expect(xhr.withCredentials, isTrue);
          });
          await request.get();
        });

        test('set to false (MultipartRequest)', () async {
          MultipartRequest request = new MultipartRequest()
            ..uri = config.pingEndpointUri
            ..fields['field'] = 'value'
            ..withCredentials = false;
          request.configure((HttpRequest xhr) async {
            expect(xhr.withCredentials, isFalse);
          });
          await request.get();
        });
      });

      test('withClient() ctor', () {
        expect(new BrowserMultipartRequest.withClient(null),
            new isInstanceOf<MultipartRequest>());
      });

      test('setting content-length is unsupported', () {
        MultipartRequest request = new MultipartRequest();
        expect(() {
          request.contentLength = 10;
        }, throwsUnsupportedError);
      });

      test('setting body in request dispatcher is unsupported', () async {
        MultipartRequest request = new MultipartRequest()
          ..uri = config.reflectEndpointUri;
        expect(request.post(body: 'invalid'), throwsUnsupportedError);
      });

      test('should support Blob file', () async {
        Blob blob = new Blob([UTF8.encode('file')]);
        MultipartRequest request = new MultipartRequest()
          ..uri = config.reflectEndpointUri
          ..files['blob'] = blob;
        await request.post();
      });

      test('should support File', () async {
        // TODO: Not sure how to test this - the File class cannot be constructed.
      });
    });
  });
}
