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

import 'package:w_transport/src/constants.dart' show v3Deprecation;
import 'package:w_transport/src/http/http_client.dart';
import 'package:w_transport/src/http/requests.dart';
import 'package:w_transport/src/http/vm/http_client.dart';
import 'package:w_transport/src/http/vm/requests.dart';
import 'package:w_transport/src/transport_platform.dart';
import 'package:w_transport/src/web_socket/web_socket.dart';
import 'package:w_transport/src/web_socket/vm/web_socket.dart';

const VMTransportPlatform vmTransportPlatform = const VMTransportPlatform();

class VMTransportPlatform implements TransportPlatform {
  const VMTransportPlatform();

  /// Construct an [HttpClient] instance for use in the Dart VM.
  @override
  HttpClient newHttpClient() => new VMHttpClient();

  /// Construct a [FormRequest] instance for use in the Dart VM.
  @override
  FormRequest newFormRequest() => new VMFormRequest(this);

  /// Construct a [JsonRequest] instance for use in the Dart VM.
  @override
  JsonRequest newJsonRequest() => new VMJsonRequest(this);

  /// Construct a [MultipartRequest] instance for use in the Dart VM.
  @override
  MultipartRequest newMultipartRequest() => new VMMultipartRequest(this);

  /// Construct a [Request] instance for use in the Dart VM.
  @override
  Request newRequest() => new VMPlainTextRequest(this);

  /// Construct a [StreamedRequest] instance for use in the Dart VM.
  @override
  StreamedRequest newStreamedRequest() => new VMStreamedRequest(this);

  /// Construct a [WebSocket] instance for use in the Dart VM.
  @override
  Future<WebSocket> newWebSocket(Uri uri,
          {Map<String, dynamic> headers,
          Iterable<String> protocols,
          @Deprecated(v3Deprecation) bool sockJSDebug,
          @Deprecated(v3Deprecation) bool sockJSNoCredentials,
          @Deprecated(v3Deprecation) List<String> sockJSProtocolsWhitelist,
          @Deprecated(v3Deprecation) Duration sockJSTimeout,
          @Deprecated(v3Deprecation) bool useSockJS}) =>
      VMWebSocket.connect(uri, headers: headers, protocols: protocols);
}
