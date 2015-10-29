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
///     import 'package:w_transport/w_transport_browser.dart'
///         show configureWTransportForBrowser;
///
///     void main() {
///       configureWTransportForBrowser();
///     }
library w_transport.w_transport_browser;

import 'package:w_transport/src/browser_adapter.dart';
import 'package:w_transport/src/platform_adapter.dart';

/// Configures w_transport for use in the browser via dart:html.
void configureWTransportForBrowser() {
  adapter = new BrowserAdapter();
}
