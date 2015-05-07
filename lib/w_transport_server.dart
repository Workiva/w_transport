/*
 * Copyright 2015 Workiva Inc.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

/// Transport for the server. Calling [configureWTransportForServer] will configure
/// w_transport for server-side use. All HTTP-related classes will use [HttpClient],
/// [HttpClientRequest], and [HttpClientResponse] to make HTTP requests.
library w_transport.w_transport_server;

import 'src/http/w_http_server.dart' show configureWHttpForServer;

/// Configure w_transport for use on the server.
///
/// Must be called before using any of the transport classes.
///
///     import 'package:w_transport/w_transport_server.dart'
///         show configureWTransportForServer;
///
///     void main() {
///       configureWTransportForServer();
///     }
void configureWTransportForServer() {
  configureWHttpForServer();
}