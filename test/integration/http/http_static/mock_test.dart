@TestOn('browser || vm')
library w_transport.test.integration.http.http_static.mock_test;

import 'package:test/test.dart';
import 'package:w_transport/w_transport_mock.dart';

import '../../../naming.dart';
import '../mock_endpoints/ping.dart';
import '../mock_endpoints/reflect.dart';
import '../mock_endpoints/timeout.dart';
import '../integration_config.dart';
import 'suite.dart';

void main() {
  group(integrationHttpMock, () {
    var config = new HttpIntegrationConfig.mock();

    setUp(() {
      configureWTransportForTest();
      mockReflectEndpoint(config.reflectEndpointUri);
    });

    runHttpStaticSuite(config);

    tearDown(() {
      MockTransports.verifyNoOutstandingExceptions();
    });
  });
}
