@TestOn('vm')
library w_transport.test.integration.http.http_static.vm_test;

import 'package:test/test.dart';
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

    runHttpStaticSuite(config);
  });
}