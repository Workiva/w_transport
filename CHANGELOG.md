# Changelog

## [2.9.4](https://github.com/Workiva/w_transport/compare/2.9.3...2.9.4)
_October 14, 2016_

- **Bug Fix:** The `Future` returned from `WSocket.cancel()` no longer waits for
  the WebSocket to be closed.

## [2.9.3](https://github.com/Workiva/w_transport/compare/2.9.2...2.9.3)
_September 8, 2016_

- **Bug Fix:** if a request is canceled right before it would also have exceeded
  the timeout threshold, a `StateError` may be thrown due to a `Completer` being
  completed more than once. This is fixed now.

## [2.9.2](https://github.com/Workiva/w_transport/compare/2.9.1...2.9.2)
_August 11, 2016_

- Widen the version range for the `http_parser` dependency to speed up and/or
  fix downstream consumers experiencing version conflicts.

## [2.9.1](https://github.com/Workiva/w_transport/compare/2.9.0...2.9.1)
_August 2, 2016_

- **Bug Fix:** previously, listening to a `WSocket` instance and then canceling
  the subscription before closing the socket would result in the "done" state
  never being reached. This is fixed now and the `Future` returned from
  `WSocket.done` and `WSocket.close()` will always resolve once the connection
  is closed.

## [2.9.0](https://github.com/Workiva/w_transport/compare/2.8.0...2.9.0)
_July 26, 2016_

- **Improvement:** All request classes now have a `bool isDone` getter that can
  be read to determine whether or not a request is complete (i.e. succeeded,
  failed, or canceled).

- **Bug Fix:** Calling `request.abort()` more than once will no longer throw a
  `StateError`.

## [2.8.0](https://github.com/Workiva/w_transport/compare/2.7.1...2.8.0)
_July 21, 2016_

- **Improvement:** Mock transport handlers can now be canceled. This will allow
  consumers to remove HTTP or WebSocket mock handlers without having to call
  `MockTransports.reset()` or `MockTransports.uninstall`.

    ```dart
    var uri = Uri.parse('/example');

    var myHttpHandler = MockTransports.http.when(uri, (request) { ... });
    myHttpHandler.cancel();

    var myWebSocketHandler = MockTransports.webSocket.when(uri,
        handler: (protocols, headers) { ... });
    myWebSocketHandler.cancel();

    /// The same works for the `whenPattern()` methods, as well.
    ```

## [2.7.1](https://github.com/Workiva/w_transport/compare/2.7.0...2.7.1)
_July 20, 2016_

- **Bug Fix:** previously, you could not retry a request that failed with a
  `null` response. This is now allowed, but still has the same default behavior.
  To retry a request with a `null` response, use the `autoRetry.test` method
  accordingly:

    ```dart
    var request = new Request();
    request.autoRetry
      ..enabled = true
      ..test = (request, response, willRetry) {
        if (response == null) return true;
        return willRetry;
      };
    ```

## [2.7.0](https://github.com/Workiva/w_transport/compare/2.6.0...2.7.0)
_June 23, 2016_

- **Deprecation:** `autoRetry.backOff.duration` has been deprecated in
  favor of the more aptly named `autoRetry.backOff.interval`.

