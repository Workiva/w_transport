# w_transport 
[![Pub](https://img.shields.io/pub/v/w_transport.svg)](https://pub.dartlang.org/packages/w_transport) [![Build Status](https://travis-ci.org/Workiva/w_transport.svg?branch=travis-ci)](https://travis-ci.org/Workiva/w_transport) [![codecov.io](http://codecov.io/github/Workiva/w_transport/coverage.svg?branch=master)](http://codecov.io/github/Workiva/w_transport?branch=master)

> A fluent-style, platform-agnostic library with ready to use transport classes for sending and receiving data over HTTP.

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


## WHttp
`WHttp` acts as an HTTP client that can be used to send many HTTP requests. Client-side this has no effect, but on the
server this gives you the benefit of cached network connections.

Additionally, `WHttp` has static methods that make simple HTTP requests easy.

```dart
WHttp.get(Uri.parse('example.com'));
WHttp.post(Uri.parse('example.com'), 'data');
...
```

If you do create an instance of `WHttp`, make sure you close it when finished.

```dart
WHttp http = new WHttp();
...
http.close();
```


## WRequest
`WRequest` is the class used to create and send HTTP requests. It supports headers, request data, upload & download
progress monitoring, withCredentials (only useful in the browser), and request cancellation.


## WResponse
`WResponse` is the class that contains the response to a `WRequest`.

This includes response meta data (available synchronously):

- Response headers
- Status code (200)
- Status text ('OK')

As well as the response content in the following formats (available asynchronously):

- Dynamic object (ByteBuffer, Document, String, List<int>, etc.)
- Text (decoded and joined if necessary)
- Stream


## WProgress
`WProgress` is a simple class that mimics `ProgressEvent` with an additional `percent`
property for convenience. `WProgress` is platform-agnostic, unlike `ProgressEvent`.


## WHttpException
`WHttpException` is a custom exception that is raised when a request responds with a non-successful status code.