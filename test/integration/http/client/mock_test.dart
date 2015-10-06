@TestOn('browser || vm')
library w_transport.test.integration.http.client.mock_test;

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
      mockPingEndpoint(config.pingEndpointUri);
      mockReflectEndpoint(config.reflectEndpointUri);
      mockTimeoutEndpoint(config.timeoutEndpointUri);
    });

    runClientSuite(config);

    tearDown(() {
      MockTransports.verifyNoOutstandingExceptions();
    });
  });
}