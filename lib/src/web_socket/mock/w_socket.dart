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

library w_transport.src.web_socket.mock.w_socket;

import 'dart:async';

import 'package:w_transport/src/mocks/web_socket.dart'
    show handleWebSocketConnection;
import 'package:w_transport/src/web_socket/common/w_socket.dart';
import 'package:w_transport/src/web_socket/w_socket.dart';

abstract class MockWSocket implements WSocket {
  static Future<WSocket> connect(Uri uri,
          {Iterable<String> protocols, Map<String, dynamic> headers}) =>
      handleWebSocketConnection(uri, protocols: protocols, headers: headers);

  factory MockWSocket() => new _MockWSocket();

  /// Simulate an incoming message that the owner of this [WSocket] instance
  /// will receive if listening.
  void addIncoming(data);

  /// Register a callback that will be called for every outgoing data event that
  /// the owner of this [WSocket] instance adds.
  ///
  /// [data] will either be the single data item or the stream, depending on
  /// whether `add()` or `addStream()` was called.
  void onOutgoing(callback(data));

  /// Cause the "server" to close, effectively severing the connection between
  /// the server and client.
  void triggerServerClose([int code, String reason]);

  /// Cause the "server" to add an error to the stream.
  ///
  /// In practice, this cannot happen. If an error is added to the stream on the
  /// server side, it will cause the connection to close, but it will not send
  /// the error and thus an error will not be received by the client. For this
  /// reason, this method has been deprecated. Use [triggerServerClose] instead.
  @Deprecated('in 3.0.0. Use triggerServerClose() instead.')
  void triggerServerError(error, [StackTrace stackTrace]);
}

class _MockWSocket extends CommonWSocket implements MockWSocket, WSocket {
  /// List of "onOutgoing" callbacks that have been registered. Any time a piece
  /// of data is added to the mock [WSocket], all callbacks in this list will be
  /// called with said data, allowing them to react and mock out the server.
  List<Function> _callbacks = [];

  /// The mock underlying WebSocket. Events are added manually via the
  /// [MockWSocket] api.
  StreamController _mocket = new StreamController();

  _MockWSocket() : super() {
    webSocketSubscription =
        _mocket.stream.listen(onIncomingData, onDone: onIncomingDone);
  }

  @override
  void addIncoming(data) {
    _mocket.add(data);
  }

  @override
  void onOutgoing(callback(data)) {
    _callbacks.add(callback);
  }

  @override
  void triggerServerClose([int code, String reason]) {
    close(code, reason);
  }

  void triggerServerError(error, [StackTrace stackTrace]) {
    close();
  }

  @override
  void closeWebSocket(int code, String reason) {
    closeCode = code;
    closeReason = reason;
    _mocket.close();
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
  void onOutgoingData(data) {
    _callbacks.forEach((f) => f(data));
  }

  @override
  void validateOutgoingData(Object data) {
    // Since this is a mock, we cannot make assumptions about which data types
    // are valid.
  }
}
