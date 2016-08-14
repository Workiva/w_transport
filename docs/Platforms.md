## Importing
```dart
import 'package:w_transport/w_transport.dart';
```

> This main entry point depends on neither `dart:html` nor `dart:io` - it's
platform-independent!

With this, you have access to all of our transport classes necessary for sending
HTTP requests and establishing WebSocket connections while remaining
platform-independent. This means you can use the `w_transport` library to build
components, libraries, or APIs that will be reusable in the browser **and** on
the Dart VM.

The end consumer will make the decision between browser and VM, most likely in a
`main()` block.


## Platforms

### Browser
```dart
import 'package:w_transport/browser.dart'
    show configureWTransportForBrowser;

void main() {
  configureWTransportForBrowser();
}
```

### Dart VM
```dart
import 'package:w_transport/vm.dart'
    show configureWTransportForVM;

void main() {
  configureWTransportForVM();
}
```

### Tests
```dart
import 'package:w_transport/mock.dart'
    show configureWTransportForTest;

void main() {
  configureWTransportForTest();
}
```

