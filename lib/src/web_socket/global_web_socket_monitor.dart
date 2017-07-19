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

  Stream<WebSocketConnectEvent> get didAttemptToConnect =>
      _didAttemptToConnect.stream;

  GlobalWebSocketMonitor._() {
    _monitors.add(this);
  }

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
