@TestOn('vm')
library w_transport.test.integration.vm_suite_test;

import 'package:test/test.dart';

import 'http/client/vm_test.dart' as http_client_vm;
import 'http/common_request/vm_test.dart' as http_common_request_vm;
import 'http/form_request/vm_test.dart' as http_form_request_vm;
import 'http/http_static/vm_test.dart' as http_http_static_vm;
import 'http/json_request/vm_test.dart' as http_json_request_vm;
import 'http/multipart_request/vm_test.dart' as http_multipart_request_vm;
import 'http/plain_text_request/vm_test.dart' as http_plain_text_request_vm;
import 'http/streamed_request/vm_test.dart' as http_streamed_request_vm;

import 'platforms/vm_platform_test.dart' as vm_platform_adapter_test;

import 'ws/server_test.dart' as ws_vm;

void main() {
  http_client_vm.main();
  http_common_request_vm.main();
  http_form_request_vm.main();
  http_http_static_vm.main();
  http_json_request_vm.main();
  http_multipart_request_vm.main();
  http_plain_text_request_vm.main();
  http_streamed_request_vm.main();

  vm_platform_adapter_test.main();

  ws_vm.main();
}