## Testing/Mocks: WebSocket connection expectations

Expectations are one-time only. Every time `transport.WebSocket.connect()` is
called while the transport mocks are installed, it is compared against the list
of unsatisfied expectations and chooses the first match (if one exists) to use
to complete said connection.

### Expecting and accepting a WebSocket connection

Exact URI match:
```dart
var mockWebSocketServer = new MockWebSocketServer();
MockTransports.webSocket.expect(
    Uri.parse('ws://example.org/ws'),
    connectTo: mockWebSocketServer);
```

Matching the URI with a pattern:
```dart
var mockWebSocketServer = new MockWebSocketServer();
MockTransports.webSocket.expectPattern(
    new RegExp('*./ws$'),
    connectTo: mockWebSocketServer);
```

### Expecting and rejecting a WebSocket connection

```dart
MockTransports.webSocket.expect(Uri.parse('/ws'), reject: true);
```

> This will cause the `WSocket.connect(...)` clause to throw.
