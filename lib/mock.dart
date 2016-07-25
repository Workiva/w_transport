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

import 'package:w_transport/src/mock_adapter.dart';
import 'package:w_transport/src/platform_adapter.dart';

export 'package:w_transport/src/http/finalized_request.dart'
    show FinalizedRequest;
export 'package:w_transport/src/http/mock/base_request.dart'
    show MockBaseRequest;
export 'package:w_transport/src/http/mock/client.dart' show MockClient;
export 'package:w_transport/src/http/mock/requests.dart'
    show
        MockFormRequest,
        MockJsonRequest,
        MockPlainTextRequest,
        MockStreamedRequest;
export 'package:w_transport/src/http/mock/response.dart'
    show MockResponse, MockStreamedResponse;

export 'package:w_transport/src/mocks/http.dart'
    show MockHttpHandler, PatternRequestHandler, RequestHandler;
export 'package:w_transport/src/mocks/transport.dart' show MockTransports;
export 'package:w_transport/src/mocks/web_socket.dart'
    show MockWebSocketHandler;

export 'package:w_transport/src/web_socket/mock/w_socket.dart' show MockWSocket;

/// Configure w_transport for use in tests, allowing you to easily mock out the
/// behavior of the w_transport classes.
void configureWTransportForTest() {
  adapter = new MockAdapter();
}
