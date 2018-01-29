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
import 'dart:js' as js;

import 'package:w_transport/src/web_socket/browser/sockjs_port.dart';
import 'package:w_transport/src/web_socket/browser/sockjs_wrapper.dart';
import 'package:w_transport/src/web_socket/common/web_socket.dart';
import 'package:w_transport/src/web_socket/web_socket.dart';

/// Implementation of the platform-dependent pieces of the [WebSocket] class for
/// the SockJS browser configuration. This class uses the SockJS library to
/// establish a WebSocket-like connection (could be a native WebSocket, could
/// be XHR-streaming).
abstract class SockJSWebSocket extends CommonWebSocket implements WebSocket {
  static Future<WebSocket> connect(Uri uri,
      {bool debug: false,
      bool noCredentials: false,
      List<String> protocolsWhitelist,
      Duration timeout}) async {
    // The SockJS wrapper library is preferred because it uses the actual JS lib
    // which is community-supported and fully-featured. But, it requires that
    // the sockjs.js file is included. We can check for that by checking for the
    // existence of a `SockJS` object on the window.
    if (js.context.hasProperty('SockJS')) {
      return SockJSWrapperWebSocket.connect(uri,
          debug: debug,
          noCredentials: noCredentials,
          protocolsWhitelist: protocolsWhitelist,
          timeout: timeout);
    }

    // If the sockjs.js file wasn't detected, then we fallback to the original
    // SockJS Dart port.
    return SockJSPortWebSocket.connect(uri,
        debug: debug,
        noCredentials: noCredentials,
        protocolsWhitelist: protocolsWhitelist,
        timeout: timeout);
  }
}
