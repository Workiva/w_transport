library w_transport.test.vm_tests;

import './integration/w_http_server_test.dart' as w_http_server_test;
import './unit/w_url_test.dart' as w_url_test;


void main() {
  w_http_server_test.main();
  w_url_test.main();
}