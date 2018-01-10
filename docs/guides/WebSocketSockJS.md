### WebSocket: Using SockJS

WebSockets can be configured to use SockJS under the hood instead of native
WebSockets. In order to leverage SockJS, however, you will first need to load
the accompanying `sockjs.js` library (likely by including it in your
application's HTML page).
See https://github.com/workiva/sockjs_client_wrapper#usage for more information.

There is a default Transport Platform instance that is configured to use SockJS
that you can use.

```dart
import 'package:w_transport/browser.dart'
    show browserTransportPlatformWithSockJS;
import 'package:w_transport/w_transport.dart' as transport;
    
var uri = Uri.parse('ws://echo.websocket.org');
var webSocket = await transport.WebSocket.connect(
      uri, transportPlatform: browserTransportPlatformWithSockJS);
```

There are also a few configuration options that can be set that will passed to
the underlying SockJS library that is used. In order to do this, you will need
to instantiate an new instance of the `BrowserTransportPlatformWithSockJS`
class.

```dart
import 'package:w_transport/browser.dart'
    show BrowserTransportPlatformWithSockJS;
import 'package:w_transport/w_transport.dart' as transport;

var uri = Uri.parse('ws://echo.websocket.org');
var transportPlatform = new BrowserTransportPlatformWithSockJS(
    sockJSNoCredentials: true,
    sockJSDebug: true,
    sockJSProtocolsWhitelist: ['xhr-streaming', 'websocket'],
    sockJSTimeout: const Duration(seconds: 10));
var webSocket = await transport.WSocket.connect(
    uri, transportPlatform: transportPlatform);
```
