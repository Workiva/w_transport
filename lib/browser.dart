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

/// Transport for the browser. Exposes a single configuration method that must
/// be called before instantiating any of the transport classes.
///
///     import 'package:w_transport/browser.dart'
///         show configureWTransportForBrowser;
///
///     void main() {
///       configureWTransportForBrowser();
///     }
///
/// If you'd like WebSocket to fall back to XHR-streaming if native WebSockets
/// are not available, w_transport can be configured to use a SockJS client.
///
///     import 'package:w_transport/browser.dart'
///         show configureWTransportForBrowser;
///
///     void main() {
///       configureWTransportForBrowser(
///           useSockJS: true,
///           sockJSProtocolsWhitelist: ['websocket', 'xhr-streaming']);
///     }
library w_transport.browser;

import 'package:w_transport/src/browser_transport_platform.dart';
import 'package:w_transport/src/browser_transport_platform_with_sockjs.dart';
import 'package:w_transport/src/constants.dart' show v3Deprecation;
import 'package:w_transport/src/global_transport_platform.dart';

export 'package:w_transport/src/browser_transport_platform.dart'
    show BrowserTransportPlatform, browserTransportPlatform;
export 'package:w_transport/src/browser_transport_platform_with_sockjs.dart'
    show BrowserTransportPlatformWithSockJS, browserTransportPlatformWithSockJS;

/// Configures w_transport for use in the browser via dart:html.
void configureWTransportForBrowser(
    {@Deprecated(v3Deprecation) bool useSockJS: false,
    @Deprecated(v3Deprecation) bool sockJSDebug: false,
    @Deprecated(v3Deprecation) bool sockJSNoCredentials: false,
    @Deprecated(v3Deprecation) List<String> sockJSProtocolsWhitelist}) {
  // Configuring SockJS at this level is deprecated. SockJS configuration should
  // occur on a per-socket basis.
  // ignore: deprecated_member_use
  if (useSockJS == true) {
    print('Deprecation Warning: Configuring all w_transport sockets to use '
        'SockJS is deprecated. Instead, SockJS usage should be configured on a '
        'per-socket basis via the optional parameters in WSocket.connect().');
  }

  // ignore: deprecated_member_use
  if (useSockJS == true) {
    globalTransportPlatform = new BrowserTransportPlatformWithSockJS(
        // ignore: deprecated_member_use
        sockJSNoCredentials: sockJSNoCredentials,
        // ignore: deprecated_member_use
        sockJSDebug: sockJSDebug,
        // ignore: deprecated_member_use
        sockJSProtocolsWhitelist: sockJSProtocolsWhitelist);
  } else {
    globalTransportPlatform = browserTransportPlatform;
  }
}
