@TestOn('browser || vm')
library w_transport.test.integration.http.streamed_request.mock_test;

import 'package:test/test.dart';
import 'package:w_transport/w_transport_mock.dart';

import '../../../naming.dart';
import '../mock_endpoints/404.dart';
import '../mock_endpoints/echo.dart';
import '../mock_endpoints/reflect.dart';
import '../integration_config.dart';
import 'suite.dart';

void main() {
  group(integrationHttpMock, () {
    var config = new HttpIntegrationConfig.mock();

    setUp(() {
      configureWTransportForTest();
      mock404Endpoint(config.fourOhFourEndpointUri);
      mockEchoEndpoint(config.echoEndpointUri);
      mockReflectEndpoint(config.reflectEndpointUri);
    });

    runStreamedRequestSuite(config);

    tearDown(() {
      MockTransports.verifyNoOutstandingExceptions();
    });
  });
}