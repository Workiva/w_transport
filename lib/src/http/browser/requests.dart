library w_transport.src.http.browser.requests;

import 'package:w_transport/src/http/browser/request_mixin.dart';
import 'package:w_transport/src/http/common/form_request.dart';
import 'package:w_transport/src/http/common/json_request.dart';
import 'package:w_transport/src/http/common/plain_text_request.dart';
import 'package:w_transport/src/http/common/streamed_request.dart';

export 'package:w_transport/src/http/browser/multipart_request.dart'
    show BrowserMultipartRequest;

class BrowserFormRequest extends CommonFormRequest with BrowserRequestMixin {}

class BrowserJsonRequest extends CommonJsonRequest with BrowserRequestMixin {}

class BrowserPlainTextRequest extends CommonPlainTextRequest
    with BrowserRequestMixin {}

class BrowserStreamedRequest extends CommonStreamedRequest
    with BrowserRequestMixin {}
