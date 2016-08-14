
#### Listening to outgoing data from a mock websocket connection
```dart
var ws = new MockWSocket();
ws.onOutgoing((data) { ... });

MockTransports.webSocket.expect(
    Uri.parse('/ws'),
    connectTo: ws);
```

#### Sending data to the client from a mock websocket connection
```dart
var ws = new MockWSocket();
// Echo.
ws.onOutgoing((data) {
  ws.addIncoming(data);
});

MockTransports.webSocket.expect(
    Uri.parse('/ws'),
    connectTo: ws);

// Create a WSocket instance here...

// Connected message.
ws.add('Connected.');
```
