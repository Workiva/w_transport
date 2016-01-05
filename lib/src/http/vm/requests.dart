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

library w_transport.src.http.vm.requests;

import 'dart:io';

import 'package:w_transport/src/http/client.dart';
import 'package:w_transport/src/http/common/form_request.dart';
import 'package:w_transport/src/http/common/json_request.dart';
import 'package:w_transport/src/http/common/multipart_request.dart';
import 'package:w_transport/src/http/common/plain_text_request.dart';
import 'package:w_transport/src/http/common/streamed_request.dart';
import 'package:w_transport/src/http/vm/request_mixin.dart';

class VMFormRequest extends CommonFormRequest with VMRequestMixin {
  VMFormRequest() : super();
  VMFormRequest.fromClient(Client wTransportClient, HttpClient client)
      : super.fromClient(wTransportClient, client);
}

class VMJsonRequest extends CommonJsonRequest with VMRequestMixin {
  VMJsonRequest() : super();
  VMJsonRequest.fromClient(Client wTransportClient, HttpClient client)
      : super.fromClient(wTransportClient, client);
}

class VMMultipartRequest extends CommonMultipartRequest with VMRequestMixin {
  VMMultipartRequest() : super();
  VMMultipartRequest.fromClient(Client wTransportClient, HttpClient client)
      : super.fromClient(wTransportClient, client);
}

class VMPlainTextRequest extends CommonPlainTextRequest with VMRequestMixin {
  VMPlainTextRequest() : super();
  VMPlainTextRequest.fromClient(Client wTransportClient, HttpClient client)
      : super.fromClient(wTransportClient, client);
}

class VMStreamedRequest extends CommonStreamedRequest with VMRequestMixin {
  VMStreamedRequest() : super();
  VMStreamedRequest.fromClient(Client wTransportClient, HttpClient client)
      : super.fromClient(wTransportClient, client);
}
