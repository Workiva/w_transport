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

import 'package:w_transport/src/http/browser/http_client.dart';
import 'package:w_transport/src/http/browser/requests.dart';
import 'package:w_transport/src/http/http_client.dart';
import 'package:w_transport/src/http/requests.dart';
import 'package:w_transport/src/transport_platform.dart';
import 'package:w_transport/src/web_socket/browser/web_socket.dart';
import 'package:w_transport/src/web_socket/web_socket.dart';

const BrowserTransportPlatform browserTransportPlatform =
    BrowserTransportPlatform();

class BrowserTransportPlatform implements TransportPlatform {
  const BrowserTransportPlatform();

  /// Construct a [HttpClient] instance for use in the browser.
  @override
  HttpClient newHttpClient() => BrowserHttpClient();

  /// Construct a [BinaryRequest] instance for use in the browser.
  @override
  BinaryRequest newBinaryRequest() => BrowserBinaryRequest(this);

  /// Construct a [FormRequest] instance for use in the browser.
  @override
  FormRequest newFormRequest() => BrowserFormRequest(this);

  /// Construct a [JsonRequest] instance for use in the browser.
  @override
  JsonRequest newJsonRequest() => BrowserJsonRequest(this);

  /// Construct a [MultipartRequest] instance for use in the browser.
  @override
  MultipartRequest newMultipartRequest() => BrowserMultipartRequest(this);

  /// Construct a [Request] instance for use in the browser.
  @override
  Request newRequest() => BrowserPlainTextRequest(this);

  /// Construct a [StreamedRequest] instance for use in the browser.
  @override
  StreamedRequest newStreamedRequest() => BrowserStreamedRequest(this);

  /// Construct a [WebSocket] instance for use in the browser.
  @override
  Future<WebSocket> newWebSocket(Uri uri,
          {Map<String, dynamic>? headers, Iterable<String>? protocols}) =>
      BrowserWebSocket.connect(uri, headers: headers, protocols: protocols);
}
