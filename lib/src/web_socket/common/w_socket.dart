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
import 'package:w_transport/src/web_socket/w_socket_close_event.dart';

abstract class CommonWSocket extends Stream implements WSocket {
  /// The close code set when the WebSocket connection is closed. If there is
  /// no close code available this property will be `null`.
  int closeCode;

  /// The close reason set when the WebSocket connection is closed. If there is
  /// no close reason available this property will be `null`.
  String closeReason;

  /// Incoming communication. Data from the web socket will be piped
  /// to this controller's sink. The stream will be exposed, allowing
  /// users to listen to the incoming data.
  StreamController incoming;

  /// Outgoing communication. Sink will be exposed, allowing users to
  /// add items to the outgoing stream.
  StreamController outgoing;

  /// Completer that will complete when the outgoing sink has finished closing
  /// and the socket connection has finished closing.
  Completer<Null> _allClosed = new Completer();

  /// The close event with close code and reason from the socket connection.
  /// Will only be populated once the socket has actually closed.
  WSocketCloseEvent _closeEvent;

  /// Completer that will complete when [_allClosed] has completed and the close
  /// code and reason have been set. If the socket closed due to an error, this
  /// will complete with an error. Otherwise, it will complete normally.
  Completer<Null> _done = new Completer();

  /// The error that was either added to the socket sink or received from the
  /// socket stream. This will only be populated if an error occurs.
  var _error;

  /// Whether or not the web socket is in the process of closing (or already has
  /// closed). This prevents duplicate behavior if [close] is called multiple
  /// times.
  bool _isClosed = false;

  /// Whether or not the outgoing sink has been closed.
  bool _isSinkClosed = false;

  /// Whether or not the incoming socket stream connection has been closed.
  bool _isSocketClosed = false;

  /// The stack trace from the error that was either added to the socket sink or
  /// received from the socket stream. This will only be populated if an error
  /// occurs.
  StackTrace _stackTrace;

  CommonWSocket() {
    // Wait for both the sink and the socket to finish closing before exposing
    // the close code, close reason, and completing the [_done] completer.
    // If the socket closed due to an error, the [_done] completer will be
    // completed with that error.
    _allClosed.future.then((_) {
      closeCode = _closeEvent.code;
      closeReason = _closeEvent.reason;
      _isClosed = true;
      if (_error != null) {
        _done.completeError(_error, _stackTrace);
      } else {
        _done.complete();
      }
    });
  }

  /// Future that resolves when this WebSocket connection has completely closed.
  Future get done => _done.future;

  /// The stream sink for outgoing messages.
  StreamSink get sink => outgoing.sink;

  /// The stream for incoming messages.
  Stream get stream => incoming.stream;

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
    shutDown(error: errorEvent, stackTrace: stackTrace);
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
    if (_isClosed) return done;
    _isClosed = true;
    shutDown(code: code, reason: reason);
    return done;
  }

  void closeSocket(int code, String reason);

  void handleOutgoingError(error, [StackTrace stackTrace]) {
    // Don't pass the error on to the socket. It will cause the socket to
    // close anyway, so we will preempt this and handle the shut down
    // by ourselves. This allows us to prevent the error from propagating to
    // the root zone where it cannot be caught.
    shutDown(error: error, stackTrace: stackTrace);
  }

  void handleOutgoingDone() {
    _isSinkClosed = true;
    if (_isSocketClosed) {
      _allClosed.complete();
    }

    // No need to close the socket here because [shutDown] handles that, and
    // the sink would only ever close as a result of [shutDown] being called,
    // which happens when
    // - [addError] is called
    // - [close] is called
    // - the sink receives an error during a call to [addStream]
  }

  void handleSocketError(error, [StackTrace stackTrace]) {
    shutDown(error: error, stackTrace: stackTrace);
  }

  void handleSocketDone(WSocketCloseEvent closeEvent) {
    _closeEvent = closeEvent;

    _isSocketClosed = true;
    if (_isSinkClosed) {
      _allClosed.complete();
    } else {
      outgoing.close().catchError((_) {});
    }
  }

  StreamSubscription listen(void onData(event),
      {Function onError, void onDone(), bool cancelOnError}) {
    if (onDone != null) {
      done.then((_) => onDone());
    }
    return stream.listen(onData,
        onError: onError, cancelOnError: cancelOnError);
  }

  /// Close the WebSocket connection if one has been established.
  void shutDown({int code, error, String reason, StackTrace stackTrace}) {
    // Store the error and stack trace. When everything has finished closing,
    // they will be indicators that the socket connection closed with an error.
    _error = error;
    _stackTrace = stackTrace;

    // Close both incoming and outgoing communication.
    closeSocket(code, reason);
    sink.close();
  }

  /// Validate the data type of the message being sent. Throws an ArgumentError
  /// if [message] is of invalid type.
  void validateDataType(message);
}
