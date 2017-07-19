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
import 'package:w_transport/src/constants.dart' show v3Deprecation;
import 'package:w_transport/src/transport_platform.dart';
import 'package:w_transport/src/web_socket/browser/sockjs.dart';
import 'package:w_transport/src/web_socket/browser/web_socket.dart';
import 'package:w_transport/src/web_socket/web_socket.dart';

const BrowserTransportPlatformWithSockJS browserTransportPlatformWithSockJS =
    const BrowserTransportPlatformWithSockJS();

class BrowserTransportPlatformWithSockJS extends BrowserTransportPlatform
    implements TransportPlatform {
  final bool _sockJSDebug;
  final bool _sockJSNoCredentials;
  final List<String> _sockJSProtocolsWhitelist;
  final Duration _sockJSTimeout;

  const BrowserTransportPlatformWithSockJS(
      {bool sockJSNoCredentials: false,
      bool sockJSDebug: false,
      List<String> sockJSProtocolsWhitelist,
      Duration sockJSTimeout})
      : _sockJSDebug = sockJSDebug == true,
        _sockJSProtocolsWhitelist = sockJSProtocolsWhitelist,
        _sockJSNoCredentials = sockJSNoCredentials == true,
        _sockJSTimeout = sockJSTimeout;

  bool get sockJSDebug => _sockJSDebug;
  bool get sockJSNoCredentials => _sockJSNoCredentials;
  List<String> get sockJSProtocolsWhitelist => _sockJSProtocolsWhitelist != null
      ? new List.from(_sockJSProtocolsWhitelist)
      : null;
  Duration get sockJSTimeout => _sockJSTimeout;

  /// Construct a [WebSocket] instance that leverages SockJS for use in the
  /// browser.
  @override
  Future<WebSocket> newWebSocket(Uri uri,
      {Map<String, dynamic> headers,
      Iterable<String> protocols,
      @Deprecated(v3Deprecation) bool sockJSDebug,
      @Deprecated(v3Deprecation) bool sockJSNoCredentials,
      @Deprecated(v3Deprecation) List<String> sockJSProtocolsWhitelist,
      @Deprecated(v3Deprecation) Duration sockJSTimeout,
      @Deprecated(v3Deprecation) bool useSockJS}) {
    // TODO: remove this backwards-compat logic in v4 when deprecated SockJS params are removed.
    // If consumers are still using the sockJS optional params to configure
    // WebSockets instead of a TransportPlatform instance, we need to respect
    // that for backwards compatibility.

    // If useSockJS is for some reason disabled, revert to standard WebSocket.
    // ignore: deprecated_member_use
    if (useSockJS == false) {
      return BrowserWebSocket.connect(uri,
          headers: headers, protocols: protocols);
    }

    // Otherwise, use the given sockJS params if given and fallback to the
    // settings configured with this TransportPlatform instance.
    return SockJSWebSocket.connect(uri,
        // ignore: deprecated_member_use
        debug: sockJSDebug ?? _sockJSDebug,
        // ignore: deprecated_member_use
        noCredentials: sockJSNoCredentials ?? _sockJSNoCredentials,
        protocolsWhitelist:
            // ignore: deprecated_member_use
            sockJSProtocolsWhitelist ?? _sockJSProtocolsWhitelist,
        // ignore: deprecated_member_use
        timeout: sockJSTimeout ?? _sockJSTimeout);
  }
}
