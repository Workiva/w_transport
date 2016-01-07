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

library w_transport.src.mock_adapter;

import 'dart:async';

import 'package:w_transport/src/http/client.dart';
import 'package:w_transport/src/http/mock/client.dart';
import 'package:w_transport/src/http/mock/requests.dart';
import 'package:w_transport/src/http/requests.dart';
import 'package:w_transport/src/platform_adapter.dart';
import 'package:w_transport/src/web_socket/mock/w_socket.dart';
import 'package:w_transport/src/web_socket/w_socket.dart';

/// Adapter for the testing environment. Exposes factories for all of the
/// transport classes that return mock implementations that can be controlled
/// by the mock transport API.
class MockAdapter implements PlatformAdapter {
  /// Construct a new [MockClient] instance that implements [Client].
  Client newClient() => new MockClient();

  /// Construct a new [MockFormRequest] instance that implements
  /// [FormRequest].
  FormRequest newFormRequest() => new MockFormRequest();

  /// Construct a new [MockJsonRequest] instance that implements
  /// [JsonRequest].
  JsonRequest newJsonRequest() => new MockJsonRequest();

  /// Construct a new [MockMultipartRequest] instance that implements
  /// [MultipartRequest].
  MultipartRequest newMultipartRequest() => new MockMultipartRequest();

  /// Construct a new [MockPlainTextRequest] instance that implements
  /// [Request].
  Request newRequest() => new MockPlainTextRequest();

  /// Construct a new [MockStreamedRequest] instance that implements
  /// [StreamedRequest].
  StreamedRequest newStreamedRequest() => new MockStreamedRequest();

  /// Construct a new [MockWSocket] instance that implements [WSocket].
  Future<WSocket> newWSocket(Uri uri,
          {Map<String, dynamic> headers,
          Iterable<String> protocols,
          bool sockJSDebug,
          bool sockJSNoCredentials,
          List<String> sockJSProtocolsWhitelist,
          bool useSockJS}) =>
      MockWSocket.connect(uri, protocols: protocols, headers: headers);
}
