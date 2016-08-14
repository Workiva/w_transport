### Listening for Completion
```dart
WSocket webSocket = await WSocket.connect(Uri.parse('ws://echo.websocket.org'));
webSocket.done.then((_) {
  // Perform cleanup, reopen socket, etc.
}).catchError((error) {
  // Handle socket error, reopen socket, etc.
});
```
