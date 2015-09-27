library w_transport.src.http.mock.requests;

import 'package:w_transport/src/http/common/form_request.dart';
import 'package:w_transport/src/http/common/json_request.dart';
import 'package:w_transport/src/http/common/plain_text_request.dart';
import 'package:w_transport/src/http/common/streamed_request.dart';
import 'package:w_transport/src/http/mock/request_mixin.dart';

//todo
//export 'package:w_transport/src/http/mock/multipart_request.dart' show BrowserMultipartRequest;

class MockFormRequest extends CommonFormRequest with MockRequestMixin {}

class MockJsonRequest extends CommonJsonRequest with MockRequestMixin {}

class MockPlainTextRequest extends CommonPlainTextRequest with MockRequestMixin {}

class MockStreamedRequest extends CommonStreamedRequest with MockRequestMixin {}