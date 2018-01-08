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

@TestOn('browser')
import 'package:test/test.dart';

import 'global_web_socket_monitor/browser_test.dart'
    as global_web_socket_monitor_browser;
import 'global_web_socket_monitor/sockjs_port_test.dart'
    as global_web_socket_monitor_sockjs_port;

import 'http/client/browser_test.dart' as http_client_browser;
import 'http/common_request/browser_test.dart' as http_common_request_browser;
import 'http/form_request/browser_test.dart' as http_form_request_browser;
import 'http/http_static/browser_test.dart' as http_http_static_browser;
import 'http/json_request/browser_test.dart' as http_json_request_browser;
import 'http/multipart_request/browser_test.dart'
    as http_multipart_request_browser;
import 'http/plain_text_request/browser_test.dart'
    as http_plain_text_request_browser;
import 'http/streamed_request/browser_test.dart'
    as http_streamed_request_browser;

import 'platforms/browser_transport_platform_test.dart'
    as browser_transport_platform_test;

import 'ws/browser_test.dart' as ws_browser;
import 'ws/sockjs_port_test.dart' as ws_sockjs_port;

void main() {
  global_web_socket_monitor_browser.main();
  global_web_socket_monitor_sockjs_port.main();

  http_client_browser.main();
  http_common_request_browser.main();
  http_form_request_browser.main();
  http_http_static_browser.main();
  http_json_request_browser.main();
  http_multipart_request_browser.main();
  http_plain_text_request_browser.main();
  http_streamed_request_browser.main();

  browser_transport_platform_test.main();

  ws_browser.main();
  ws_sockjs_port.main();
}
