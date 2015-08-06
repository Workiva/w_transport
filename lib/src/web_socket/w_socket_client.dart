library w_transport.src.web_socket.w_socket_server;

import 'dart:async';
import 'dart:html';
import 'dart:typed_data';

import 'package:w_transport/src/web_socket/w_socket.dart'
    show WSocketCloseEvent, WSocketController, WSocketException;

import 'package:w_transport/src/web_socket/w_socket_common.dart' as common;

/// Configure w_transport/w_transport WSocket library for use in the browser.
void configureWSocketForBrowser() {
  common.configureWSocket(close, connect, validateDataType);
}

void close(WebSocket socket, [int code, String reason]) {
  socket.close(code, reason);
}

Future<WSocketController> connect(Uri uri,
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
  Completer<WSocketCloseEvent> done = new Completer();

  // Create a controller that will pipe data from the sink
  // to the web socket.
  outgoing = new StreamController();
  outgoing.stream.listen((message) {
    // Pipe data straight through to the web socket.
    socket.send(message);
  }, onError: (error, [StackTrace stackTrace]) {
    // TODO: log

    // There's no way to send errors with the client-side WebSocket.

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
    incoming.close();
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
    done.complete(wCloseEvent);
  });

  return new WSocketController(
      socket, outgoing.sink, incoming.stream, done.future);
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
