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

import 'package:w_transport/src/global_transport_platform.dart';
import 'package:w_transport/src/http/client.dart';
import 'package:w_transport/src/mocks/mock_transports.dart'
    show MockTransportsInternal;
import 'package:w_transport/src/transport_platform.dart';

/// An HTTP client acts as a single point from which many requests can be
/// constructed. All requests constructed from a client will inherit [headers],
/// the [withCredentials] flag, and the [timeoutThreshold].
///
/// On the server, the Dart VM will also be able to take advantage of cached
/// network connections between requests that share a client.
// ignore: deprecated_member_use
abstract class HttpClient extends Client {
  factory HttpClient({TransportPlatform transportPlatform}) {
    // If a transport platform is not explicitly given, fallback to the globally
    // configured platform.
    transportPlatform ??= globalTransportPlatform;

    if (MockTransportsInternal.isInstalled) {
      // If transports are mocked, return a mock HttpClient instance. This
      // mock instance will construct mock-aware BaseRequest and WebSocket
      // instances that will be able to decide at the time of dispatch
      // whether or not the mock logic should be used.
      return MockAwareTransportPlatform.newHttpClient(transportPlatform);
    } else if (transportPlatform != null) {
      // Otherwise, return a real instance using the given transport platform.
      return transportPlatform.newHttpClient();
    } else {
      // If transports are not mocked and a transport platform is not available
      // (neither explicitly given nor configured globally), then we cannot
      // successfully construct an HttpClient.
      throw new TransportPlatformMissing.httpClientFailed();
    }
  }
}
