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

import 'package:meta/meta.dart' show required;

List<GlobalWebSocketMonitor> _monitors = [];

void emitWebSocketConnectEvent(WebSocketConnectEvent connectEvent) {
  for (final monitor in _monitors) {
    monitor._didAttemptToConnect.add(connectEvent);
  }
}

GlobalWebSocketMonitor newGlobalWebSocketMonitor() =>
    new GlobalWebSocketMonitor._();

WebSocketConnectEvent newWebSocketConnectEvent(
        {@required String url,
        @required bool wasSuccessful,
        String sockJsSelectedProtocol,
        List<String> sockJsProtocolsWhitelist}) =>
    new WebSocketConnectEvent._(
        url: url,
        wasSuccessful: wasSuccessful,
        sockJsProtocolsWhitelist: sockJsProtocolsWhitelist,
        sockJsSelectedProtocol: sockJsSelectedProtocol);

class GlobalWebSocketMonitor {
  StreamController<WebSocketConnectEvent> _didAttemptToConnect =
      new StreamController<WebSocketConnectEvent>.broadcast();

  GlobalWebSocketMonitor._() {
    _monitors.add(this);
  }

  Stream<WebSocketConnectEvent> get didAttemptToConnect =>
      _didAttemptToConnect.stream;

  Future<Null> close() async {
    _monitors.remove(this);
    await _didAttemptToConnect.close();
  }
}

class WebSocketConnectEvent {
  final List<String> sockJsProtocolsWhitelist;
  final String sockJsSelectedProtocol;
  final String url;
  final bool wasSuccessful;

  WebSocketConnectEvent._(
      {@required this.url,
      @required this.wasSuccessful,
      this.sockJsProtocolsWhitelist,
      this.sockJsSelectedProtocol});
}
