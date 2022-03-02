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

import 'package:w_transport/src/browser_transport_platform.dart';
import 'package:w_transport/src/transport_platform.dart';
import 'package:w_transport/src/web_socket/browser/sockjs.dart';
import 'package:w_transport/src/web_socket/web_socket.dart';

const BrowserTransportPlatformWithSockJS browserTransportPlatformWithSockJS =
    BrowserTransportPlatformWithSockJS();

class BrowserTransportPlatformWithSockJS extends BrowserTransportPlatform
    implements TransportPlatform {
  final bool _sockJSDebug;
  final bool _sockJSNoCredentials;
  final List<String> _sockJSProtocolsWhitelist;
  final Duration _sockJSTimeout;

  const BrowserTransportPlatformWithSockJS(
      {bool sockJSNoCredentials,
      bool sockJSDebug,
      List<String> sockJSProtocolsWhitelist,
      Duration sockJSTimeout})
      : _sockJSDebug = sockJSDebug ?? false,
        _sockJSProtocolsWhitelist = sockJSProtocolsWhitelist,
        _sockJSNoCredentials = sockJSNoCredentials ?? false,
        _sockJSTimeout = sockJSTimeout;

  bool get sockJSDebug => _sockJSDebug;
  bool get sockJSNoCredentials => _sockJSNoCredentials;
  List<String> get sockJSProtocolsWhitelist => _sockJSProtocolsWhitelist != null
      ? List.from(_sockJSProtocolsWhitelist)
      : null;
  Duration get sockJSTimeout => _sockJSTimeout;

  /// Construct a [WebSocket] instance that leverages SockJS for use in the
  /// browser.
  @override
  Future<WebSocket> newWebSocket(Uri uri,
          {Map<String, dynamic> headers, Iterable<String> protocols}) =>
      SockJSWebSocket.connect(uri,
          debug: sockJSDebug ?? _sockJSDebug,
          noCredentials: sockJSNoCredentials ?? _sockJSNoCredentials,
          protocolsWhitelist:
              sockJSProtocolsWhitelist ?? _sockJSProtocolsWhitelist,
          timeout: sockJSTimeout ?? _sockJSTimeout);
}
