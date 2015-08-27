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

library w_transport.src.web_socket.server.w_socket;

import 'dart:async';
import 'dart:io';

import 'package:w_transport/src/web_socket/common/w_socket.dart';
import 'package:w_transport/src/web_socket/w_socket.dart';
import 'package:w_transport/src/web_socket/w_socket_close_event.dart';
import 'package:w_transport/src/web_socket/w_socket_exception.dart';

class ServerWSocket extends CommonWSocket implements WSocket {
  static Future<WSocket> connect(Uri uri,
      {Iterable<String> protocols, Map<String, dynamic> headers}) async {
    WebSocket socket;
    try {
      socket = await WebSocket.connect(uri.toString(),
          protocols: protocols, headers: headers);
    } on SocketException catch (e) {
      throw new WSocketException(e.toString());
    }

    // Outgoing communication. Sink will be exposed, allowing users to
    // add items to the outgoing stream.
    StreamController outgoing;

    // Incoming communication. Data from the web socket will be piped
    // to this controller's sink. The stream will be exposed, allowing
    // users to listen to the incoming data.
    StreamController incoming;

    // Subscription to the incoming web socket data. Will be mapped to
    // the incoming stream controller.
    StreamSubscription socketSubscription;

    // Used to determine when the web socket is completely finished.
    Completer<WSocketCloseEvent> finished = new Completer();

    // Create a controller that will pipe data from the sink
    // to the web socket.
    outgoing = new StreamController();
    outgoing.stream.listen((message) {
      // Pipe data straight through to the web socket.
      socket.add(message);
    }, onError: (error, [StackTrace stackTrace]) {
      // TODO: log
      // Pipe the error through to the web socket, which will cause the
      // error to bubble and eventually be thrown.
      socket.addError(error, stackTrace);

      // Don't call onDone() yet, because at this point only the outgoing
      // communication has been stopped. Still need to wait for the incoming
      // stream to be closed and the close code and reason to be set.
    }, onDone: () {
      // Outgoing communication has been closed, but again, we're not ready
      // to call onDone(). Still need to wait on the incoming stream.
    }, cancelOnError: true);

    // Create a subscription that will pipe data from the web socket
    // to a stream that can be listened to.
    socketSubscription = socket.listen((data) {
      // Pipe data straight through from the web socket.
      incoming.add(data);
    }, onError: (error) {
      // Pipe the error through to our stream, so that it can be listened
      // to if necessary.
      incoming.addError(error);

      // Close the outgoing communication since an error will be followed
      // by the web socket closing.
      outgoing.close();
    }, onDone: () {
      // Incoming communication has been closed, meaning that the web socket
      // has completely closed. At this point, the close code and reason
      // should be available.
      WSocketCloseEvent closeEvent =
          new WSocketCloseEvent(socket.closeCode, socket.closeReason);

      // Since the web socket has closed, the outgoing and incoming controllers
      // should also be closed.
      outgoing.close();
      incoming.close();

      // At this point, both outgoing and incoming streams of communication
      // have been closed, as has the underlying web socket.
      finished.complete(closeEvent);
    }, cancelOnError: false);

    // Map the incoming controller to this subscription to the web socket.
    incoming = new StreamController(
        onListen: socketSubscription.resume,
        onPause: socketSubscription.pause,
        onResume: socketSubscription.resume);

    return new ServerWSocket._(
        socket, outgoing.sink, incoming.stream, finished.future);
  }

  StreamSink sink;

  Stream stream;

  Future<WSocketCloseEvent> _finished;

  Completer _done = new Completer();

  WebSocket _socket;

  ServerWSocket._(WebSocket this._socket, StreamSink this.sink,
      Stream this.stream, Future<WSocketCloseEvent> this._finished)
      : super() {
    _done.complete(_socket.done.then((_) async {
      WSocketCloseEvent closeEvent = await _finished;
      closeCode = closeEvent.code;
      closeReason = closeEvent.reason;
    }));
  }

  Future get done => _done.future;

  Future closeConnection([int code, String reason]) async =>
      _socket.close(code, reason);

  /// Validate the WebSocket message data type. For server-side messages,
  /// [String] and [List<int>] are valid types.
  ///
  /// Throws an [ArgumentError] if [data] is invalid.
  void validateDataType(Object data) {
    if (data is! String && data is! List<int>) {
      throw new ArgumentError(
          'WSocket data type must be a String or a List<int>.');
    }
  }
}
