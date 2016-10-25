### WebSocket: Listening for Completion

The `transport.WebSocket` class implements both the
`Stream` and `StreamSink` interfaces - but it's a bit unique because those two
interfaces are actually tied to the same connection (the underlying WebSocket).

For this reason, a `transport.WebSocket` instance only reaches the "done" state
when _both_ the outgoing `StreamSink` _and_ the incoming `Stream` have been
closed and cleaned up (including the underlying WebSocket connection).

You can listen for this "done" event or state just as you would with any other
`Stream` or `StreamSink` instance.

```dart
var uri = Uri.parse('ws://echo.websocket.org');
var webSocket = await transport.WebSocket.connect(uri);

// Using the `Future done` property from the `StreamSink` interface:
webSocket.done.then((_) {
  // Perform cleanup, reopen socket, etc.
});

// Using the `onDone` handler from the `Stream`'s `listen()` method:
webSocket.listen((data) { ... }, onDone: () {
  // Perform cleanup, reopen socket, etc.
});

// Additionally, the `close()` method returns the same `Future` as `done`:
webSocket.close().then((_) {
  // Perform cleanup, reopen socket, etc.
});
```
