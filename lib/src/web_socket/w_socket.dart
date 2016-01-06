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

/// Classes for sending and receiving data over Web Sockets designed with
/// a single, platform-agnostic API to make client and server usage easy.
///
/// If possible, APIs built using these classes should also avoid
/// importing `dart:html` and `dart:io` in order to remain platform-agnostic,
/// as it provides much greater reuse value.
library w_transport.src.web_socket.w_socket;

import 'dart:async';

import 'package:w_transport/src/platform_adapter.dart';

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
abstract class WSocket implements Stream, StreamSink {
  /// Create a new WebSocket connection. The given [uri] must use the scheme
  /// `ws` or `wss`.
  ///
  /// Specify the subprotocols the client is willing to speak via [protocols].
  ///
  /// Additional headers to be used in setting up the connection can be
  /// specified in [headers]. This only applies to server-side usage. See
  /// `dart:io`'s [WebSocket] for more information.
  static Future<WSocket> connect(Uri uri,
      {Map<String, dynamic> headers,
      Iterable<String> protocols,
      bool sockJSDebug,
      bool sockJSNoCredentials,
      List<String> sockJSProtocolsWhitelist,
      bool useSockJS}) async {
    return PlatformAdapter.retrieve().newWSocket(uri,
        headers: headers,
        protocols: protocols,
        sockJSDebug: sockJSDebug,
        sockJSNoCredentials: sockJSNoCredentials,
        sockJSProtocolsWhitelist: sockJSProtocolsWhitelist,
        useSockJS: useSockJS);
  }

  /// The close code set when the WebSocket connection is closed. If there is
  /// no close code available this property will be `null`.
  int get closeCode;

  /// The close reason set when the WebSocket connection is closed. If there is
  /// no close reason available this property will be `null`.
  String get closeReason;

  /// Future that resolves when this WebSocket connection has completely closed.
  Future<Null> get done;

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
  void add(message);

  /// Add an error to the sink. This will cause the WebSocket connection to close.
  void addError(errorEvent, [StackTrace stackTrace]);

  /// Adds a stream of data to send over the WebSocket connection.
  /// This will wait for the stream to complete, sending each element
  /// as it is received.
  ///
  /// See [send] for the list of accepted types of data from the stream.
  ///
  /// Sending additional data before this stream has completed may
  /// result in a [StateError].
  Future addStream(Stream stream);

  /// Closes the WebSocket connection. Optionally set [code] and [reason]
  /// to send close information to the remote peer.
  Future close([int code, String reason]);
}
