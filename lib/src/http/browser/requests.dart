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
import 'package:w_transport/src/http/common/form_request.dart';
import 'package:w_transport/src/http/common/json_request.dart';
import 'package:w_transport/src/http/common/plain_text_request.dart';
import 'package:w_transport/src/http/common/streamed_request.dart';

export 'package:w_transport/src/http/browser/multipart_request.dart'
    show BrowserMultipartRequest;

class BrowserFormRequest extends CommonFormRequest with BrowserRequestMixin {
  BrowserFormRequest() : super();
  BrowserFormRequest.fromClient(Client wTransportClient)
      : super.fromClient(wTransportClient, null);
}

class BrowserJsonRequest extends CommonJsonRequest with BrowserRequestMixin {
  BrowserJsonRequest() : super();
  BrowserJsonRequest.fromClient(Client wTransportClient)
      : super.fromClient(wTransportClient, null);
}

class BrowserPlainTextRequest extends CommonPlainTextRequest
    with BrowserRequestMixin {
  BrowserPlainTextRequest() : super();
  BrowserPlainTextRequest.fromClient(Client wTransportClient)
      : super.fromClient(wTransportClient, null);
}

class BrowserStreamedRequest extends CommonStreamedRequest
    with BrowserRequestMixin {
  BrowserStreamedRequest() : super();
  BrowserStreamedRequest.fromClient(Client wTransportClient)
      : super.fromClient(wTransportClient, null);
}
