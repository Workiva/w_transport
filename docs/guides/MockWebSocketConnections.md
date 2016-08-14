
#### Expecting and accepting a websocket connection
```dart
var ws = new MockWSocket();
MockTransports.webSocket.expect(
    Uri.parse('/ws'),
    connectTo: ws);
```

#### Expecting and rejecting a websocket connection
```dart
MockTransports.webSocket.expect(Uri.parse('/ws'), reject: true);
```

> This will cause the `WSocket.connect(...)` clause to throw.


#### Triggering a close event for a mock websocket connection
```dart
var ws = new MockWSocket();
MockTransports.webSocket.expect(
    Uri.parse('/ws'),
    connectTo: ws);

new Timer(new Duration(seconds: 5), () {
  ws.triggerServerClose();
});
```
