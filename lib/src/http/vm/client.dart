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
import 'package:w_transport/src/http/common/client.dart';
import 'package:w_transport/src/http/requests.dart';
import 'package:w_transport/src/http/vm/requests.dart';

/// VM-specific implementation of an HTTP client. All requests created from this
/// client will use the same dart:io.HttpClient. This allows for network
/// connections to be cached.
class VMClient extends CommonClient implements Client {
  /// The underlying HTTP client used to open and send requests.
  HttpClient _client = new HttpClient();

  /// Close the underlying HTTP client.
  @override
  void closeClient() {
    if (_client != null) {
      _client.close();
    }
  }

  /// Constructs a new [FormRequest] that will use this client to send the
  /// request. Throws a [StateError] if this client has been closed.
  @override
  FormRequest newFormRequest() {
    verifyNotClosed();
    FormRequest request = new VMFormRequest.fromClient(this, _client);
    registerAndDecorateRequest(request);
    return request;
  }

  /// Constructs a new [JsonRequest] that will use this client to send the
  /// request. Throws a [StateError] if this client has been closed.
  @override
  JsonRequest newJsonRequest() {
    verifyNotClosed();
    JsonRequest request = new VMJsonRequest.fromClient(this, _client);
    registerAndDecorateRequest(request);
    return request;
  }

  /// Constructs a new [MultipartRequest] that will use this client to send the
  /// request. Throws a [StateError] if this client has been closed.
  @override
  MultipartRequest newMultipartRequest() {
    verifyNotClosed();
    MultipartRequest request = new VMMultipartRequest.fromClient(this, _client);
    registerAndDecorateRequest(request);
    return request;
  }

  /// Constructs a new [Request] that will use this client to send the request.
  /// Throws a [StateError] if this client has been closed.
  @override
  Request newRequest() {
    verifyNotClosed();
    Request request = new VMPlainTextRequest.fromClient(this, _client);
    registerAndDecorateRequest(request);
    return request;
  }

  /// Constructs a new [StreamedRequest] that will use this client to send the
  /// request. Throws a [StateError] if this client has been closed.
  @override
  StreamedRequest newStreamedRequest() {
    verifyNotClosed();
    StreamedRequest request = new VMStreamedRequest.fromClient(this, _client);
    registerAndDecorateRequest(request);
    return request;
  }
}
