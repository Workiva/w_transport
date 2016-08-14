
## Testing & Mocks

Just like the browser or the Dart VM, tests are considered a platform for which
this library can be configured. By configuring `w_transport` for tests, mock
implementations of all classes will be used.

```dart
import 'package:w_transport/mock.dart';

main() {
  configureWTransportForTest();
}
```

That's it. No changes to your source code are necessary! Once configured for
test, you are in control of every HTTP request and every WebSocket connection.
The APIs for controlling these transports are exported with the `mock.dart`
entry point as static APIs on a `MockTransports` class.

> **Resetting Mocks:**
>
> At any point, you can reset all mock expectations and handlers, giving you a
> clean state to begin a new mock setup:
>
> ```dart
> MockTransports.reset();
> ```
