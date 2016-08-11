// Copyright 2015 Workiva Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

@TestOn('vm')
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

import 'ws/vm_test.dart' as ws_vm;

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
