/// Classes for sending and receiving data over Web Sockets designed with
/// a single, platform-agnostic API to make client and server usage easy.
///
/// If possible, APIs built using these classes should also avoid
/// importing `dart:html` and `dart:io` in order to remain platform-agnostic,
/// as it provides much greater reuse value.
library w_transport.src.web_socket.w_socket;

import 'dart:async';

import 'package:w_transport/src/configuration/configuration.dart'
    show verifyWHttpConfigurationIsSet;
import 'package:w_transport/src/web_socket/w_socket_common.dart' as common;

/// A two-way communication object for WebSocket clients. Establishes
/// a WebSocket connection, sends data or streams of data to the server,
/// and receives data from the server.
///
/// This class mirrors the native Dart WebSocket API from the dart:io library.
/// The benefit is that it's platform agnostic and can be used on the server or
/// in the browser - so you can write libraries or APIs that can run in either
/// place just by building them on [WSocket].
///
/// To establish a connection, use the static [connect] method:
///
///     import 'package:w_transport/w_transport.dart';
///
///     main() async {
///       Uri uri = Uri.parse('ws://echo.websocket.org');
///       WSocket webSocket = await WSocket.connect(uri);
///     }
///
/// Once the connection has been established, data can be sent to server and
/// the connection can be listened to. WSocket is a stream and a stream sink,
/// so sending and receiving data is the same as interacting with a sink and
/// a stream, respectively.
///
///     Uri uri = Uri.parse('ws://echo.websocket.org');
///     WSocket webSocket = await WSocket.connect(uri);
///
///     // Send data
///     String data = 'data';
///     Stream stream = ...;
///     webSocket.add(data);
///     webSocket.addStream(stream);
///
///     // Receive data
///     webSocket.listen((data) {
///       print(data);
///     });
///
/// Finally, you can determine when the web socket connection has been closed
/// in a few different ways:
///
///     Uri uri = Uri.parse('ws://echo.websocket.org');
///     WSocket webSocket = await WSocket.connect(uri);
///
///     // "done" is a Future
///     webSocket.done.then((_) { ... });
///
///     // calling "close()" returns the same Future
///     webSocket.close().then((_) { ... });
///
///     // registering an "onDone()" handler also works
///     webSocket.listen((_) {}, onDone: () { ... });
///
class WSocket extends Stream implements StreamSink {

  /// Create a new WebSocket connection. The given [uri] must use the scheme
  /// `ws` or `wss`.
  ///
  /// Specify the subprotocols the client is willing to speak via [protocols].
  ///
  /// Additional headers to be used in setting up the connection can be
  /// specified in [headers]. This only applies to server-side usage. See
  /// `dart:io`'s [WebSocket] for more information.
  static Future<WSocket> connect(Uri uri,
      {Iterable<String> protocols, Map<String, dynamic> headers}) async {
    verifyWHttpConfigurationIsSet();
    var socketController =
        await common.connect(uri, protocols: protocols, headers: headers);
    return new WSocket._(socketController);
  }

  /// Close code set when the WebSocket closes.
  int _closeCode;

  /// Close reason set when the WebSocket closes.
  String _closeReason;

  /// Whether or not the web socket is in the process of closing (or already has
  /// closed). This prevents duplicate behavior if [close] is called multiple times.
  bool _closing = false;

  /// Completes when..
  /// - Outgoing communication is closed (sink)
  /// - Underlying WebSocket connection is closed
  /// - Incoming communication is closed (stream)
  Completer _done = new Completer();

  /// Underlying sink used to send WebSocket messages.
  StreamSink _sink;

  /// Underlying WebSocket instance.
  dynamic _socket;

  /// Underlying stream of incoming WebSocket messages.
  Stream _stream;

  /// Private constructor for creating new [WSocket] instances after connecting.
  WSocket._(WSocketController wSocketController)
      : _sink = wSocketController.sink,
        _socket = wSocketController.socket,
        _stream = wSocketController.stream {
    wSocketController.done.then((closeEvent) {
      _closeCode = closeEvent.code;
      _closeReason = closeEvent.reason;
      _done.complete();
    });
  }

  /// The close code set when the WebSocket connection is closed. If there is
  /// no close code available this property will be `null`.
  int get closeCode => _closeCode;

  /// The close reason set when the WebSocket connection is closed. If there is
  /// no close reason available this property will be `null`.
  String get closeReason => _closeReason;

  /// Future that resolves when this WebSocket connection has completely closed.
  Future get done => _done.future;

  /// Closes the WebSocket connection. Optionally set [code] and [reason]
  /// to send close information to the remote peer.
  Future close([int code, String reason]) {
    if (_closing) return done;
    _closing = true;
    common.close(_socket, code, reason);
    _sink.close();
    return done;
  }

  StreamSubscription listen(void onData(event),
      {Function onError, void onDone(), bool cancelOnError}) {
    if (onDone != null) {
      done.then((_) => onDone());
    }
    return _stream.listen(onData,
        onError: onError, cancelOnError: cancelOnError);
  }

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
    common.validateDataType(message);
    _sink.add(message);
  }

  /// Add an error to the sink. This will cause the WebSocket connection to close.
  void addError(errorEvent, [StackTrace stackTrace]) {
    _sink.addError(errorEvent, stackTrace);
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
    await _sink.addStream(stream);
  }
}

class WSocketCloseEvent {
  final int code;
  final String reason;
  WSocketCloseEvent(this.code, this.reason);
}

class WSocketController {
  Sink sink;
  var socket;
  Stream stream;
  Future<WSocketCloseEvent> done;
  WSocketController(this.socket, this.sink, this.stream, this.done);
}

/// Represents an exception in the connection process of a Web Socket.
class WSocketException {
  String message;
  WSocketException([String this.message]);
  String toString() => 'WSocketException: $message';
}
