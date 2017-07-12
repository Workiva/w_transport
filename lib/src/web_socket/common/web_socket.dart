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

import 'package:w_transport/src/web_socket/web_socket.dart';
import 'package:w_transport/src/web_socket/w_socket_subscription.dart';

/// Implementation of the [WebSocket] class that is common across all platforms.
/// Platform-dependent pieces are left as unimplemented abstract members.
abstract class CommonWebSocket extends Stream implements WebSocket {
  /// The close code set when the WebSocket connection is closed. If there is
  /// no close code available this property will be `null`.
  @override
  int closeCode;

  /// The close reason set when the WebSocket connection is closed. If there is
  /// no close reason available this property will be `null`.
  @override
  String closeReason;

  /// Whether or not this [WebSocket] instance is closed or in the process of
  /// closing.
  bool isClosed = false;

  /// The subscription to the underlying WebSocket (either a browser WebSocket,
  /// VM WebSocket, SockJS Client, or a mock WebSocket).
  StreamSubscription webSocketSubscription;

  /// A completer that completes when both the outgoing stream sink and the
  /// incoming stream have been closed. This is used to determine when this
  /// [WebSocket] instance can be considered completely closed.
  Completer<Null> _allClosed = new Completer<Null>();

  /// A completer that completes when this [WebSocket] instance is completely
  /// "done" - both outgoing and incoming.
  Completer<Null> _done = new Completer<Null>();

  /// Any error that may be caught during the life of the underlying WebSocket.
  Object _error;

  /// A `StreamController` used to expose the incoming stream of events from the
  /// underlying WebSocket.
  StreamController<dynamic> _incoming;

  /// Whether or not the incoming stream of WebSocket events is closed.
  bool _isIncomingClosed = false;

  /// Whether or not the outgoing stream of WebSocket events is closed.
  bool _isOutgoingClosed = false;

  /// A `StreamController` used to pipe outgoing events to the underlying
  /// WebSocket.
  StreamController<dynamic> _outgoing;

  /// The stack trace for any error that may be caught during the life of the
  /// underlying WebSocket.
  StackTrace _stackTrace;

  /// The custom `StreamSubscription` that is used to proxy the subscription to
  /// the underlying WebSocket.
  WSocketSubscription _incomingSubscription;

  CommonWebSocket() {
    _allClosed.future.then((_) {
      if (_incomingSubscription != null &&
          _incomingSubscription.doneHandler != null) {
        _incomingSubscription.doneHandler();
      }

      if (_error != null) {
        _done.completeError(_error, _stackTrace);
      } else {
        _done.complete();
      }
    });

    // Outgoing communication will be handled by this stream controller.
    _outgoing = new StreamController<dynamic>();
    _outgoing.stream.listen(onOutgoingData,
        onError: onOutgoingError, onDone: onOutgoingDone);

    // Map events from the underlying socket to the incoming controller.
    // It is important to have handlers for start/stop/pause/resume so that the
    // controller properly respects the StreamSubscription API.
    _incoming = new StreamController<dynamic>(
        onListen: onIncomingListen,
        onPause: onIncomingPause,
        onResume: onIncomingResume,
        onCancel: onIncomingCancel);
  }

  /// Future that resolves when this WebSocket connection has completely closed.
  @override
  Future<Null> get done => _done.future;

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
  @override
  void add(dynamic data) {
    validateOutgoingData(data);
    _outgoing.add(data);
  }

  /// Add an error to the sink. This will cause the WebSocket connection to close.
  @override
  void addError(Object errorEvent, [StackTrace stackTrace]) {
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
  @override
  Future<Null> addStream(Stream stream) async {
    return _outgoing.addStream(stream);
  }

  /// Closes the WebSocket connection. Optionally set [code] and [reason]
  /// to send close information to the remote peer.
  @override
  Future<Null> close([int code, String reason]) {
    shutDown(code: code, reason: reason);
    return done;
  }

  @override
  StreamSubscription listen(void onData(dynamic event),
      {Function onError, void onDone(), bool cancelOnError}) {
    // ignore: cancel_subscriptions
    final sub = _incoming.stream
        .listen(onData, onError: onError, cancelOnError: cancelOnError);
    _incomingSubscription = new WSocketSubscription(sub, onDone, onCancel: () {
      _incomingSubscription = null;
    });
    return _incomingSubscription;
  }

  /// Called when the subscription to the incoming `StreamController` is
  /// canceled.
  Future<Null> onIncomingCancel() async {
    await webSocketSubscription.cancel();
    await _incoming.close();
  }

  /// Called when a message event with [data] is received from the underlying
  /// WebSocket.
  void onIncomingData(dynamic data) {
    // Pipe messages from the socket through to the stream, but only if a
    // listener has been registered and is not paused. Otherwise we risk leaking
    // resources by adding events to the controller that may be buffered
    // indefinitely.
    if (!_incoming.isPaused && !_incoming.isClosed) {
      _incoming.add(data);
    }
  }

  /// Called when the incoming `StreamController` is closed (due to the
  /// underlying WebSocket closing).
  void onIncomingDone() {
    isClosed = true;
    _isIncomingClosed = true;

    if (_isOutgoingClosed) {
      _allClosed.complete();
    } else {
      _outgoing.close().catchError((_) {});
    }
  }

  /// Called when the outgoing `StreamController` is closed.
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

  /// Called when an error is added to the outgoing `StreamController`.
  void onOutgoingError(Object error, [StackTrace stackTrace]) {
    // Don't pass the error on to the socket. It will cause the socket to close
    // anyway, so we will preempt this and handle the shut down by ourselves.
    // This allows us to prevent the error from propagating to the root zone
    // where it cannot be caught.
    shutDown(error: error, stackTrace: stackTrace);
  }

  /// Shuts down the connection to the underling WebSocket. The outgoing
  /// `StreamController` is closed and the WebSocket is closed.
  void shutDown(
      {int code, Object error, String reason, StackTrace stackTrace}) {
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

  /// Closes the underlying WebSocket connection with the given [code] and
  /// [reason].
  void closeWebSocket(int code, String reason);

  /// Called when the incoming `StreamController` receives a listener. This
  /// should effectively trigger a subscription to the WebSocket's events. Up
  /// until this point, events from the WebSocket should have been discarded.
  void onIncomingListen();

  /// Called when the subscription to the incoming `StreamController` is paused.
  /// From this point until the subscription is resumed, events from the
  /// WebSocket should be discarded.
  void onIncomingPause();

  /// Called when a paused subscription to the incoming `StreamController` is
  /// resumed. At this point, events from the WebSocket should once again be
  /// delivered to the listener.
  void onIncomingResume();

  /// Called when a piece of data should be added to the outgoing
  /// `StreamController`.
  void onOutgoingData(Object data);

  /// Called prior to adding a piece of data to the underlying WebSocket.
  void validateOutgoingData(Object data);
}
