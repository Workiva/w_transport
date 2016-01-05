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

library w_transport.src.http.mock.requests;

import 'package:w_transport/src/http/client.dart';
import 'package:w_transport/src/http/common/form_request.dart';
import 'package:w_transport/src/http/common/json_request.dart';
import 'package:w_transport/src/http/common/multipart_request.dart';
import 'package:w_transport/src/http/common/plain_text_request.dart';
import 'package:w_transport/src/http/common/streamed_request.dart';
import 'package:w_transport/src/http/mock/request_mixin.dart';

class MockFormRequest extends CommonFormRequest with MockRequestMixin {
  MockFormRequest() : super();
  MockFormRequest.fromClient(Client wTransportClient)
      : super.fromClient(wTransportClient, null);
}

class MockJsonRequest extends CommonJsonRequest with MockRequestMixin {
  MockJsonRequest() : super();
  MockJsonRequest.fromClient(Client wTransportClient)
      : super.fromClient(wTransportClient, null);
}

class MockMultipartRequest extends CommonMultipartRequest
    with MockRequestMixin {
  MockMultipartRequest() : super();
  MockMultipartRequest.fromClient(Client wTransportClient)
      : super.fromClient(wTransportClient, null);
}

class MockPlainTextRequest extends CommonPlainTextRequest
    with MockRequestMixin {
  MockPlainTextRequest() : super();
  MockPlainTextRequest.fromClient(Client wTransportClient)
      : super.fromClient(wTransportClient, null);
}

class MockStreamedRequest extends CommonStreamedRequest with MockRequestMixin {
  MockStreamedRequest() : super();
  MockStreamedRequest.fromClient(Client wTransportClient)
      : super.fromClient(wTransportClient, null);
}
