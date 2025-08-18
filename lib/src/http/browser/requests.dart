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

import 'package:w_transport/src/http/browser/request_mixin.dart';
import 'package:w_transport/src/http/client.dart';
import 'package:w_transport/src/http/common/binary_request.dart';
import 'package:w_transport/src/http/common/form_request.dart';
import 'package:w_transport/src/http/common/json_request.dart';
import 'package:w_transport/src/http/common/plain_text_request.dart';
import 'package:w_transport/src/http/common/streamed_request.dart';
import 'package:w_transport/src/transport_platform.dart';

export 'package:w_transport/src/http/browser/multipart_request.dart'
    show BrowserMultipartRequest;

class BrowserBinaryRequest extends CommonBinaryRequest
    with BrowserRequestMixin {
  BrowserBinaryRequest(TransportPlatform transportPlatform)
      : super(transportPlatform);
  // ignore: deprecated_member_use_from_same_package
  BrowserBinaryRequest.fromClient(Client wTransportClient)
      : super.fromClient(wTransportClient, null);
}

class BrowserFormRequest extends CommonFormRequest with BrowserRequestMixin {
  BrowserFormRequest(TransportPlatform transportPlatform)
      : super(transportPlatform);
  // ignore: deprecated_member_use_from_same_package
  BrowserFormRequest.fromClient(Client wTransportClient)
      : super.fromClient(wTransportClient, null);
}

class BrowserJsonRequest extends CommonJsonRequest with BrowserRequestMixin {
  BrowserJsonRequest(TransportPlatform transportPlatform)
      : super(transportPlatform);
  // ignore: deprecated_member_use_from_same_package
  BrowserJsonRequest.fromClient(Client wTransportClient)
      : super.fromClient(wTransportClient, null);
}

class BrowserPlainTextRequest extends CommonPlainTextRequest
    with BrowserRequestMixin {
  BrowserPlainTextRequest(TransportPlatform transportPlatform)
      : super(transportPlatform);
  // ignore: deprecated_member_use_from_same_package
  BrowserPlainTextRequest.fromClient(Client wTransportClient)
      : super.fromClient(wTransportClient, null);
}

class BrowserStreamedRequest extends CommonStreamedRequest
    with BrowserRequestMixin {
  BrowserStreamedRequest(TransportPlatform transportPlatform)
      : super(transportPlatform);
  // ignore: deprecated_member_use_from_same_package
  BrowserStreamedRequest.fromClient(Client wTransportClient)
      : super.fromClient(wTransportClient, null);
}
