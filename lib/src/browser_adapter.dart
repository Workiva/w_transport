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
import 'package:w_transport/src/platform_adapter.dart';
import 'package:w_transport/src/web_socket/browser/sockjs.dart';
import 'package:w_transport/src/web_socket/browser/web_socket.dart';
import 'package:w_transport/src/web_socket/web_socket.dart';

/// Adapter for the browser platform. Exposes factories for all of the transport
/// classes that return browser-specific implementations that leverage
/// dart:html.
class BrowserAdapter implements PlatformAdapter {
  final bool _useSockJS;
  final bool _sockJSDebug;
  final bool _sockJSNoCredentials;
  final List<String> _sockJSProtocolsWhitelist;
  final Duration _sockJSTimeout;

  BrowserAdapter(
      {bool useSockJS: false,
      bool sockJSNoCredentials: false,
      bool sockJSDebug: false,
      List<String> sockJSProtocolsWhitelist,
      Duration sockJSTimeout})
      : _useSockJS = useSockJS == true,
        _sockJSDebug = sockJSDebug == true,
        _sockJSProtocolsWhitelist = sockJSProtocolsWhitelist,
        _sockJSNoCredentials = sockJSNoCredentials == true,
        _sockJSTimeout = sockJSTimeout;

  /// Construct a new [BrowserHttpClient] instance that implements [HttpClient].
  HttpClient newHttpClient() => new BrowserHttpClient();

  /// Construct a new [BrowserFormRequest] instance that implements
  /// [FormRequest].
  FormRequest newFormRequest() => new BrowserFormRequest();

  /// Construct a new [BrowserJsonRequest] instance that implements
  /// [JsonRequest].
  JsonRequest newJsonRequest() => new BrowserJsonRequest();

  /// Construct a new [BrowserMultipartRequest] instance that implements
  /// [MultipartRequest].
  MultipartRequest newMultipartRequest() => new BrowserMultipartRequest();

  /// Construct a new [BrowserPlainTextRequest] instance that implements
  /// [Request].
  Request newRequest() => new BrowserPlainTextRequest();

  /// Construct a new [BrowserStreamedRequest] instance that implements
  /// [StreamedRequest].
  StreamedRequest newStreamedRequest() => new BrowserStreamedRequest();

  /// Construct a new [BrowserWebSocket] or [SockJSWebSocket] instance that
  /// implements [WebSocket].
  Future<WebSocket> newWebSocket(Uri uri,
      {Map<String, dynamic> headers,
      Iterable<String> protocols,
      bool sockJSDebug,
      bool sockJSNoCredentials,
      List<String> sockJSProtocolsWhitelist,
      Duration sockJSTimeout,
      bool useSockJS}) {
    sockJSDebug = sockJSDebug ?? _sockJSDebug;
    sockJSNoCredentials = sockJSNoCredentials ?? _sockJSNoCredentials;
    sockJSProtocolsWhitelist =
        sockJSProtocolsWhitelist ?? _sockJSProtocolsWhitelist;
    sockJSTimeout = sockJSTimeout ?? _sockJSTimeout;
    useSockJS = useSockJS ?? _useSockJS;

    if (useSockJS) {
      return SockJSWebSocket.connect(uri,
          debug: sockJSDebug,
          noCredentials: sockJSNoCredentials,
          protocolsWhitelist: sockJSProtocolsWhitelist,
          timeout: sockJSTimeout);
    } else {
      return BrowserWebSocket.connect(uri,
          protocols: protocols, headers: headers);
    }
  }
}
