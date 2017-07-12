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

import 'dart:io';

import 'package:w_transport/src/http/client.dart';
import 'package:w_transport/src/http/common/form_request.dart';
import 'package:w_transport/src/http/common/json_request.dart';
import 'package:w_transport/src/http/common/multipart_request.dart';
import 'package:w_transport/src/http/common/plain_text_request.dart';
import 'package:w_transport/src/http/common/streamed_request.dart';
import 'package:w_transport/src/http/vm/request_mixin.dart';
import 'package:w_transport/src/transport_platform.dart';

class VMFormRequest extends CommonFormRequest with VMRequestMixin {
  VMFormRequest(TransportPlatform transportPlatform) : super(transportPlatform);
  // ignore: deprecated_member_use
  VMFormRequest.fromClient(Client wTransportClient, HttpClient client)
      : super.fromClient(wTransportClient, client);
}

class VMJsonRequest extends CommonJsonRequest with VMRequestMixin {
  VMJsonRequest(TransportPlatform transportPlatform) : super(transportPlatform);
  // ignore: deprecated_member_use
  VMJsonRequest.fromClient(Client wTransportClient, HttpClient client)
      : super.fromClient(wTransportClient, client);
}

class VMMultipartRequest extends CommonMultipartRequest with VMRequestMixin {
  VMMultipartRequest(TransportPlatform transportPlatform)
      : super(transportPlatform);
  // ignore: deprecated_member_use
  VMMultipartRequest.fromClient(Client wTransportClient, HttpClient client)
      : super.fromClient(wTransportClient, client);
}

class VMPlainTextRequest extends CommonPlainTextRequest with VMRequestMixin {
  VMPlainTextRequest(TransportPlatform transportPlatform)
      : super(transportPlatform);
  // ignore: deprecated_member_use
  VMPlainTextRequest.fromClient(Client wTransportClient, HttpClient client)
      : super.fromClient(wTransportClient, client);
}

class VMStreamedRequest extends CommonStreamedRequest with VMRequestMixin {
  VMStreamedRequest(TransportPlatform transportPlatform)
      : super(transportPlatform);
  // ignore: deprecated_member_use
  VMStreamedRequest.fromClient(Client wTransportClient, HttpClient client)
      : super.fromClient(wTransportClient, client);
}
