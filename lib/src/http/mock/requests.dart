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

import 'package:w_transport/src/http/http_client.dart';
import 'package:w_transport/src/http/common/form_request.dart';
import 'package:w_transport/src/http/common/json_request.dart';
import 'package:w_transport/src/http/common/multipart_request.dart';
import 'package:w_transport/src/http/common/plain_text_request.dart';
import 'package:w_transport/src/http/common/streamed_request.dart';
import 'package:w_transport/src/http/mock/request_mixin.dart';
import 'package:w_transport/src/http/requests.dart';
import 'package:w_transport/src/transport_platform.dart';

class MockFormRequest extends CommonFormRequest with MockRequestMixin {
  TransportPlatform _realTransport;

  MockFormRequest(TransportPlatform realTransport)
      : _realTransport = realTransport,
        super(realTransport);
  MockFormRequest.fromClient(HttpClient wTransportClient, this._realTransport)
      : super.fromClient(wTransportClient, null);

  @override
  FormRequest createRealRequest() {
    if (_realTransport == null) {
      throw TransportPlatformMissing.httpRequestFailed('FormRequest');
    }
    return _realTransport.newFormRequest()..fields = fields;
  }
}

class MockJsonRequest extends CommonJsonRequest with MockRequestMixin {
  TransportPlatform _realTransport;

  MockJsonRequest(TransportPlatform realTransport)
      : _realTransport = realTransport,
        super(realTransport);
  MockJsonRequest.fromClient(HttpClient wTransportClient, this._realTransport)
      : super.fromClient(wTransportClient, null);

  @override
  JsonRequest createRealRequest() {
    if (_realTransport == null) {
      throw TransportPlatformMissing.httpRequestFailed('JsonRequest');
    }
    return _realTransport.newJsonRequest()..body = body;
  }
}

class MockMultipartRequest extends CommonMultipartRequest
    with MockRequestMixin {
  TransportPlatform _realTransport;

  MockMultipartRequest(TransportPlatform realTransport)
      : _realTransport = realTransport,
        super(realTransport);
  MockMultipartRequest.fromClient(
      HttpClient wTransportClient, this._realTransport)
      : super.fromClient(wTransportClient, null);

  @override
  MultipartRequest createRealRequest() {
    if (_realTransport == null) {
      throw TransportPlatformMissing.httpRequestFailed('MultipartRequest');
    }
    return _realTransport.newMultipartRequest()
      ..fields = fields
      ..files = files;
  }
}

class MockPlainTextRequest extends CommonPlainTextRequest
    with MockRequestMixin {
  TransportPlatform _realTransport;

  MockPlainTextRequest(TransportPlatform realTransport)
      : _realTransport = realTransport,
        super(realTransport);
  MockPlainTextRequest.fromClient(
      HttpClient wTransportClient, this._realTransport)
      : super.fromClient(wTransportClient, null);

  @override
  Request createRealRequest() {
    if (_realTransport == null) {
      throw TransportPlatformMissing.httpRequestFailed('Request');
    }
    return _realTransport.newRequest()..body = body;
  }
}

class MockStreamedRequest extends CommonStreamedRequest with MockRequestMixin {
  TransportPlatform _realTransport;

  MockStreamedRequest(TransportPlatform realTransport)
      : _realTransport = realTransport,
        super(realTransport);
  MockStreamedRequest.fromClient(
      HttpClient wTransportClient, this._realTransport)
      : super.fromClient(wTransportClient, null);

  @override
  StreamedRequest createRealRequest() {
    if (_realTransport == null) {
      throw TransportPlatformMissing.httpRequestFailed('StreamedRequest');
    }
    return _realTransport.newStreamedRequest()
      ..contentLength = contentLength
      ..contentType = contentType
      ..body = body;
  }
}
