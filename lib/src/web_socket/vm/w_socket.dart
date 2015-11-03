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
import 'package:w_transport/src/web_socket/w_socket_close_event.dart';
import 'package:w_transport/src/web_socket/w_socket_exception.dart';

class VMWSocket extends CommonWSocket implements WSocket {
  static Future<WSocket> connect(Uri uri,
      {Iterable<String> protocols, Map<String, dynamic> headers}) async {
    WebSocket socket;
    try {
      socket = await WebSocket.connect(uri.toString(),
          protocols: protocols, headers: headers);
    } on SocketException catch (e) {
      throw new WSocketException(e.toString());
    }

    return new VMWSocket._(socket);
  }

  /// The underlying [WebSocket] instance.
  WebSocket _socket;

  /// Subscription to the incoming web socket data. Will be mapped to
  /// the incoming stream controller.
  StreamSubscription _socketSubscription;

  VMWSocket._(WebSocket this._socket) : super() {
    // The outgoing communication will be handled by this stream controller.
    // The sink from this controller will be used by [add] and [addStream].
    outgoing = new StreamController();
    outgoing.stream.listen((message) {
      // Pipe messages through to the underlying socket.
      _socket.add(message);
    }, onError: handleOutgoingError, onDone: handleOutgoingDone);

    // The incoming communication will be handled by mapping a stream
    // controller to a subscription to the underlying socket.
    _socketSubscription = _socket.listen(
        (data) {
          // Pipe messages from the socket through to the stream.
          incoming.add(data);
        },
        onError: handleSocketError,
        onDone: () {
          // Now that the socket has closed, capture the close code and reason.
          var closeEvent =
              new WSocketCloseEvent(_socket.closeCode, _socket.closeReason);
          handleSocketDone(closeEvent);
        });

    // Map the incoming controller to this subscription to the web socket.
    incoming = new StreamController(
        onListen: _socketSubscription.resume,
        onPause: _socketSubscription.pause,
        onResume: _socketSubscription.resume);
  }

  @override
  void closeSocket(int code, String reason) {
    _socket.close(code, reason);
  }

  /// Validate the WebSocket message data type. For server-side messages,
  /// [String] and [List<int>] are valid types.
  ///
  /// Throws an [ArgumentError] if [data] is invalid.
  @override
  void validateDataType(Object data) {
    if (data is! String && data is! List<int>) {
      throw new ArgumentError(
          'WSocket data type must be a String or a List<int>.');
    }
  }
}
