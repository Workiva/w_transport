library w_transport.src.http.vm.requests;

import 'dart:io';

import 'package:w_transport/src/http/common/form_request.dart';
import 'package:w_transport/src/http/common/json_request.dart';
import 'package:w_transport/src/http/common/plain_text_request.dart';
import 'package:w_transport/src/http/common/streamed_request.dart';
import 'package:w_transport/src/http/vm/request_mixin.dart';

export 'package:w_transport/src/http/vm/multipart_request.dart' show VMMultipartRequest;


class VMFormRequest extends CommonFormRequest with VMRequestMixin {
  VMFormRequest() : super();
  VMFormRequest.withClient(HttpClient client) : super.withClient(client);
}

class VMJsonRequest extends CommonJsonRequest with VMRequestMixin {
  VMJsonRequest() : super();
  VMJsonRequest.withClient(HttpClient client) : super.withClient(client);
}

class VMPlainTextRequest extends CommonPlainTextRequest with VMRequestMixin {
  VMPlainTextRequest() : super();
  VMPlainTextRequest.withClient(HttpClient client) : super.withClient(client);
}

class VMStreamedRequest extends CommonStreamedRequest with VMRequestMixin {
  VMStreamedRequest() : super();
  VMStreamedRequest.withClient(HttpClient client) : super.withClient(client);
}