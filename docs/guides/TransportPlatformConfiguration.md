## Configuring `w_transport`

- [Platform Independence](#platform-independence)
- [Configuring with Transport Platforms (>=3.0.0)](#configuring-with-transport-platforms)
- [Configuring with Global Config Methods (<3.0.0)](#configuring-with-global-config-methods)

### Platform Independence

```dart
import 'package:w_transport/w_transport.dart';
```

**This main entry point depends on neither `dart:html` nor `dart:io` - it's
platform-independent!**

With this, you have access to all of our transport classes necessary for sending
HTTP requests and establishing WebSocket connections while remaining
platform-independent. This means you can use the `w_transport` library to build
components, libraries, or APIs that will be reusable in the browser **and** on
the Dart VM.

The end consumer will make the decision between browser and VM, most likely in a
`main()` block.


---


### Configuring with Transport Platforms
__*(version >=3.0.0)*__


> The pattern for configuring `w_transport` for a specific platform changed in
> version 3.0.0. Previously, it was done by importing one of the
> platform-specific entry points and calling a `configureWTransportFor...()`
> method.
>
> The downside to this approach and an impetus for this change is that it
> configures all `w_transport` classes at a global level, which can make
> advanced usages of this library difficult (e.g. mocking out some but not all
> requests or WebSockets).

Because all of the transport classes in the `w_transport` library are
platform-independent, a platform must be configured prior to actually using
them.

As of version 3, there is a `TransportPlatform` abstract class included with the
library. This class defines an interface that knows how to construct each of the
transport classes (HTTP client, HTTP requests, and WebSockets). Also included
are three default implementations of the `TransportPlatform` interface:

- **`BrowserTransportPlatform`**

  For use in the browser. All HTTP requests will be sent with `XMLHttpRequest`
  and native WebSockets will be used.
  
  A constant instance of this implementation is available for convenience:
  
  ```dart
  import 'package:w_transport/browser.dart' show browserTransportPlatform;
  ```

- **`BrowserTransportPlatformWithSockJS`**

  The same as above, but instead of using native WebSockets, the SockJS protocol
  will be used. This enables graceful fallback to XHR streaming if native
  WebSockets are not available, but requires that you are communicating with a
  SockJS server.
  
  A constant instance of this implementation is available for convenience:
  
  ```dart
  import 'package:w_transport/browser.dart'
      show browserTransportPlatformWithSockJS;
  ```
  
- **`VMTransportPlatform`**

  For use on the Dart VM. All HTTP and WebSocket communication will leverage
  the APIs from `dart:io`.
  
  A constant instance of this implementation is available for convenience:
  
  ```dart
  import 'package:w_transport/vm.dart' show vmTransportPlatform;
  ```
  
The transport platform can be configured globally. The globally configured
transport platform will serve as the default.

```dart
import 'package:w_transport/vm.dart' show vmTransportPlatform;
import 'package:w_transport/w_transport.dart' as transport;

void main() {
  transport.globalTransportPlatform = vmTransportPlatform;
}
```

Alternatively, a transport platform can be specified when constructing any of the
transport classes included in this library:

```dart
import 'package:w_transport/browser.dart'
    show browserTransportPlatform, browserTransportPlatformWithSockJS;
import 'package:w_transport/w_transport.dart' as transport;

void main() {
  // These requests will use the given transport platform regardless of what the
  // globally configured transport platform is.
  new transport.FormRequest(transportPlatform: browserTransportPlatform);
  new transport.JsonRequest(transportPlatform: browserTransportPlatform);
  new transport.MultipartRequest(transportPlatform: browserTransportPlatform);
  new transport.Request(transportPlatform: browserTransportPlatform);
  new transport.StreamedRequest(transportPlatform: browserTransportPlatform);
  
  // Any requests constructed from this HTTP client will use the given transport
  // platform regardless of what the globally configured transport platform is.
  new transport.HttpClient(transportPlatform: browserTransportPlatform);
  
  // This WebSocket will use the given transport platform regardless of what the
  // globally configured transport platform is.
  var uri = ...;
  transport.WebSocket.connect(
      uri, transportPlatform: browserTransportPlatformWithSockJS).then(...);
}
```

[Additional SockJS configuration](/docs/guides/WebSocketSockJS.md).

> "Testing" is no longer considered a platform for which `w_transport` can be
> configured. Instead, the "mock transports" utilities can be installed at any
> time to assist with testing.
>
> As a result, the configuration instructions above do not include a section for
> tests.


---


### Configuring with Global Config Methods
__*(version <3.0.0)*__

- **Browser**

  ```dart
  import 'package:w_transport/browser.dart'
      show configureWTransportForBrowser;
  
  void main() {
    configureWTransportForBrowser();
  }
  ```

- **Dart VM**

  ```dart
  import 'package:w_transport/vm.dart'
      show configureWTransportForVM;
  
  void main() {
    configureWTransportForVM();
  }
  ```

- **Tests**

  ```dart
  import 'package:w_transport/mock.dart'
      show configureWTransportForTest;
  
  void main() {
    configureWTransportForTest();
  }
  ```

