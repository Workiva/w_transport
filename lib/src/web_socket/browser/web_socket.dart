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
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:w_transport/src/web_socket/common/web_socket.dart';
import 'package:w_transport/src/web_socket/global_web_socket_monitor.dart';
import 'package:w_transport/src/web_socket/web_socket.dart';
import 'package:w_transport/src/web_socket/web_socket_exception.dart';

/// Implementation of the platform-dependent pieces of the [WebSocket] class for
/// the browser. This class uses native WebSockets.
class BrowserWebSocket extends CommonWebSocket implements WebSocket {
  /// The underlying native WebSocket.
  html.WebSocket _webSocket;

  BrowserWebSocket._(this._webSocket, Future<html.CloseEvent> webSocketClosed)
      : super() {
    webSocketSubscription = _webSocket.onMessage.listen((messageEvent) {
      onIncomingData(messageEvent.data);
    });
    webSocketClosed.then((closeEvent) {
      closeCode = closeEvent.code;
      closeReason = closeEvent.reason;
      onIncomingDone();
    });
  }

  static Future<WebSocket> connect(Uri uri,
      {Map<String, dynamic> headers, Iterable<String> protocols}) async {
    // Establish a Web Socket connection.
    final webSocket = new html.WebSocket(uri.toString(), protocols);
    if (webSocket == null) {
      throw new WebSocketException('Could not connect to $uri');
    }

    // Listen for and store the close event. This will determine whether or
    // not the socket connected successfully, and will also be used later
    // to handle the web socket closing.
    final closedFuture = webSocket.onClose.first;

    // Will complete if the socket successfully opens, or complete with
    // an error if the socket moves straight to the closed state.
    final connected = new Completer<Null>();
    // ignore: unawaited_futures
    webSocket.onOpen.first.then((_) {
      connected.complete();
      emitWebSocketConnectEvent(
          newWebSocketConnectEvent(url: uri.toString(), wasSuccessful: true));
    });
    // ignore: unawaited_futures
    closedFuture.then((_) {
      if (!connected.isCompleted) {
        connected
            .completeError(new WebSocketException('Could not connect to $uri'));
        emitWebSocketConnectEvent(newWebSocketConnectEvent(
            url: uri.toString(), wasSuccessful: false));
      }
    });

    await connected.future;
    return new BrowserWebSocket._(webSocket, closedFuture);
  }

  @override
  void closeWebSocket(int code, String reason) {
    _webSocket.close(code, reason);
  }

  @override
  void onIncomingListen() {
    // In the browser with a native WebSocket, we listen to the WebSocket
    // immediately, so there's nothing to do here.
  }

  @override
  void onIncomingPause() {
    // In the browser with a native WebSocket, we are always listening to the
    // WebSocket. Traditionally when a stream subscription is paused, the
    // producer of events should stop producing events to avoid buffering that
    // could lead to a memory leak. Instead of doing that, we check the status
    // of the subscription to this [WSocket] instance whenever an event is
    // dispatched and discard said event if it's paused. This is effectively the
    // same.
  }

  @override
  void onIncomingResume() {
    // See the note in [onIncomingPause]. We don't actually pause the
    // subscription to the WebSocket, so there's no need to resume it here.
  }

  @override
  void onOutgoingData(dynamic data) {
    // Pipe messages through to the underlying socket.
    _webSocket.send(data);
  }

  @override
  void validateOutgoingData(Object data) {
    if (data is! html.Blob &&
        data is! ByteBuffer &&
        data is! String &&
        data is! TypedData) {
      throw new ArgumentError(
          'WSocket data type must be a String, Blob, ByteBuffer, or an instance of TypedData.');
    }
  }
}
