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

/// Easily mock out the platform-specific details of w_transport. Exposes a
/// single configuration method that must be called before instantiating any of
/// the transport classes.
///
///     import 'package:w_transport/mock.dart'
///         show configureWTransportForTest;
///
///     void main() {
///       configureWTransportForTest();
///     }
library w_transport.mock;

import 'package:w_transport/src/mocks/mock_transports.dart' show MockTransports;

export 'package:w_transport/src/http/finalized_request.dart'
    show FinalizedRequest;
export 'package:w_transport/src/http/mock/base_request.dart'
    show MockBaseRequest; // ignore: deprecated_member_use
export 'package:w_transport/src/http/mock/client.dart' show MockClient;
export 'package:w_transport/src/http/mock/requests.dart'
    show
        MockFormRequest, // ignore: deprecated_member_use
        MockJsonRequest, // ignore: deprecated_member_use
        MockPlainTextRequest, // ignore: deprecated_member_use
        MockStreamedRequest; // ignore: deprecated_member_use
export 'package:w_transport/src/http/mock/response.dart'
    show MockResponse, MockStreamedResponse;

export 'package:w_transport/src/mocks/mock_transports.dart'
    show
        MockHttpHandler,
        MockTransports,
        MockWebSocketConnection,
        MockWebSocketHandler,
        MockWebSocketServer,
        PatternRequestHandler,
        RequestHandler,
        WebSocketConnectHandler,
        WebSocketPatternConnectHandler;

export 'package:w_transport/src/web_socket/mock/w_socket.dart'
    show MockWSocket; // ignore: deprecated_member_use

/// Configure w_transport for use in tests, allowing you to easily mock out the
/// behavior of the w_transport classes.
void configureWTransportForTest() {
  // The previous behavior of mocked requests/WebSockets is that they would
  // enter a "pending" queue if there were no expectations/handlers set up to
  // handle them. Then the `verifyNoOutstandingExceptions()` method would throw
  // if that "pending" queue was not empty.
  //
  // Enabling fall-through breaks this behavior because requests/WebSockets
  // without an expectation/handler will result in a switch to a real instance
  // which would throw if no other TransportPlatform instance is configured.
  //
  // So, for backwards compatibility, we disable fall-through.
  MockTransports.install(fallThrough: false);
}
