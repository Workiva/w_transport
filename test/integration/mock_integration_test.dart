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
import 'package:test/test.dart';

import 'http/client/mock_test.dart' as http_client_mock;
import 'http/common_request/mock_test.dart' as http_common_request_mock;
import 'http/form_request/mock_test.dart' as http_form_request_mock;
import 'http/http_static/mock_test.dart' as http_http_static_mock;
import 'http/json_request/mock_test.dart' as http_json_request_mock;
import 'http/multipart_request/mock_test.dart' as http_multipart_request_mock;
import 'http/plain_text_request/mock_test.dart' as http_plain_text_request_mock;
import 'http/streamed_request/mock_test.dart' as http_streamed_request_mock;

import 'platforms/mock_aware_transport_platform.dart'
    as mock_aware_transport_platform_test;
import 'platforms/transport_platform_test.dart' as transport_platform_test;

import 'ws/mock_test.dart' as ws_mock;

void main() {
  http_client_mock.main();
  http_common_request_mock.main();
  http_form_request_mock.main();
  http_http_static_mock.main();
  http_json_request_mock.main();
  http_multipart_request_mock.main();
  http_plain_text_request_mock.main();
  http_streamed_request_mock.main();

  mock_aware_transport_platform_test.main();
  transport_platform_test.main();

  ws_mock.main();
}
