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

library w_transport.src.mocks.mock_transports;

import 'dart:async';

import 'package:http_parser/http_parser.dart' show CaseInsensitiveMap;

import 'package:w_transport/src/constants.dart' show v3Deprecation;
import 'package:w_transport/src/http/base_request.dart' show BaseRequest;
import 'package:w_transport/src/http/finalized_request.dart'
    show FinalizedRequest;
import 'package:w_transport/src/http/mock/base_request.dart'
    show MockBaseRequest; // ignore: deprecated_member_use
import 'package:w_transport/src/http/mock/response.dart' show MockResponse;
import 'package:w_transport/src/http/response.dart' show BaseResponse;
import 'package:w_transport/src/web_socket/mock/w_socket.dart'
    show MockWSocket; // ignore: deprecated_member_use
import 'package:w_transport/src/web_socket/w_socket.dart'
    show WSocket; // ignore: deprecated_member_use
import 'package:w_transport/src/web_socket/web_socket.dart' show WebSocket;
import 'package:w_transport/src/web_socket/web_socket_exception.dart'
    show WebSocketException;

part 'package:w_transport/src/mocks/mock_http.dart';
part 'package:w_transport/src/mocks/mock_web_socket.dart';
part 'package:w_transport/src/mocks/mock_web_socket_server.dart';

class MockTransports {
  static const MockHttp http = const MockHttp();
  static const MockWebSockets webSocket = const MockWebSockets();

  /// Install mocking logic & controls for all transports. This will effectively
  /// wrap all [BaseRequest], [HttpClient], and [WebSocket] instances in a
  /// mocking layer. Expectations and handlers can be registered via the
  /// [MockTransports] API.
  ///
  /// If [fallThrough] is true, any HTTP request that is sent and any WebSocket
  /// that is opened will fall through to the configured [TransportPlatform] if
  /// a mock expectation or handler is not set up to handle it. This enables
  /// selective mocking - certain requests or WebSockets can be mocked while
  /// the rest will be handled by a real transport platform.
  static void install({bool fallThrough: false}) {
    MockTransportsInternal.isInstalled = true;
    MockTransportsInternal.fallThrough = fallThrough ?? false;
  }

  static Future<Null> reset() {
    http.reset();
    webSocket.reset();
    return new Future.value();
  }

  static Future<Null> uninstall() async {
    await reset();
    MockTransportsInternal.isInstalled = false;
  }

  static void verifyNoOutstandingExceptions() {
    http.verifyNoOutstandingExceptions();
  }
}

class MockTransportsInternal {
  static bool fallThrough = true;
  static bool isInstalled = false;
}
