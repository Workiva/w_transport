@TestOn('browser || vm')
library w_transport.test.integration.mock_suite_test;

import 'package:test/test.dart';

import 'http/client/mock_test.dart' as http_client_mock;
import 'http/common_request/mock_test.dart' as http_common_request_mock;
import 'http/form_request/mock_test.dart' as http_form_request_mock;
import 'http/http_static/mock_test.dart' as http_http_static_mock;
import 'http/json_request/mock_test.dart' as http_json_request_mock;
import 'http/multipart_request/mock_test.dart' as http_multipart_request_mock;
import 'http/plain_text_request/mock_test.dart' as http_plain_text_request_mock;
import 'http/streamed_request/mock_test.dart' as http_streamed_request_mock;

import 'platforms/mock_platform_test.dart' as mock_platform_adapter_test;
import 'platforms/platform_adapter_test.dart' as platform_adapter_test;

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

  mock_platform_adapter_test.main();
  platform_adapter_test.main();

  ws_mock.main();
}
