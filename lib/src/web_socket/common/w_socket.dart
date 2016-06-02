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
import 'package:w_transport/src/web_socket/w_socket_subscription.dart';

abstract class CommonWSocket extends Stream implements WSocket {
  /// The close code set when the WebSocket connection is closed. If there is
  /// no close code available this property will be `null`.
  int closeCode;

  /// The close reason set when the WebSocket connection is closed. If there is
  /// no close reason available this property will be `null`.
  String closeReason;

  bool isClosed = false;

  StreamSubscription webSocketSubscription;

  Completer<Null> _allClosed = new Completer();
  Completer<Null> _done = new Completer();
  var _error;
  StreamController _incoming;
  bool _isIncomingClosed = false;
  bool _isOutgoingClosed = false;
  StreamController _outgoing;
  StackTrace _stackTrace;
  WSocketSubscription _incomingSubscription;

  CommonWSocket() {
    _allClosed.future.then((_) {
      if (_incomingSubscription?.doneHandler != null) {
        _incomingSubscription.doneHandler();
      }

      if (_error != null) {
        _done.completeError(_error, _stackTrace);
      } else {
        _done.complete();
      }
    });

    // Outgoing communication will be handled by this stream controller.
    _outgoing = new StreamController();
    _outgoing.stream.listen(onOutgoingData,
        onError: onOutgoingError, onDone: onOutgoingDone);

    // Map events from the underlying socket to the incoming controller.
    // It is important to have handlers for start/stop/pause/resume so that the
    // controller properly respects the StreamSubscription API.
    _incoming = new StreamController(
        onListen: onIncomingListen,
        onPause: onIncomingPause,
        onResume: onIncomingResume,
        onCancel: onIncomingCancel);
  }

  /// Future that resolves when this WebSocket connection has completely closed.
  Future get done => _done.future;

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
  void add(data) {
    validateOutgoingData(data);
    _outgoing.add(data);
  }

  /// Add an error to the sink. This will cause the WebSocket connection to close.
  void addError(errorEvent, [StackTrace stackTrace]) {
    _outgoing.addError(errorEvent, stackTrace);
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
    return _outgoing.addStream(stream);
  }

  /// Closes the WebSocket connection. Optionally set [code] and [reason]
  /// to send close information to the remote peer.
  Future close([int code, String reason]) {
    shutDown(code: code, reason: reason);
    return done;
  }

  StreamSubscription listen(void onData(event),
      {Function onError, void onDone(), bool cancelOnError}) {
    var sub = _incoming.stream
        .listen(onData, onError: onError, cancelOnError: cancelOnError);
    _incomingSubscription = new WSocketSubscription(sub, onDone, onCancel: () {
      _incomingSubscription = null;
      return done;
    });
    return _incomingSubscription;
  }

  Future onIncomingCancel() async {
    webSocketSubscription.cancel();
    return _incoming.close();
  }

  void onIncomingData(data) {
    // Pipe messages from the socket through to the stream, but only if a
    // listener has been registered and is not paused. Otherwise we risk leaking
    // resources by adding events to the controller that may be buffered
    // indefinitely.
    if (!_incoming.isPaused && !_incoming.isClosed) {
      _incoming.add(data);
    }
  }

  void onIncomingDone() {
    isClosed = true;

    // Now that the socket has closed, capture the close code and reason.
    _isIncomingClosed = true;

    if (_isOutgoingClosed) {
      _allClosed.complete();
    } else {
      _outgoing.close().catchError((_) {});
    }
  }

  void onOutgoingDone() {
    _isOutgoingClosed = true;
    if (_isIncomingClosed) {
      _allClosed.complete();
    }

    // No need to close the socket here because [shutDown] handles that, and
    // the sink would only ever close as a result of [shutDown] being called,
    // which happens when
    // - [addError] is called
    // - [close] is called
    // - the sink receives an error during a call to [addStream]
  }

  void onOutgoingError(error, [StackTrace stackTrace]) {
    // Don't pass the error on to the socket. It will cause the socket to close
    // anyway, so we will preempt this and handle the shut down by ourselves.
    // This allows us to prevent the error from propagating to the root zone
    // where it cannot be caught.
    shutDown(error: error, stackTrace: stackTrace);
  }

  void shutDown({int code, error, String reason, StackTrace stackTrace}) {
    if (isClosed) return;
    isClosed = true;

    // Store the error and stack trace. When everything has finished closing,
    // they will be indicators that the socket connection closed with an error.
    _error = error;
    _stackTrace = stackTrace;

    // Close both incoming and outgoing communication.
    _outgoing.close();
    closeWebSocket(code, reason);
  }

  void closeWebSocket(int code, String reason);

  void onIncomingError(error, [StackTrace stackTrace]);

  void onIncomingListen();

  void onIncomingPause();

  void onIncomingResume();

  void onOutgoingData(data);

  void validateOutgoingData(Object data);
}