- **Improvement:** Automatic request retrying will now add
  [jitter](https://www.awsarchitectureblog.com/2015/03/backoff.html) to the
  backoff intervals by default. To disable jitter, set
  `autoRetry.backOff.withJitter = false;`.

- **Improvement:** You can now put a cap on the backoff interval used during
  automatic request retrying.

    ```dart
    request.autoRetry.backOff.maxInterval = new Duration(minutes: 2);
    ```

- **Bug Fix:** A request's `encoding` property can no longer be set to null.
  This would have most likely caused an RTE when the request was sent, so now an
  `ArgumentError` will be thrown immediately.

- **Bug Fix:** As of 2.6.0, if you were to set a request's content-type manually
  without a charset or with an unknown charset, it was possible to hit an RTE
  due to a null `encoding`. The `HttpBody` class has been updated to be more
  resilient to a missing encoding or charset. Additionally, all request classes
  will now pass in the value of its `encoding` property, which should now always
  be non-null.

## [2.6.0](https://github.com/Workiva/w_transport/compare/2.5.1...2.6.0)
_June 20, 2016_

- **Improvement:** The `MockTransport` utilities now support expecting
  and registering handlers for HTTP requests and WS connections that
  match a `Pattern` instead of exactly matching a URI. Handlers will
  also receive the `Match` instance.

    ```dart
    var response = new MockResponse.ok();
    var webSocket = new MockWSocket();

    var uriPattern = new RegExp('(http|ws)s:\/\/example.com\/(.*)');

    // Capture any GET request to example.com/
    MockTransports.http.expectPattern('GET', uriPattern, respondWith: response);

    // Register a handler for any GET request to https://example.com/
    // The `Match` instance will be given to the handler, where it can be used
    // to read any of the captured groups.
    MockTransports.http.whenPattern(uriPattern, (request, match) async {
      print('path: ${match.group(2)}');
      return response;
    }, method: 'GET');

    // Capture any WS connection attempt to example.com/
    MockTransports.webSocket.expectPattern(uriPattern, connectTo: webSocket);
    
    // Register a handler for an WS connection attempt to example.com/
    // The `Match` instance will be given to the handler, where it can be used
    // to read any of the captured groups.
    MockTransports.webSocket.whenPattern(uriPattern, handler:
        (uri, {protocols, headers, match}) async {
      print('path: ${match.group(2)}');
      return webSocket;
    });
    ```

- **Improvement:** the content-type for HTTP requests can now be set manually.

    ```dart
    var request = new Request()
      ..uri = Uri.parse('/example')
      ..contentType =
          new MediaType('application', 'x-custom', {'charset': UTF8.name});
    ```

  - The content-type still has a default value based on the type of request
    (`Request` - text/plain, `JsonRequest` - application/json, etc.).

  - The content-type's charset parameter will still be updated automatically
    when you set the `encoding`, **but once you manually set `contentType`, this
    behavior will stop.** In other words, we are assuming that if you set
    `contentType` manually, you are intentionally overriding the defaults and
    are taking responsibility of setting the `charset` parameter appropriately.

- **Bug Fix:** the `StreamedRequest` now properly verifies that the request has
  not been sent when setting `contentType`. It will now throw a `StateError`
  like the rest of the request types.

## [2.5.1](https://github.com/Workiva/w_transport/compare/2.5.0...2.5.1)
_June 16, 2016_

- **Error Messaging:** When a response body cannot be properly decoded/encoded
  using the `Encoding` dictated by the `content-type` header, a
  `ResponseFormatException` will now be thrown with a much more descriptive
  message. The content-type, encoding, and body will be included.

## [2.5.0](https://github.com/Workiva/w_transport/compare/2.4.0...2.5.0)
_June 15, 2016_

- **Bug Fix:** `WSocket` extends `Stream` and `StreamSink`, but was not
  fulfilling those contracts in all scenarios. In particular:

  - After obtaining a `StreamSubscription` instance from a call to
    `WSocket.listen()`, reassigning the `onData()`, `onError()`, and `onDone()`
    handlers had no effect.

      ```dart
      var webSocket = await WSocket.connect(...);
      var subscription = webSocket.listen((data) { ... });

      // This does nothing:
      subscription.onData((data) { ... });
      // Same goes for onError() and onDone()
      ```

  - A subscription to a `WSocket` instance did not properly respect pause and
    resume signals. This could produce a memory leak by buffering WebSocket
    events indefinitely.

  - A `WSocket` instance was immediately listening to the underlying WebSocket
    and buffering events from the underlying WebSocket until a listener was
    registered. This is not how a standard Dart `Stream` works.

  - The SockJS configuration was not properly handling the fact that the SockJS
    `Client` produces WebSocket events with a broadcast stream.

  - **All of these issues have been addressed, and every `WSocket` instance
    should now behave exactly as a standard `Stream` and `StreamSink` would,
    regardless of the platform (VM, browser, SockJS, or mock).**

> The `WSocketCloseEvent` class has been deprecated. This class was only used
> internally and should not have been exported as a part of the public API.

> The WSocket implementations are no longer registering an `onError` handler for
> the underlying WebSocket stream. If an error occurs on the server, it will not
> add the error to the stream, it will just close the connection. As a result,
> the `MockWSocket.triggerServerError()` method has been deprecated - use
> `MockWSocket.triggerServerClose()` instead.

## [2.4.0](https://github.com/Workiva/w_transport/compare/2.3.2...2.4.0)
_May 4, 2016_

- **Improvement:** `FormRequest` now supports fields with multiple values.

    ```dart
    var request = new FormRequest()
      ..fields['multi'] = ['one', 'two'];
    ```

- **SDK Compatibility:** Dart 1.16 exposed a new `Client` class from the
  `dart:html` library that conflicted with the `Client` class in this library.
  This has been fixed by adjusting our imports internally, but it may still
  affect consumers of this library.

- **Documentation:** fixed inaccurate documentation around mocking & testing
  with WebSockets.

## [2.3.2](https://github.com/Workiva/w_transport/compare/2.3.0...2.3.2)
_March 2, 2016_

- **Bug Fix:** requests created from a `Client` now properly inherit all of the
  `autoRetry` configuration. Previously the `backOff`, `forTimeouts`, and
  `maxRetries` settings were missing.

## [2.3.0](https://github.com/Workiva/w_transport/compare/2.2.0...2.3.0)
_February 11, 2016_

### Features

- Implemented retry back-off to allow fixed or exponential back-off between
  request retries. By default, there is no back-off.

    ```dart
    // Fixed back-off: 1 second between attempts.
    var request = new Request();
    request.autoRetry
      ..enabled = true
      ..backOff = new RetryBackOff.fixed(new Duration(seconds: 1));

    // Exponential back-off: 250ms, 500ms, 1s, 2s, etc (base*2^attempt)
    var request = new Request();
    request.autoRetry
      ..enabled = true
      ..backOff = new RetryBackOff.exponential(new Duration(milliseconds: 125));
  ```

- Added methods to all request classes for manually retrying failures. This is
  mainly useful for corner cases where the request's success is dependent on
  something else and where automatic retrying won't help.

    ```dart
    var request = new Request();
    // send request, catch failure

    var response = await request.retry(); // normal
    var response = await request.streamRetry(); // streamed
    ```

- Improved error messaging around failed requests. If automatic retrying is
  enabled, the error message for a failed request will include each individual
  attempt and why it failed.

## [2.2.0](https://github.com/Workiva/w_transport/compare/2.1.0...2.2.0)
_February 8, 2016_

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

- Added a `Duration sockJSTimeout` config option to `WSocket.connect()`.

    ```dart
    // browser only
    var socket = await WSocket.connect(Uri.parse('...'),
        useSockJS: true, sockJSTimeout: new Duration(seconds: 5));
    ```

## [2.1.0](https://github.com/Workiva/w_transport/compare/2.0.0...2.1.0)
_January 7, 2016_

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


## [2.0.0](https://github.com/Workiva/w_transport/compare/1.0.1...2.0.0)
_November 24, 2015_

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


## [1.0.1](https://github.com/Workiva/w_transport/compare/1.0.0...1.0.1)
_June 23, 2015_

**Bug Fixes:**

- Allow request data to be set to `null`.
- Canceling an in-flight request now properly results in the returned Future
  completing with an error.
- Request data type validation now happens when sending the request instead of
  upon assignment, allowing intermediate data assignments.
- Verify w_transport configuration has been set before constructing a `WHttp`
  instance.


## [1.0.0](https://github.com/Workiva/w_transport/compare/f9a8277b552902db962b8eb3d41c82ded4900284...1.0.0)
_May 21, 2015_

- Initial version of w_transport: a fluent-style, platform-agnostic library with
  ready to use transport classes for sending and receiving data over HTTP.
