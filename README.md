# w_transport 
[![Pub](https://img.shields.io/pub/v/w_transport.svg)](https://pub.dartlang.org/packages/w_transport) [![Build Status](https://travis-ci.org/Workiva/w_transport.svg?branch=travis-ci)](https://travis-ci.org/Workiva/w_transport) [![codecov.io](http://codecov.io/github/Workiva/w_transport/coverage.svg?branch=master)](http://codecov.io/github/Workiva/w_transport?branch=master)

> A fluent-style, platform-agnostic library with ready to use transport classes for sending and receiving data over HTTP and WebSocket.

---

## Platform Agnostic
The main library (`w_transport/w_transport.dart`) depends on neither `dart:html` nor `dart:io`, making it platform agnostic.
This means you can use the `w_transport` library to build components, libraries, or APIs that will be reusable in the browser
AND on the server.

The end consumer will make the decision between client and server, most likely in a main() block.

## Usage in the Browser
```dart
import 'package:w_transport/w_transport_client.dart' show configureWTransportForBrowser;

void main() {
  configureWTransportForBrowser();
}
```

## Usage on the Server
```dart
import 'package:w_transport/w_transport_server.dart' show configureWTransportForServer;

void main() {
  configureWTransportForServer();
}
```

---

## HTTP

All standard HTTP methods are supported:

- DELETE
- GET
- HEAD
- OPTIONS
- PATCH
- POST
- PUT
- TRACE (only on the server)

Features include:

- Fluent URI construction/mutation thanks to [Fluri](https://pub.dartlang.org/packages/fluri).
- Request headers.
- Easy attachment of various data types to requests.
- Upload and download progress streams.
- Sending of credentials on cross-origin requests (`withCredentials` flag - only has an effect on the client).
- Request cancellation.

## WebSocket

The WebSocket API mirrors the `dart:io.WebSocket` class to keep things simple. If you've used the server-side `WebSocket`
class before, then you're ready to go. The benefit is that this same API works for client-side usage as well, which is
a big improvement over the `dart:html.WebSocket` class.

The `WSocket` class included in this library is a `Stream` and a `Sink`, so sending and receiving data is as simple as
adding items to it like a sink and listening to it like a stream.

---

> Be sure to check out the [documentation](https://pub.dartlang.org/packages/w_transport) and the
 [examples](https://github.com/Workiva/w_transport/tree/master/example) for code samples and more detailed information. 

---

## Development

This project leverages [the dart_dev package](https://github.com/Workiva/dart_dev)
for most of its tooling needs, including static analysis, code formatting,
running tests, collecting coverage, and serving examples. Check out the dart_dev
readme for more information.