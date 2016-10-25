## WebSocket: Establishing a Connection and Handling Failure

To establish a WebSocket connection, use the static `connect` method - it
returns a `Future` that eventually resolves with a `transport.WebSocket`
instance.

```dart
var uri = Uri.parse('ws://echo.websocket.org');
var webSocket = await transport.WebSocket.connect(uri);
```

The `connect()` method will throw a `transport.WebSocketException` if a
connection cannot be established.

```dart
var uri = Uri.parse('ws://echo.websocket.org');
transport.WebSocket webSocket;
try {
  webSocket = await transport.WebSocket.connect(uri);
} on transport.WebSocketException {
  // Handle failure.
}
```
