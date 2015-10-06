@TestOn('vm')
library w_transport.test.integration.http.streamed_request.vm_test;

import 'dart:io';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_vm.dart';

import '../../../naming.dart';
import '../integration_config.dart';
import 'suite.dart';

void main() {
  var config = new HttpIntegrationConfig.vm();
  group(integrationHttpVM, () {
    setUp(() {
      configureWTransportForVM();
    });

    runStreamedRequestSuite(config);

    test('underlying HttpRequest configuration', () async {
      StreamedRequest request = new StreamedRequest()..uri = config.reflectEndpointUri;
      request.configure((HttpClientRequest ioRequest) async {
        ioRequest.headers.set('x-configured', 'true');
      });
      Response response = await request.get();
      expect(response.body.asJson()['headers']['x-configured'], equals('true'));
    });
  });
}