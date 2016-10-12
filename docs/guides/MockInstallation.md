## Testing/Mocks: Installing/Uninstalling the Transport Mocks

All of the transport classes in this library are designed to be mockable. There
is a `MockTransports` API that enables mocking of HTTP requests and WebSockets
without any changes to the source code.

```dart
import 'package:w_transport/mock.dart' show MockTransports;
```

### Installation

These transport mocks can then be installed at any time.

```dart
MockTransports.install();
```

Once installed, any transport class that is constructed will be wrapped in a
mock-aware class. This is completely transparent and has no immediate effect.

When the transport mocks are installed, it is up to you to define how requests
and WebSockets are handled. In other words, you play the role of the server so
that a real one isn't necessary.

To do this, you can set up **expectations** and/or **handlers**. Expectations
are one-time only, while handlers continue to serve requests/WebSockets until
canceled.

Check out the HTTP and WebSocket guides for expectations and handlers.

### Uninstallation

The transport mocks should always be uninstalled in order to ensure that you
return to a clean state. Additionally, we recommend utilizing
`MockTransports.verifyNoOutstandingExceptions` to ensure that there are no
unresolved requests or unsatisfied expectations.

A good pattern to follow in tests looks like this:

```dart
import 'package:test/test.dart';
import 'package:w_transport/mock.dart';

void main() {
  setUp(() {
    MockTransports.install();
  });
  
  tearDown(() async {
    MockTransports.verifyNoOutstandingExceptions();
    await MockTransports.uninstall();
  });
}
```

> Note that the call to `uninstall()` is async because it may have to cancel
> in-flight requests or tear down open websocket connections.
