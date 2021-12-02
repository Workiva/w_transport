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

/// Transport for the browser.
///
/// Before instantiating any of the transport classes, the transport platform
/// should be configured. For simple use cases, use
/// [configureWTransportForBrowser]:
///
///     import 'package:w_transport/browser.dart'
///         show configureWTransportForBrowser;
///
///     void main() {
///       configureWTransportForBrowser();
///     }
///
/// This is equivalent to:
///
///     globalTransportPlatform = browserTransportPlatform;
///
/// Or, if you'd like to use SockJS for WebSocket transports:
///
///     globalTransportPlatform = browserTransportPlatformWithSockJS;
///
/// You may also build your own configurations.
library w_transport.browser;

import 'package:w_transport/src/browser_transport_platform.dart';
import 'package:w_transport/src/global_transport_platform.dart';

export 'package:w_transport/src/browser_transport_platform.dart'
    show BrowserTransportPlatform, browserTransportPlatform;
export 'package:w_transport/src/browser_transport_platform_with_sockjs.dart'
    show BrowserTransportPlatformWithSockJS, browserTransportPlatformWithSockJS;
export 'package:w_transport/src/web_socket/browser/sockjs.dart'
    show MissingSockJSException;

/// Configures w_transport for use in the browser via dart:html.
void configureWTransportForBrowser() {
  globalTransportPlatform = browserTransportPlatform;
}
