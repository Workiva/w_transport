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

library w_transport.src.web_socket.browser.w_socket;

import 'dart:async';
import 'dart:html';
import 'dart:typed_data';

import 'package:w_transport/src/web_socket/common/w_socket.dart';
import 'package:w_transport/src/web_socket/w_socket.dart';
import 'package:w_transport/src/web_socket/w_socket_close_event.dart';
import 'package:w_transport/src/web_socket/w_socket_exception.dart';

class BrowserWSocket extends CommonWSocket implements WSocket {
  static Future<WSocket> connect(Uri uri,
      {Iterable<String> protocols, Map<String, dynamic> headers}) async {
    // Establish a Web Socket connection.
    WebSocket socket = new WebSocket(uri.toString(), protocols);
    if (socket == null) {
      throw new WSocketException('Could not connect to $uri');
    }

    // Listen for and store the close event. This will determine whether or
    // not the socket connected successfully, and will also be used later
    // to handle the web socket closing.
    Future<CloseEvent> closed = socket.onClose.first;

    // Will complete if the socket successfully opens, or complete with
    // an error if the socket moves straight to the closed state.
    Completer connected = new Completer();
    socket.onOpen.first.then(connected.complete);
    closed.then((_) {
      if (!connected.isCompleted) {
        connected
            .completeError(new WSocketException('Could not connect to $uri'));
      }
    });

    await connected.future;
    return new BrowserWSocket._(socket, closed);
  }

  /// The underlying [WebSocket] instance.
  WebSocket _socket;

  /// The close event Future from the [WebSocket] onClose stream.
  Future<CloseEvent> _socketClosed;

  BrowserWSocket._(
      WebSocket this._socket, Future<CloseEvent> this._socketClosed)
      : super() {
    // The outgoing communication will be handled by this stream controller.
    // The sink from this controller will be used by [add] and [addStream].
    outgoing = new StreamController();
    outgoing.stream.listen((message) {
      // Pipe messages through to the underlying socket.
      _socket.send(message);
    }, onError: handleOutgoingError, onDone: handleOutgoingDone);

    // Map events from the underlying socket to the incoming controller.
    incoming = new StreamController();
    _socket.onMessage.listen((messageEvent) {
      // Pipe messages from the socket through to the stream.
      incoming.add(messageEvent.data);
    });
    _socket.onError.listen(handleSocketError);
    _socketClosed.then((closeEvent) {
      // Now that the socket has closed, capture the close code and reason.
      var wCloseEvent =
          new WSocketCloseEvent(closeEvent.code, closeEvent.reason);
      handleSocketDone(wCloseEvent);
    });
  }

  @override
  void closeSocket(int code, String reason) {
    _socket.close(code, reason);
  }

  /// Validate the WebSocket message data type. For client-side messages,
  /// [Blob], [ByteBuffer], [String] and [TypedData] are valid types.
  ///
  /// Throws an [ArgumentError] if [data] is invalid.
  @override
  void validateDataType(Object data) {
    if (data is! Blob &&
        data is! ByteBuffer &&
        data is! String &&
        data is! TypedData) {
      throw new ArgumentError(
          'WSocket data type must be a String, Blob, ByteBuffer, or an instance of TypedData.');
    }
  }
}
