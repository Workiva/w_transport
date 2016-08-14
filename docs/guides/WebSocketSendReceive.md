

### Receiving Data
```dart
WSocket webSocket = await WSocket.connect(Uri.parse('ws://echo.websocket.org'));

webSocket.listen((data) {
  // Handle message.
}, onError: (error) {
  // Handle error (if desired).
  // The socket will close immediately after this.
}, onDone: () {
  // Perform any cleanup if desired.
});
```

### Sending Data
```dart
WSocket webSocket = await WSocket.connect(Uri.parse('ws://echo.websocket.org'));
webSocket.add('message');
await webSocket.addStream(new Stream.fromIterable([...]));
```
