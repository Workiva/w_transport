@TestOn('browser || vm')
library w_transport.test.integration.http.common_request.mock_test;

import 'package:test/test.dart';
import 'package:w_transport/w_transport_mock.dart';

import '../../../naming.dart';
import '../mock_endpoints/404.dart';
import '../mock_endpoints/download.dart';
import '../mock_endpoints/reflect.dart';
import '../mock_endpoints/timeout.dart';
import '../integration_config.dart';
import 'suite.dart';

void main() {
  group(integrationHttpMock, () {
    var config = new HttpIntegrationConfig.mock();

    setUp(() {
      configureWTransportForTest();
      mock404Endpoint(config.fourOhFourEndpointUri);
      mockDownloadEndpoint(config.downloadEndpointUri);
      mockReflectEndpoint(config.reflectEndpointUri);
      mockTimeoutEndpoint(config.timeoutEndpointUri);
    });

    runCommonRequestSuite(config);

    tearDown(() {
      MockTransports.verifyNoOutstandingExceptions();
    });
  });
}