// TODO: move this intro-y thing elsewhere?
The WebSocket API mirrors the `dart:io.WebSocket` class to keep things simple.
If you've used the VM's WebSocket class before, then you're ready to go. The
benefit is that this same API works in the browser as well (even when configured
to use SockJS), which is a big improvement over the `dart:html.WebSocket` class.

The `WSocket` class included in this library is a `Stream` and a `StreamSink`,
so sending and receiving data is as simple as adding items to it like a sink and
listening to it like a stream.

### Establishing a Connection
```dart
WSocket webSocket = await WSocket.connect(Uri.parse('ws://echo.websocket.org'));
```

> The `connect()` method will throw if a connection cannot be established.
