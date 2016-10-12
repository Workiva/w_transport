## Testing/Mocks: WebSocket connection handlers

Once registered, handlers continue to serve matching WebSocket connections until
canceled or until the transport mocks are reset/uninstalled.

### Registering a handler for WebSockets that match a URI exactly

> The expected URI must match exactly, including scheme, host, path, and query.

```dart
var mockWebSocketServer = new MockWebSocketServer();

MockTransports.webSocket.when(
    Uri.parse('ws://example.org/ws'),
    (Uri uri, {Iterable<String> protocols, Map<String, dynamic> headers}) async {
      // Perform any setup necessary.
      // Can even dynamically return a mock WebSocket server based on the given
      // URI, protocols, and headers.
      return mockWebSocketServer;
    });
```

### Registering a handler for WebSockets that match a URI pattern

Just like HTTP expectations, there is an alternate way to register handlers that
allows matching via a `Pattern` for greater flexibility. This is especially
useful for handlers since it essentially lets you define mock endpoints that can
handle dynamic parameters in the path or query.

```dart
var mockWebSocketServer = new MockWebSocketServer();

MockTransports.webSocket.whenPattern(new RegExp('.*/subscribe/(\w+)$'),
        (Uri uri,
        {Iterable<String> protocols,
        Map<String, dynamic> headers,
        Match match}) async {
      // Perform any setup necessary.
      // Can even dynamically return a mock WebSocket server based on the given
      // URI, protocols, headers, and the pattern match.
      return mockWebSocketServer;
    });
```

### Canceling a handler

Both `when()` and `whenPattern()` return a `MockWebSocketHandler` instance that
can be used to cancel/unregister the handler.

```dart
var mockHandler = MockTransports.webSocket.when(...);
...
mockHandler.cancel();
```
