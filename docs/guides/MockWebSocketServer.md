## Testing/Mocks: Mock WebSocket Server

In order to mock out a WebSocket, you have to provide and control a mock
WebSocket server. To do this, you construct an instance of `MockWebSocketServer`
and either provide it when setting up an expectation, or return it from a
handler.

> Just like an actual server, a `MockWebSocketServer` instance can serve
> multiple `transport.WebSocket` instances.

```dart
import 'package:w_transport/mock.dart';

...

var mockWebSocketServer = new MockWebSocketServer();
```

A stream of connections is available on the mock WebSocket server. Listening to
this stream allows you to setup listeners for each connected client so that
incoming data can be read and data can be sent to the client.

```dart
var mockWebSocketServer = new MockWebSocketServer();
mockWebSocketServer.onClientConnected.listen((MockWebSocketConnection connection) {
  // Echo any message from the client
  connection.listen((data) {
    connection.add(data);
  });
});
```

When listening to a connected client, you can include an `onDone` handler to
detect when the client closes the connection.

```dart
var mockWebSocketServer = new MockWebSocketServer();
mockWebSocketServer.onClientConnected.listen((MockWebSocketConnection connection) {
  // Echo any message from the client
  connection.listen((_) { ... }, onDone: () {
    // Perform any cleanup if necessary
  });
});
```

Additionally, you can close the connection at any time.

```dart
var mockWebSocketServer = new MockWebSocketServer();
mockWebSocketServer.onClientConnected.listen((MockWebSocketConnection connection) {
  ...
  
  connection.close(4000, 'Mock server closed connection.');
});
```

Finally, you may choose to shut down the entire mock server at any time, which
will terminate any active connections.

```dart
var mockWebSocketServer = new MockWebSocketServer();
mockWebSocketServer.onClientConnected.listen(
    (MockWebSocketConnection connection) { ... });

...

mockWebSocketServer.shutDown();
```
