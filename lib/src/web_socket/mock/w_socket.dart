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

  void addIncoming(data);
  void onOutgoing(callback(data));
  void onOutgoingError(callback(error));
}

// TODO expose a public interface for this class to limit the API to what would only be useful for testing
class _MockWSocket extends CommonWSocket implements MockWSocket, WSocket {
  List<Function> _callbacks = [];

  Completer _done = new Completer();

  List<Function> _errorCallbacks = [];

  StreamController _sinkController = new StreamController();

  StreamController _streamController = new StreamController();

  _MockWSocket() {
    _sinkController.stream.listen((data) {
      _callbacks.forEach((f) => f(data));
    }, onError: (error) {
      _errorCallbacks.forEach((f) => f(error));
    });
  }

  StreamSink get sink => _sinkController.sink;

  Stream get stream => _streamController.stream;

  Future get done => _done.future;

  /// Simulate an incoming message that the owner of this [WSocket] instance
  /// will receive if listening.
  void addIncoming(data) {
    _streamController.add(data);
  }

  Future closeConnection([int code, String reason]) async {
    closeCode = code;
    closeReason = reason;
    _done.complete();
  }

  /// Register a callback that will be called for every outgoing data event that
  /// the owner of this [WSocket] instance adds.
  ///
  /// [data] will either be the single data item or the stream, depending on
  /// whether `add()` or `addStream()` was called.
  void onOutgoing(callback(data)) {
    _callbacks.add(callback);
  }

  void onOutgoingError(callback(error)) {
    _errorCallbacks.add(callback);
  }

  /// Validate the WebSocket message data type.
  void validateDataType(Object data) {
    // Since this is a mock, we cannot make assumptions about which data types
    // are valid.
  }
}
