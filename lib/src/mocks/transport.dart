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

library w_transport.src.mocks.transport;

import 'package:w_transport/src/mocks/http.dart';
import 'package:w_transport/src/mocks/web_socket.dart';

class MockTransports {
  static const MockHttp http = const MockHttp();
  static const MockWebSocket webSocket = const MockWebSocket();

  static void reset() {
    http.reset();
    webSocket.reset();
  }

  static void verifyNoOutstandingExceptions() {
    http.verifyNoOutstandingExceptions();
  }
}
