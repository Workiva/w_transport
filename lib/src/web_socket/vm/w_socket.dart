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

library w_transport.src.web_socket.vm.w_socket;

import 'dart:async';
import 'dart:io';

import 'package:w_transport/src/web_socket/common/w_socket.dart';
import 'package:w_transport/src/web_socket/w_socket.dart';
import 'package:w_transport/src/web_socket/w_socket_exception.dart';
import 'package:w_transport/src/web_socket/global_web_socket_monitor.dart';

/// Implementation of the platform-dependent pieces of the [WSocket] class for
/// the Dart VM. This class uses native Dart WebSockets.
class VMWSocket extends CommonWSocket implements WSocket {
  static Future<WSocket> connect(Uri uri,
      {Iterable<String> protocols, Map<String, dynamic> headers}) async {
    // Note: closing this sink is handled by VMWSocket
    // ignore: close_sinks
    WebSocket webSocket;
    bool wasSuccessful;
    try {
      webSocket = await WebSocket.connect(uri.toString(),
          protocols: protocols, headers: headers);
      wasSuccessful = true;
    } on SocketException catch (e) {
      wasSuccessful = false;
      throw new WSocketException(e.toString());
    } finally {
      emitWebSocketConnectEvent(newWebSocketConnectEvent(
          url: uri.toString(), wasSuccessful: wasSuccessful));
    }

    return new VMWSocket._(webSocket);
  }

  /// The underlying native WebSocket.
  WebSocket _webSocket;

  VMWSocket._(this._webSocket) : super() {
    webSocketSubscription = _webSocket.listen(onIncomingData, onDone: () {
      closeCode = _webSocket.closeCode;
      closeReason = _webSocket.closeReason;
      onIncomingDone();
    });
  }

  @override
  void closeWebSocket(int code, String reason) {
    _webSocket.close(code, reason);
  }

  @override
  void onIncomingListen() {
    // On the VM, we listen to the WebSocket immediately, so there's nothing to
    // do here.
  }

  @override
  void onIncomingPause() {
    // On the VM, we are always listening to the WebSocket. Traditionally when
    // a stream subscription is paused, the producer of events should stop
    // producing events to avoid buffering that could lead to a memory leak.
    // Instead of doing that, we check the status of the subscription to this
    // [WSocket] instance whenever an event is dispatched and discard said event
    // if it's paused. This is effectively the same.
  }

  @override
  void onIncomingResume() {
    // See the note in [onIncomingPause]. We don't actually pause the
    // subscription to the WebSocket, so there's no need to resume it here.
  }

  @override
  void onOutgoingData(data) {
    // Pipe messages through to the underlying socket.
    _webSocket.add(data);
  }

  @override
  void validateOutgoingData(Object data) {
    if (data is! String && data is! List<int>) {
      throw new ArgumentError(
          'WSocket data type must be a String or a List<int>.');
    }
  }
}
