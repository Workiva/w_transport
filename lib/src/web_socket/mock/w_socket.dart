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
import 'package:w_transport/src/web_socket/w_socket_close_event.dart';

abstract class MockWSocket implements WSocket {
  static Future<WSocket> connect(Uri uri,
          {Iterable<String> protocols, Map<String, dynamic> headers}) =>
      handleWebSocketConnection(uri, protocols: protocols, headers: headers);

  factory MockWSocket() => new _MockWSocket();

  void addIncoming(data);
  void onOutgoing(callback(data));
  void triggerServerClose([int code, String reason]);
  void triggerServerError(error, [StackTrace stackTrace]);
}

class _MockWSocket extends CommonWSocket implements MockWSocket, WSocket {
  List<Function> _callbacks = [];

  int _code;

  StreamController _mocket = new StreamController();

  String _reason;

  _MockWSocket() : super() {
    outgoing = new StreamController();
    incoming = new StreamController();

    outgoing.stream.listen((data) {
      _callbacks.forEach((f) => f(data));
    }, onError: handleOutgoingError, onDone: handleOutgoingDone);

    _mocket.stream.listen(
        (message) {
          incoming.add(message);
        },
        onError: handleSocketError,
        onDone: () {
          var closeEvent = new WSocketCloseEvent(_code, _reason);
          handleSocketDone(closeEvent);
        });
  }

  /// Simulate an incoming message that the owner of this [WSocket] instance
  /// will receive if listening.
  void addIncoming(data) {
    _mocket.add(data);
  }

  @override
  void closeSocket(int code, String reason) {
    _code = code;
    _reason = reason;
    _mocket.close();
  }

  /// Register a callback that will be called for every outgoing data event that
  /// the owner of this [WSocket] instance adds.
  ///
  /// [data] will either be the single data item or the stream, depending on
  /// whether `add()` or `addStream()` was called.
  void onOutgoing(callback(data)) {
    _callbacks.add(callback);
  }

  void triggerServerClose([int code, String reason]) {
    closeSocket(code, reason);
  }

  void triggerServerError(error, [StackTrace stackTrace]) {
    _mocket.addError(error, stackTrace);
  }

  /// Validate the WebSocket message data type.
  void validateDataType(Object data) {
    // Since this is a mock, we cannot make assumptions about which data types
    // are valid.
  }
}
