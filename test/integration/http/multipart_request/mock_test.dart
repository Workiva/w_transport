@TestOn('browser || vm')
library w_transport.test.integration.http.multipart_request.mock_test;

import 'package:test/test.dart';
import 'package:w_transport/w_transport_mock.dart';

import '../../../naming.dart';
import '../mock_endpoints/404.dart';
import '../mock_endpoints/reflect.dart';
import '../mock_endpoints/upload.dart';
import '../integration_config.dart';
import 'suite.dart';

void main() {
  group(integrationHttpMock, () {
    var config = new HttpIntegrationConfig.mock();

    setUp(() {
      configureWTransportForTest();
      mock404Endpoint(config.fourOhFourEndpointUri);
      mockReflectEndpoint(config.reflectEndpointUri);
      mockUploadEndpoint(config.uploadEndpointUri);
    });

    runMultipartRequestSuite(config);

    tearDown(() {
      MockTransports.verifyNoOutstandingExceptions();
    });
  });
}
