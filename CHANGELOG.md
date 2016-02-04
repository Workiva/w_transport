# Changelog

## 2.2.0

### Features

- Added an `autoRetry.forTimeouts` flag (defaults to `true`) to the `Client`
  class and all request classes. This flag determines whether or not requests
  that are canceled due to exceeding the timeout threshold should be retried.

    ```dart
    // This request will retry if the timeout is exceeded.
    var request = new Request()
      ..timeoutThreshold = new Duration(seconds: 10)
      ..autoRetry.enabled = true;

    // This request will NOT retry if the timeout is exceeded.
    var request = new Request()
      ..timeoutThreshold = new Duration(seconds: 10)
      ..autoRetry.enabled = true
      ..autoRetry.forTimeouts = false;
    ```

## 2.1.0

### Deprecation: SockJS global configuration

As of v2.0.0, this library could be configured to use SockJS under the hood when
the `WSocket` class was used to establish WebSocket connections. This
configuration occurred on a global basis (meaning it affected every `WSocket`
instance) which is undesirable for applications with a mixed usage of native
WebSockets and SockJS. **This global configuration has been deprecated.**

As of v2.1.0, passing `useSockJS: true` to the `configureWTransportForBrowser()`
method will cause a deprecation warning to be printed to the console.

The SockJS configuration should now occur on a per-socket basis via the
`WSocket.connect()` method:

```dart
Uri uri = Uri.parse('ws://echo.websocket.org');
WSocket webSocket = await WSocket.connect(uri,
   useSockJS: true, sockJSProtocolsWhitelist: ['websocket', 'xhr-streaming']);
```

### Features

- Added a `baseUri` field to `Client` that all requests from the client will
  inherit.

- All request classes now support a timeout threshold via the `timeoutTreshold`
  field. This was also added to the `Client` class and all requests created from
  a client will inherit this value.

- Request and response interception is now supported. This can be done directly
  on a request instance, but more usefully through a `Client` instance. See
  ["request & response interception"](README.md#request--response-interception)
  and ["intercepting requests & responses from a client"](README.md#intercepting-requests--responses-from-a-client)
  in the README.

- All request classes and the `Client` class now include an API for automatic
  retrying via the `autoRetry` field. See ["automatic request retrying"](README.md#automatic-request-retrying)
  in the README.

- Added a `replace` method to `Response` and `StreamedResponse` to allow simple
  creation of new responses based on another response, while changing only the
  fields you specify. This is particularly useful during response interception.

### Bug Fixes

- Headers passed into a request's dispatch method (ex: `.get(headers: {...})`)
  are now merged with any existing headers on the request (previously they were
  being ignored).


## 2.0.0

> The 2.0.0 release is a major breaking release. While many of the patterns from
> 1.0.x were maintained, the HTTP API was broken up into several request classes
> and two response classes for a much more robust and useful API. As such, there
> is no backwards compatibility, but a migration guide is included below.

### Features

- **WebSockets**
  - Single API for the browser and the Dart VM.
  - Option to use SockJS library in place of native WebSockets for the ability
    to fall back to XHR streaming (configuration only, no API usage difference).

- **HTTP**
  - Support for most commonly used request types:
    - `Request` (content-type: text/plain)
    - `JsonRequest` (content-type: application/json)
    - `FormRequest` (content-type: application/x-www-form-urlencoded)
    - `MultipartRequest` (content-type: multipart/form-data)
  - Synchronous access to response bodies as bytes, text, and JSON.
  - Asynchronous request bodies (`StreamedRequest`).
  - Asynchronous response bodies via `streamGet()`, `streamPost()`, etc. on any
    of the above request classes.
  - Automatic request encoding and response decoding.

- **Mocks**
  - Because this library is designed to be platform-agnostic, it's easy to
    introduce mocks simply by treating tests as another platform, just like the
    browser or the Dart VM.
  - Import `package:w_transport/w_transport_mock.dart` and call
    `configureWTransportForTest()` to configure w_transport to use mock
    implementations for every class.
  - No changes necessary to your source code!
  - Utilize the `MockTransports` class to control WebSocket connections and HTTP
    requests.

- **Testing**
  - A big initiative in this 2.0.0 release was to increase our test coverage -
    which we've done. **With almost 1000 statements, `w_transport` has 99.7%
    coverage!**
  - Since this library is concerned with transport protocols, it is imperative
    that our testing included rigorous integration tests. **We have over 1000
    integration tests that run in the browser and on the Dart VM against real
    servers.**
  - Our test suites run against our mock implementations as well to ensure they
    are in parity with the real implementations.

### Migration Guide

#### `WRequest`

The `WRequest` class attempted to cover all HTTP request use cases. Its closest
analog now is `Request` - the class for sending plain-text requests. All other
request classes share a similar base API with additional support for a specific
type of request data (JSON, form, multipart, or streamed).

#### `WResponse`

The `WResponse` class made request meta data (status, headers) available as soon
as the request had finished; however, in an attempt to unify the API between the
`dart:io` HTTP requests and `dart:html` XHR requests, the response body was only
available asynchronously (as a stream, an untyped future, or decoded to text).
This meant two asynchronous steps were required for every request - one to get
the response, and one to get the response body.

This has been greatly improved by switching to two different response classes:

- `Response` - response meta data and body available synchronously
- `StreamedResponse` - response meta data available synchronously, body
  available as a stream of bytes


## 1.0.1
**Bug Fixes:**

- Allow request data to be set to `null`.
- Canceling an in-flight request now properly results in the returned Future
  completing with an error.
- Request data type validation now happens when sending the request instead of
  upon assignment, allowing intermediate data assignments.
- Verify w_transport configuration has been set before constructing a `WHttp`
  instance.


## 1.0.0
- Initial version of w_transport: a fluent-style, platform-agnostic library with
  ready to use transport classes for sending and receiving data over HTTP.
