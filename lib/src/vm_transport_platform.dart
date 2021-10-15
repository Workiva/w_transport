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
import 'package:w_transport/src/transport_platform.dart';
import 'package:w_transport/src/web_socket/web_socket.dart';
import 'package:w_transport/src/web_socket/vm/web_socket.dart';

const VMTransportPlatform vmTransportPlatform = VMTransportPlatform();

class VMTransportPlatform implements TransportPlatform {
  const VMTransportPlatform();

  /// Construct an [HttpClient] instance for use in the Dart VM.
  @override
  HttpClient newHttpClient() => VMHttpClient();

  /// Construct a [FormRequest] instance for use in the Dart VM.
  @override
  FormRequest newFormRequest() => VMFormRequest(this);

  /// Construct a [JsonRequest] instance for use in the Dart VM.
  @override
  JsonRequest newJsonRequest() => VMJsonRequest(this);

  /// Construct a [MultipartRequest] instance for use in the Dart VM.
  @override
  MultipartRequest newMultipartRequest() => VMMultipartRequest(this);

  /// Construct a [Request] instance for use in the Dart VM.
  @override
  Request newRequest() => VMPlainTextRequest(this);

  /// Construct a [StreamedRequest] instance for use in the Dart VM.
  @override
  StreamedRequest newStreamedRequest() => VMStreamedRequest(this);

  /// Construct a [WebSocket] instance for use in the Dart VM.
  @override
  Future<WebSocket> newWebSocket(Uri uri,
          {Map<String, dynamic> headers, Iterable<String> protocols}) =>
      VMWebSocket.connect(uri, headers: headers, protocols: protocols);
}
