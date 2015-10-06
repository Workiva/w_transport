library w_transport.src.http.mock.requests;

import 'package:w_transport/src/http/common/form_request.dart';
import 'package:w_transport/src/http/common/json_request.dart';
import 'package:w_transport/src/http/common/multipart_request.dart';
import 'package:w_transport/src/http/common/plain_text_request.dart';
import 'package:w_transport/src/http/common/streamed_request.dart';
import 'package:w_transport/src/http/mock/request_mixin.dart';

class MockFormRequest extends CommonFormRequest with MockRequestMixin {}

class MockJsonRequest extends CommonJsonRequest with MockRequestMixin {}

class MockMultipartRequest extends CommonMultipartRequest
    with MockRequestMixin {}

class MockPlainTextRequest extends CommonPlainTextRequest
    with MockRequestMixin {}

class MockStreamedRequest extends CommonStreamedRequest with MockRequestMixin {}
