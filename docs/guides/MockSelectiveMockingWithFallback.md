## Mocks/Testing: Selective mocking with fallback to a real transport platform

The transport mocks can be installed at any time and are independent from the
[configured transport platform](/docs/TransportPlatformConfiguration.md).

You can leverage this to selectively mock a subset of requests or WebSockets
while allowing the remainder to transparently fall through to a transport
platform. Requests or WebSockets for which you setup mock expectations and/or
handlers will be processed by that mock logic and will not result in a real
request being sent or a real WebSocket connection being established. However,
requests and WebSockets for which there are no mock expectations or handlers
will be processed as if the mock transports were never installed. In other
words, they will expect that a transport platform has been configured either for
that specific instance or globally and said transport platform will be used to
send a real request or establish a real WebSocket connection.

This can enable some powerful functionality for local development stories. For
example, consider an application that talks to two different backends: (1) an
authentication server, and (2) a document server.

For a variety of reasons (e.g. backends are maintained by separate teams), it
may be desired to mock out _only_ one of these backends. The team that works on
the document server may be able to run that server locally with its own mock
configuration that does not require a real authentication token or cookie. If
they could then mock out the authentication server, they could save time and
hassle during local development, resulting in faster iteration.

This is possible with `w_transport`, and might look something like this:

```dart
import 'dart:convert';
import 'dart:html' show window;

import 'package:w_transport/browser.dart' show browserTransportPlatform;
import 'package:w_transport/mock.dart';
import 'package:w_transport/w_transport.dart' as transport;

void main() {
  transport.globalTransportPlatform = browserTransportPlatform;

  final uri = Uri.parse(window.location.toString());
  if (uri.queryParameters.containsKey('mockAuth')) {
    mockOutAuthenticationServer();
  }
  
  // carry on with application initialization
}

void mockOutAuthenticationServer() {
  MockTransports.install();
  
  MockTransports.http.when(
        Uri.parse('https://authserver.com/api/user/'),
        (transport.FinalizedRequest request) async {
      final body = JSON.encode({'authenticated': 'true'});
      return MockResponse.ok(body: body);
    });
}
```

With the above setup, any request to `https://authserver.com/api/user/` will be
handled by the mock handler and a 200 OK response will be returned. All other
requests (like requests to the documents server) will be unaffected and will use
the browser transport platform since it was configured globally.
