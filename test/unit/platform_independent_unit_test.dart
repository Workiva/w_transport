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

@TestOn('browser || vm')
library w_transport.test.unit.unit_test_suite;

import 'package:test/test.dart';

import 'http/client_test.dart' as http_client_test;
import 'http/form_request_test.dart' as http_form_request_test;
import 'http/http_body_test.dart' as http_body_test;
import 'http/http_static_test.dart' as http_static_test;
import 'http/json_request_test.dart' as http_json_request_test;
import 'http/multipart_file_test.dart' as http_multipart_file_test;
import 'http/multipart_request_test.dart' as http_multipart_request_test;
import 'http/plain_text_request_test.dart' as http_plain_text_request_test;
import 'http/request_exception_test.dart' as http_request_exception_test;
import 'http/request_progress_test.dart' as http_request_progress_test;
import 'http/request_test.dart' as http_request_test;
import 'http/response_test.dart' as http_response_test;
import 'http/streamed_request_test.dart' as http_streamed_request_test;
import 'http/utils_test.dart' as http_utils_test;

import 'mocks/mock_http_test.dart' as mock_http_test;
import 'mocks/mock_response_test.dart' as mock_response_test;
import 'mocks/mock_web_socket_test.dart' as mock_web_socket_test;

import 'ws/w_socket_exception_test.dart' as ws_w_socket_exception_test;
import 'ws/w_socket_test.dart' as ws_w_socket_test;

void main() {
  http_client_test.main();
  http_body_test.main();
  http_form_request_test.main();
  http_json_request_test.main();
  http_multipart_file_test.main();
  http_multipart_request_test.main();
  http_plain_text_request_test.main();
  http_static_test.main();
  http_request_exception_test.main();
  http_request_progress_test.main();
  http_request_test.main();
  http_response_test.main();
  http_streamed_request_test.main();
  http_utils_test.main();

  mock_http_test.main();
  mock_response_test.main();
  mock_web_socket_test.main();

  ws_w_socket_exception_test.main();
  ws_w_socket_test.main();
}
