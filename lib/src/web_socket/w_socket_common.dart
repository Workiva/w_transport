library w_transport.src.web_socket.w_socket_common;

import 'dart:async';

import 'package:w_transport/src/web_socket/w_socket.dart'
    show WSocket, WSocketCloseEvent, WSocketController;

void close(socket, [int code, String reason]) => _close(socket, code, reason);
typedef void WebSocketCloser(socket, [int code, String reason]);
WebSocketCloser _close;

Future<WSocketController> connect(Uri uri,
        {Iterable<String> protocols, Map<String, dynamic> headers}) =>
    _connect(uri, protocols: protocols, headers: headers);
typedef Future<WSocketController> WebSocketConnector(Uri uri,
    {Iterable<String> protocols, Map<String, dynamic> headers});
WebSocketConnector _connect;

void validateDataType(Object data) => _validateDataType(data);
typedef void DataTypeValidator(Object data);
DataTypeValidator _validateDataType;

/// Configures the w_socket library for use on a particular platform
/// (client or server) by providing concrete implementations for all
/// of the above pieces of WebSocket logic.
void configureWSocket(WebSocketCloser close, WebSocketConnector connect,
    DataTypeValidator validateDataType) {
  _close = close;
  _connect = connect;
  _validateDataType = validateDataType;
}
