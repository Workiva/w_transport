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

import 'package:w_transport/src/mocks/mock_transports.dart'
    show MockWebSocketInternal;
import 'package:w_transport/src/web_socket/common/web_socket.dart';
import 'package:w_transport/src/web_socket/web_socket.dart';

abstract class MockWebSocket implements WebSocket {
  factory MockWebSocket() => _MockWebSocket();

  static Future<WebSocket> connect(Uri uri,
          {Map<String, dynamic> headers, Iterable<String> protocols}) =>
      MockWebSocketInternal.handleWebSocketConnection(uri,
          headers: headers, protocols: protocols);

  /// Simulate an incoming message that the owner of this [WSocket] instance
  /// will receive if listening.
  void addIncoming(dynamic data);

  /// Register a callback that will be called for every outgoing data event that
  /// the owner of this [WSocket] instance adds.
  ///
  /// [data] will either be the single data item or the stream, depending on
  /// whether `add()` or `addStream()` was called.
  void onOutgoing(callback(dynamic data));
}

class _MockWebSocket extends CommonWebSocket
    implements MockWebSocket, WebSocket {
  /// List of "onOutgoing" callbacks that have been registered. Any time a piece
  /// of data is added to the mock [WSocket], all callbacks in this list will be
  /// called with said data, allowing them to react and mock out the server.
  List<Function> _callbacks = [];

  /// The mock underlying WebSocket. Events are added manually via the
  /// [MockWebSocket] api.
  StreamController<dynamic> _mocket = StreamController<dynamic>();

  _MockWebSocket() : super() {
    webSocketSubscription = _mocket.stream.listen(onIncomingData);
  }

  @override
  void addIncoming(dynamic data) {
    _mocket.add(data);
  }

  @override
  void onOutgoing(callback(dynamic data)) {
    _callbacks.add(callback);
  }

  @override
  void closeWebSocket(int code, String reason) {
    closeCode = code;
    closeReason = reason;
    _mocket.close().then((_) {
      onIncomingDone();
    });
  }

  @override
  void onIncomingListen() {
    // With the mock WebSocket, we listen to the mock stream immediately, so
    // there's nothing to do here.
  }

  @override
  void onIncomingPause() {
    // With the mock WebSocket, we are always listening to the WebSocket stream.
    // Traditionally when a stream subscription is paused, the producer of
    // events should stop producing events to avoid buffering that could lead to
    // a memory leak. Instead of doing that, we check the status of the
    // subscription to this [WSocket] instance whenever an event is dispatched
    // and discard said event if it's paused. This is effectively the same.
  }

  @override
  void onIncomingResume() {
    // See the note in [onIncomingPause]. We don't actually pause the
    // subscription to the mock WebSocket, so there's no need to resume it here.
  }

  @override
  void onOutgoingData(dynamic data) {
    for (final callback in _callbacks) {
      callback(data);
    }
  }

  @override
  void validateOutgoingData(Object data) {
    // Since this is a mock, we cannot make assumptions about which data types
    // are valid.
  }
}
