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

library w_transport.src.web_socket.common.w_socket;

import 'dart:async';

import 'package:w_transport/src/web_socket/w_socket.dart';

abstract class CommonWSocket extends Stream implements WSocket {
  /// The close code set when the WebSocket connection is closed. If there is
  /// no close code available this property will be `null`.
  int closeCode;

  /// The close reason set when the WebSocket connection is closed. If there is
  /// no close reason available this property will be `null`.
  String closeReason;

  /// Whether or not the web socket is in the process of closing (or already has
  /// closed). This prevents duplicate behavior if [close] is called multiple
  /// times.
  bool _closed = false;

  CommonWSocket() {
    done.whenComplete(() {
      _closed = true;
    });
  }

  StreamSink get sink;

  Stream get stream;

  /// Sends a message over the WebSocket connection.
  ///
  /// This accepts a variety of data types, depending on the platform.
  /// In the browser:
  ///   - Blob
  ///   - ByteBuffer
  ///   - String
  ///   - TypedData
  /// On the server:
  ///   - String
  ///   - List<int>
  void add(message) {
    validateDataType(message);
    sink.add(message);
  }

  /// Add an error to the sink. This will cause the WebSocket connection to close.
  void addError(errorEvent, [StackTrace stackTrace]) {
    sink.addError(errorEvent, stackTrace);
  }

  /// Adds a stream of data to send over the WebSocket connection.
  /// This will wait for the stream to complete, sending each element
  /// as it is received.
  ///
  /// See [send] for the list of accepted types of data from the stream.
  ///
  /// Sending additional data before this stream has completed may
  /// result in a [StateError].
  Future addStream(Stream stream) async {
    await sink.addStream(stream);
  }

  /// Closes the WebSocket connection. Optionally set [code] and [reason]
  /// to send close information to the remote peer.
  Future close([int code, String reason]) {
    if (_closed) return done;
    _closed = true;
    closeConnection(code, reason);
    sink.close();
    return done;
  }

  /// Close the WebSocket connection if one has been established.
  Future closeConnection([int code, String reason]);

  StreamSubscription listen(void onData(event),
      {Function onError, void onDone(), bool cancelOnError}) {
    if (onDone != null) {
      done.then((_) => onDone());
    }
    return stream.listen(onData,
        onError: onError, cancelOnError: cancelOnError);
  }

  /// Validate the data type of the message being sent. Throws an ArgumentError
  /// if [message] is of invalid type.
  void validateDataType(message);
}
