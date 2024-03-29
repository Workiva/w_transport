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

import 'dart:io' as io;

import 'package:w_transport/src/http/common/http_client.dart';
import 'package:w_transport/src/http/http_client.dart';
import 'package:w_transport/src/http/requests.dart';
import 'package:w_transport/src/http/vm/requests.dart';

/// VM-specific implementation of an HTTP client. All requests created from this
/// client will use the same dart:io.HttpClient. This allows for network
/// connections to be cached.
class VMHttpClient extends CommonHttpClient implements HttpClient {
  /// The underlying HTTP client used to open and send requests.
  io.HttpClient _ioHttpClient = io.HttpClient();

  /// Close the underlying HTTP client.
  @override
  void closeClient() {
    _ioHttpClient.close();
  }

  /// Constructs a new [FormRequest] that will use this client to send the
  /// request. Throws a [StateError] if this client has been closed.
  @override
  FormRequest newFormRequest() {
    verifyNotClosed();
    final request = VMFormRequest.fromClient(this, _ioHttpClient);
    registerAndDecorateRequest(request);
    return request;
  }

  /// Constructs a new [JsonRequest] that will use this client to send the
  /// request. Throws a [StateError] if this client has been closed.
  @override
  JsonRequest newJsonRequest() {
    verifyNotClosed();
    final request = VMJsonRequest.fromClient(this, _ioHttpClient);
    registerAndDecorateRequest(request);
    return request;
  }

  /// Constructs a new [MultipartRequest] that will use this client to send the
  /// request. Throws a [StateError] if this client has been closed.
  @override
  MultipartRequest newMultipartRequest() {
    verifyNotClosed();
    final request = VMMultipartRequest.fromClient(this, _ioHttpClient);
    registerAndDecorateRequest(request);
    return request;
  }

  /// Constructs a new [Request] that will use this client to send the request.
  /// Throws a [StateError] if this client has been closed.
  @override
  Request newRequest() {
    verifyNotClosed();
    final request = VMPlainTextRequest.fromClient(this, _ioHttpClient);
    registerAndDecorateRequest(request);
    return request;
  }

  /// Constructs a new [StreamedRequest] that will use this client to send the
  /// request. Throws a [StateError] if this client has been closed.
  @override
  StreamedRequest newStreamedRequest() {
    verifyNotClosed();
    final request = VMStreamedRequest.fromClient(this, _ioHttpClient);
    registerAndDecorateRequest(request);
    return request;
  }
}
