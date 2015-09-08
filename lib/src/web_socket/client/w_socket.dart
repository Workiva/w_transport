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

library w_transport.src.web_socket.client.w_socket;

import 'dart:async';
import 'dart:html';
import 'dart:typed_data';

import 'package:w_transport/src/web_socket/common/w_socket.dart';
import 'package:w_transport/src/web_socket/w_socket.dart';
import 'package:w_transport/src/web_socket/w_socket_close_event.dart';
import 'package:w_transport/src/web_socket/w_socket_exception.dart';

class ClientWSocket extends CommonWSocket implements WSocket {
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

    // Outgoing communication. Sink will be exposed, allowing users to
    // add items to the outgoing stream.
    StreamController outgoing;

    // Incoming communication. Data from the web socket will be piped
    // to this controller's sink. The stream will be exposed, allowing
    // users to listen to the incoming data.
    StreamController incoming;

    // Used to determine when the web socket is completely finished.
    Completer<WSocketCloseEvent> finished = new Completer();

    // Will store any error added to the sink.
    var outgoingError;

    // Create a controller that will pipe data from the sink
    // to the web socket.
    outgoing = new StreamController();
    outgoing.stream.listen((message) {
      // Pipe data straight through to the web socket.
      socket.send(message);
    }, onError: (error, [StackTrace stackTrace]) {
      // TODO: log

      // There's no way to send errors with the client-side WebSocket, so we
      // store it to complete the "done" future with later.
      outgoingError = error;

      // Close the outgoing communication, since our own subscription
      // will be canceled and the web socket will be closing.
      socket.close();

      // Drain the incoming stream if it hasn't been listened to in order
      // to force execution of the onDone() handler.
      if (!incoming.hasListener) {
        incoming.stream.drain().catchError((_) {});
      }

      // Don't call onDone() yet, because at this point only the outgoing
      // communication has been stopped. Still need to wait for the incoming
      // stream to be closed and the close code and reason to be set.
    }, onDone: () {
      // Drain the incoming stream if it hasn't been listened to in order
      // to force execution of the onDone() handler.
      if (!incoming.hasListener) {
        incoming.stream.drain().catchError((_) {});
      }

      // Outgoing communication has been closed, but again, we're not ready
      // to call onDone(). Still need to wait on the incoming stream.
    }, cancelOnError: true);

    // Pipe events from the socket to the controller.
    incoming = new StreamController();
    socket.onMessage.listen((messageEvent) {
      // Pipe data straight through from the web socket.
      incoming.add(messageEvent.data);
    });
    socket.onError.listen((error) {
      // Pipe the error through to our stream, so that it can be listened
      // to if necessary.
      incoming.addError(error);

      // Close the outgoing communication since an error will be followed
      // by the web socket closing.
      outgoing.close();
    });
    closed.then((closeEvent) {
      // Incoming communication has been closed, meaning that the web socket
      // has completely closed. At this point, the close code and reason
      // should be available.
      WSocketCloseEvent wCloseEvent =
          new WSocketCloseEvent(closeEvent.code, closeEvent.reason);

      // Since the web socket has closed, the outgoing and incoming controllers
      // should also be closed.
      outgoing.close();
      incoming.close();

          // At this point, both outgoing and incoming streams of communication
          // have been closed, as has the underlying web socket.
          outgoingError == null
          ? finished.complete(wCloseEvent)
          : finished.completeError(outgoingError);
    });

    return new ClientWSocket._(
        socket, outgoing.sink, incoming.stream, finished.future);
  }

  StreamSink sink;

  Stream stream;

  Future<WSocketCloseEvent> _closed;

  Completer _done = new Completer();

  WebSocket _socket;

  ClientWSocket._(WebSocket this._socket, StreamSink this.sink,
      Stream this.stream, Future<WSocketCloseEvent> this._closed)
      : super() {
    _done.complete(_closed.then((closeEvent) {
      closeCode = closeEvent.code;
      closeReason = closeEvent.reason;
    }));
  }

  Future get done => _done.future;

  Future closeConnection([int code, String reason]) async {
    _socket.close(code, reason);
  }

  /// Validate the WebSocket message data type. For client-side messages,
  /// [Blob], [ByteBuffer], [String] and [TypedData] are valid types.
  ///
  /// Throws an [ArgumentError] if [data] is invalid.
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
