## WebSocket: Send and Receive Data

The `transport.WebSocket` class included in this library is a `Stream` and a
`StreamSink`, so sending and receiving data is as simple as adding items to it
like a sink and listening to it like a stream.

### Sending Data

```dart
var uri = Uri.parse('ws://echo.websocket.org');
var webSocket = await transport.WebSocket.connect(uri);
webSocket.add('message');
await webSocket.addStream(new Stream.fromIterable([...]));
```

### Receiving Data

```dart
var uri = Uri.parse('ws://echo.websocket.org');
var webSocket = await transport.WebSocket.connect(uri);

webSocket.listen((data) {
  // Handle message.
}, onError: (error) {
  // Handle error (if desired).
  // The web socket will close immediately after this.
}, onDone: () {
  // Perform any cleanup if desired.
});
```


### WebSocket Subscription

Just like any other Dart Stream, when you listen to a `transport.WebSocket`
instance, you obtain a `StreamSubscription`. This can be used to pause and
resume the subscription; to cancel the subscription; or to reassign the
onListen, onError, and/or onDone handlers.

```dart
var uri = Uri.parse('ws://echo.websocket.org');
var webSocket = await transport.WebSocket.connect(uri);

var subscription = webSocket.listen(...);
...
subscription.pause();
...
subscription.resume();
...
subscription.onData(...);
...
subscription.cancel();
```
