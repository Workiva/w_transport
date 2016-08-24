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

import 'dart:async';

import 'package:w_transport/src/http/http_client.dart';
import 'package:w_transport/src/http/requests.dart';
import 'package:w_transport/src/http/vm/http_client.dart';
import 'package:w_transport/src/http/vm/requests.dart';
import 'package:w_transport/src/platform_adapter.dart';
import 'package:w_transport/src/web_socket/web_socket.dart';
import 'package:w_transport/src/web_socket/vm/w_socket.dart';

/// Adapter for the Dart VM. Exposes factories for all of the transport classes
/// that return VM-specific implementations that leverage dart:io.
class VMAdapter implements PlatformAdapter {
  /// Construct a new [VMHttpClient] instance that implements [HttpClient].
  HttpClient newHttpClient() => new VMHttpClient();

  /// Construct a new [VMFormRequest] instance that implements [FormRequest].
  FormRequest newFormRequest() => new VMFormRequest();

  /// Construct a new [VMJsonRequest] instance that implements [JsonRequest].
  JsonRequest newJsonRequest() => new VMJsonRequest();

  /// Construct a new [VMMultipartRequest] instance that implements
  /// [MultipartRequest].
  MultipartRequest newMultipartRequest() => new VMMultipartRequest();

  /// Construct a new [VMPlainTextRequest] instance that implements [Request].
  Request newRequest() => new VMPlainTextRequest();

  /// Construct a new [VMStreamedRequest] instance that implements
  /// [StreamedRequest].
  StreamedRequest newStreamedRequest() => new VMStreamedRequest();

  /// Construct a new [VMWebSocket] instance that implements [WebSocket].
  Future<WebSocket> newWebSocket(Uri uri,
          {Map<String, dynamic> headers,
          Iterable<String> protocols,
          bool sockJSDebug,
          bool sockJSNoCredentials,
          List<String> sockJSProtocolsWhitelist,
          Duration sockJSTimeout,
          bool useSockJS}) =>
      VMWebSocket.connect(uri, protocols: protocols, headers: headers);
}
