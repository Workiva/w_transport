@TestOn('browser')
library w_transport.test.integration.browser_suite_test;

import 'package:test/test.dart';

import 'http/client/browser_test.dart' as http_client_browser;
import 'http/common_request/browser_test.dart' as http_common_request_browser;
import 'http/form_request/browser_test.dart' as http_form_request_browser;
import 'http/http_static/browser_test.dart' as http_http_static_browser;
import 'http/json_request/browser_test.dart' as http_json_request_browser;
import 'http/multipart_request/browser_test.dart' as http_multipart_request_browser;
import 'http/plain_text_request/browser_test.dart' as http_plain_text_request_browser;
import 'http/streamed_request/browser_test.dart' as http_streamed_request_browser;

import 'platforms/browser_platform_test.dart' as browser_platform_adapter_test;

import 'ws/client_test.dart' as ws_browser;

void main() {
  http_client_browser.main();
  http_common_request_browser.main();
  http_form_request_browser.main();
  http_http_static_browser.main();
  http_json_request_browser.main();
  http_multipart_request_browser.main();
  http_plain_text_request_browser.main();
  http_streamed_request_browser.main();

  browser_platform_adapter_test.main();

  ws_browser.main();
}