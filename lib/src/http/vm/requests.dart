library w_transport.src.http.vm.requests;

import 'dart:io';

import 'package:w_transport/src/http/common/form_request.dart';
import 'package:w_transport/src/http/common/json_request.dart';
import 'package:w_transport/src/http/common/multipart_request.dart';
import 'package:w_transport/src/http/common/plain_text_request.dart';
import 'package:w_transport/src/http/common/streamed_request.dart';
import 'package:w_transport/src/http/vm/request_mixin.dart';

class VMFormRequest extends CommonFormRequest with VMRequestMixin {
  VMFormRequest() : super();
  VMFormRequest.withClient(HttpClient client) : super.withClient(client);
}

class VMJsonRequest extends CommonJsonRequest with VMRequestMixin {
  VMJsonRequest() : super();
  VMJsonRequest.withClient(HttpClient client) : super.withClient(client);
}

class VMMultipartRequest extends CommonMultipartRequest with VMRequestMixin {
  VMMultipartRequest() : super();
  VMMultipartRequest.withClient(HttpClient client) : super.withClient(client);
}

class VMPlainTextRequest extends CommonPlainTextRequest with VMRequestMixin {
  VMPlainTextRequest() : super();
  VMPlainTextRequest.withClient(HttpClient client) : super.withClient(client);
}

class VMStreamedRequest extends CommonStreamedRequest with VMRequestMixin {
  VMStreamedRequest() : super();
  VMStreamedRequest.withClient(HttpClient client) : super.withClient(client);
}
