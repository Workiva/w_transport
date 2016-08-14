
### Using SockJS
Sockets can be configured to use SockJS under the hood instead of native
WebSockets. This configuration must occur on a per-socket basis.

```dart
Uri uri = Uri.parse('ws://echo.websocket.org');
WSocket webSocket = await WSocket.connect(uri,
   useSockJS: true, sockJSProtocolsWhitelist: ['websocket', 'xhr-streaming']);
```
