# w_transport 
[![Pub](https://img.shields.io/pub/v/w_transport.svg)](https://pub.dartlang.org/packages/w_transport)
[![Build Status](https://travis-ci.org/Workiva/w_transport.svg?branch=travis-ci)](https://travis-ci.org/Workiva/w_transport)
[![codecov.io](http://codecov.io/github/Workiva/w_transport/coverage.svg?branch=master)](http://codecov.io/github/Workiva/w_transport?branch=master)
[![documentation](https://img.shields.io/badge/Documentation-w__transport-blue.svg)](https://www.dartdocs.org/documentation/w_transport/latest/)

> Platform-agnostic transport library for sending and receiving data over HTTP
> and WebSocket. HTTP support includes plain-text, JSON, form-data, and
> multipart data, as well as custom encoding. WebSocket support includes native
> WebSockets in the browser and the VM with the option to use SockJS in the
> browser.


- [**Importing**](#importing)
- [**Platforms**](#platforms)
  - [Browser](#browser)
  - [Browser (SockJS)](#browser-sockjs)
  - [Dart VM](#dart-vm)
  - [Tests](#tests)
- [**HTTP**](#http)
  - [Static Request Methods](#static-request-methods)
  - [Request Classes](#request-classes)
  - [Common Request API](#common-request-api)
    - [Creating a Request](#creating-a-request)
    - [Canceling a Request](#canceling-a-request)
    - [Credentials (browser only)](#credentials-browser-only)
    - [Content-Length, Content-Type and Encoding](#content-length-content-type-and-encoding)
    - [Timeout Threshold](#timeout-threshold)
    - [Request & Response Interception](#request--response-interception)
    - [Automatic Request Retrying](#automatic-request-retrying)
  - [Request Types](#request-types)
    - [JsonRequest](#jsonrequest)
    - [FormRequest](#formrequest)
    - [MultipartRequest](#multipartrequest)
    - [Request (plain-text)](#request-plain-text)
    - [StreamedRequest](#streamedrequest)
  - [HTTP Client](#http-client)
    - [Intercepting Requests & Responses from a Client](#intercepting-requests--responses-from-a-client)
  - [Responses](#responses)
  - [Streamed Responses](#streamed-responses)
- [**WebSocket**](#websocket)
  - [Establishing a Connection](#establishing-a-connection)
  - [Receiving Data](#receiving-data)
  - [Sending Data](#sending-data)
  - [Listening for Completion](#listening-for-completion)
- [**Testing & Mocks**](#testing--mocks)
  - [Mocking HTTP](#mocking-http)
  - [Mocking WebSockets](#mocking-websockets)
- [**Credits**](#credits)
- [**Development**](#development)


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
import 'package:w_transport/w_transport_browser.dart'
    show configureWTransportForBrowser;

void main() {
  configureWTransportForBrowser();
}
```

### Browser (SockJS)
```dart
import 'package:w_transport/w_transport_browser.dart'
    show configureWTransportForBrowser;

void main() {
  configureWTransportForBrowser(
      useSockJS: true,
      sockJSProtocolsWhitelist: ['websocket', 'xhr-streaming']);
}
```

### Dart VM
```dart
import 'package:w_transport/w_transport_vm.dart'
    show configureWTransportForVM;

void main() {
  configureWTransportForVM();
}
```

### Tests
```dart
import 'package:w_transport/w_transport_mock.dart'
    show configureWTransportForTest;

void main() {
  configureWTransportForTest();
}
```

---

## HTTP

### Static Request Methods

For one-off or simple requests, use the static methods on the `Http` class:
```dart
await Http.get(Uri.parse('/ping'));
await Http.post(Uri.parse('/tasks/2'), body: 'new task');
```

These standard HTTP methods are supported:

* DELETE : `Http.delete()`
* GET : `Http.get()`
* HEAD : `Http.head()`
* OPTIONS : `Http.options()`
* PATCH : `Http.patch()`
* POST : `Http.post()`
* PUT : `Http.put()`

If you need to send a request with a non-standard HTTP method, use `send()`:
```dart
await Http.send('COPY', Uri.parse('/tasks/4'));
```

#### Headers
```dart
Map headers = {
  'authorization': 'Bearer sometoken',
  'x-custom': 'value'
};
await Http.get(Uri.parse('/notes/'), headers: headers);
```

#### Plain-Text Body
```dart
await Http.post(Uri.parse('/notes/'), body: 'testing..');
```

> Plain-text request bodies default to UTF8 encoding.


### Request Classes
The above works well for simple requests, but what if you need to send JSON? Or
use a different encoding? Send a multi-part request? Or maybe you just want more
explicit control over the request. In these cases, you'll want to use one of the
exposed request classes:

* `Request`
* `FormRequest`
* `JsonRequest`
* `MultipartRequest`
* `StreamedRequest`

> Every request class extends from `BaseRequest`.


### Common Request API
Though each request type has some idiosyncrasies, they share a common underlying
API. We'll cover this common API using `Request` as the example.

#### Creating a Request
```dart
Request request = new Request();
```
At this point, there's nothing special about this request, and you'd use it
almost exactly like you'd use the top-level request API from above:

```dart
Request request = new Request();
await request.post(uri: Uri.parse('/notes/'),
                   headers: {'x-auth-token': 'a390bn'},
                   body: 'A note.');
```

As you'll notice, all of the parameters are optional - even the `uri` - because
they can be set on the `Request` directly before being sent:

```dart
Request request = new Request()
  ..uri = Uri.parse('/notes/')
  ..headers = {'x-auth-token': 'a390bn'}
  ..body = 'A note.';
await request.post();
```

> For simpler requests, it's recommended that you set the `uri`, `headers`,
> and/or `body` when dispatching the request (in other words, when you call
> `.get()`, `.post()`, etc).
>
> For requests with more configuration or where the configuration may need to
> be broken up into several steps, set these properties on the request object
> directly.

Again, all of the standard HTTP methods are supported and each has its own
method (`get()`, `post()`, etc). If you need to send a request with a custom
HTTP method, use `send()`:

```dart
Request request = new Request();
await request.send('COPY', uri: Uri.parse('/notes/6'));
```

#### Canceling a Request
All of the request classes support cancellation. At any time, the `.abort()`
method can be called. If the request has not completed yet, it will be canceled.
If it has already completed, it has no effect.

```dart
Request request = new Request();
request.get(Uri.parse('/notes/'));
...
request.abort();
```

#### Credentials (browser only)
HTTP requests made from a browser have an added restriction - secure cookies are
not sent by default on cross-origin requests. To include these secure cookies
when sending a request, set `withCredentials` to `true`. Although this only
applies to browsers, it's included in the platform-independent API because it
has no effect on the other platforms.

```dart
Request request = new Request()
  ..uri = Uri.parse('https://otherhost.com/notes/')
  ..withCredentials = true;
await request.get();
```

#### Content-Length, Content-Type and Encoding
All of the request classes set the `content-type` automatically based on the
type of data being sent in the request body, and the `charset` parameter is set
using the encoding's name.

> By default, UTF8 encoding is used for requests.

The content-type of a request is available as `.contentType` and is of type
`MediaType` from [the `http_parser` package](https://github.com/dart-lang/http_parser).

> This property is read-only and is updated based on the type of data in the
> request body and the encoding. The exception to this is a streamed request
> where the request body is asynchronous and thus not known ahead of time.

Additionally, the `content-length` is set automatically for all `Request`
classes since the length of the body in bytes is known before sending. The
content-length of a request is available as the read-only property
`.contentLength` and is the number of bytes of the request body when encoded.

> Again, the exception to this is `StreamedRequest` since the body is sent
> asynchronously.

Consider the following plain-text request:
```dart
Request request = new Request()
  ..body = 'Hello World ®';

print(request.contentType.toString());
// content-type: text/plain; charset=utf-8
print(request.contentLength);
// 14
```

As you can see, the content-type is `text/plain` because the request body is
plain-text and the charset is `utf-8` because UTF8 encoding is used by default.

Let's change the encoding:
```dart
Request request = new Request()
  ..body = 'Hello World ®'
  ..encoding = LATIN1;

print(request.contentType.toString());
// content-type: text/plain; charset=iso-8859-1
print(request.contentLength);
// 13
```

The content-type value will change based on the type of request being sent. For
plain `Request`s, it will always be `text/plain`. The other supported request
types will set the content-type as follows:

* `FormRequest`: `application/x-www-form-urlencoded`
* `JsonRequest`: `application/json`
* `MultipartRequest`: `multipart/form-data`

#### Timeout Threshold
A timeout threshold can be set on any request. If the request takes longer than
the set duration, the request will be canceled.

```dart
Request request = new Request()
  ..uri = Uri.parse('/notes/')
  ..timeoutThreshold = new Duration(seconds: 15);
request.get();
// This will throw if the request takes longer than 15 seconds.
```

#### Request & Response Interception
All of the request classes have hooks that allow request and response
interception.

> Although hooks for interception are available on the request classes, their
> purpose is to enable an API on the [`Client` class](#http-client) for
> intercepting every request created by the client, which is much more useful.

**Request interception** occurs right before the request is dispatched, at which
point changes (async if necessary) to the request instance can be made.

```dart
Request request = new Request();

// Register a hook to intercept the request.
request.requestInterceptor = (Request request) async {
  // Modify the request as necessary.
};
```

**Response interception** occurs after the response is received but before it is
delivered to the caller. At this point, a finalized version of the request can
be inspected and the response instance can be modified, augmented, or replaced.
Additionally, a `RequestException` instance will be available if one occurred.
Again, this interception can be async if necessary.

```dart
Request request = new Request();

// Register a hook to intercept the response.
request.responseInterceptor =
    (FinalizedRequest request, BaseResponse response,
    [RequestException exception]) async {
  // Return a `BaseResponse` instance, modified as necessary.
};
```

> Note that while response interceptors _can_ replace the response instance (and
> thus are expected to return a `BaseResponse` instance), request interceptors
> _cannot_ do this because the request creator's reference would then be
> incorrect. For this reason, request interceptors must modify the request in
> place.

#### Automatic Request Retrying
All of the request classes have an `autoRetry` API for enabling and configuring
automatic request retrying. For example, the following request is configured
to automatically retry up to 3 times for non-mutation requests that fail with
a 500 or a 502:

```dart
Request request = new Request();
request.autoRetry
  ..enabled = true
  ..maxRetries = 3
  ..forHttpMethods = ['GET', 'HEAD', 'OPTIONS']
  ..forStatusCodes = [500, 502];
```

See the documentation for more information.



### Request Types
Now that we've established the API common across all of our `Request` classes,
let's dive into the different types of requests that are supported.

* `JsonRequest`
* `FormRequest`
* `MultipartRequest`
* `Request`
* `StreamedRequest`

#### `JsonRequest`
A `JsonRequest` sets the content-type to `application/json` and accepts
JSON-encodable `Map`s or `List`s for the request body.

```dart
var note = {
  'title': 'My Note',
  'contents': '...',
  'date': new DateTime.now().toString()
};
JsonRequest request = new JsonRequest()
  ..uri = Uri.parse('/notes/')
  ..body = note;
await request.post();
```

Prior to sending a `JsonRequest`, the request body will be encoded to an
appropriate format (text or bytes, depending on the platform).


#### `FormRequest`
A `FormRequest` sets the content-type to `application/x-www-form-urlencoded` and
accepts a `Map<String, String>` for the request body where each key-value pair
represents a form field's name and value.

By default, a `FormRequest`'s body is an empty `Map`, allowing you to
incrementally set each field.

```dart
FormRequest request = new FormRequest()
  ..uri = Uri.parse('/notes/')
  ..body['title'] = 'My Note'
  ..body['contents'] = '...'
  ..body['date'] = new DateTime.now().toString();
await request.post();
```


#### `MultipartRequest`
A `MultipartRequest` sets the content-type to `multipart/form-data` and accepts
both fields and files for the request body. The `MultipartRequest` class takes
care of generating a unique boundary string used to separate each part of the
request body.

The fields are key-value pairs representing a form field's name and value, just
like the `FormRequest`:

```dart
MultipartRequest request = new MultipartRequest()
  ..uri = Uri.parse('/notes/')
  ..fields['title'] = 'My Note'
  ..fields['date'] = new DateTime.now().toString();
```

The files are also key-value pairs, but each pair represents a file's name and
object. The actual file object can be several different types.

> This is one area where the API is _not_ entirely platform-independent because
> the APIs for file I/O in the browser are so restricted that they cannot easily
> be abstracted.

This library includes a `MultipartFile` class as an option for a
platform-independent file abstraction, but it requires that you have access to
a byte stream to construct an instance.

The `files` map accepts the following types:

- `MultipartFile` (any platform)
- `dart:html.File` (browser)
- `dart:html.Blob` (browser)

```dart
Stream<List<int>> byteStream;
int length;
MultipartFile file = new MultipartFile(byteStream, length);

MultipartRequest request = new MultipartRequest()
  ..uri = Uri.parse('/notes/')
  ..fields['title'] = 'My Note'
  ..files['attachment'] = file;
```


#### `Request` (plain-text)
A `Request` sets the content-type to `text/plain` and accepts either a `String`
or a list of bytes (`List<int>`) as the body.

```dart
// Request body as string
Request request = new Request()
  ..uri = Uri.parse('/notes/')
  ..body = 'My notes.';

// Request body as bytes
Request request = new Request()
  ..uri = Uri.parse('/notes/')
  ..bodyBytes = UTF8.encode('My notes.');
```

The latter approach is useful if you are already dealing with encoded data - no
need to translate back and forth between bytes and text just to fit the API.

> Be sure to set `encoding` if using something other than the default UTF8.


#### `StreamedRequest`
A `StreamedRequest` accepts a byte stream (`Stream<List<int>>`) as the request
body. When a `StreamedRequest` is sent, the headers will be sent immediately,
but the request body will be sent as items are added to the stream. Once the
stream has been closed and has finished, the request will end.

```dart
List<int> encoded = UTF8.encode('data');
Stream<List<int>> byteStream = new Stream.fromIterable(encoded);

StreamedRequest request = new StreamedRequest()
  ..uri = Uri.parse('/bytes/')
  ..body = byteStream;
```

> Note: the stream you supply should be a single-subscription stream (not a
> broadcast stream) to avoid losing data.


### HTTP Client
An HTTP client acts as a single point from which many requests can be
constructed. All requests constructed from a client will inherit headers, the
`withCredentials` flag, and the timeout threshold.

On the server, the Dart VM will also be able to take advantage of cached
network connections between requests that share a client.

```dart
Client client = new Client()
  ..headers['x-xsrf-token'] = 'ab93c...'
  ..withCredentials = true;

// This request will inherit the above header and withCredentials value.
// Once created, it can be used and dispatched as expected.
Request request = client.newRequest();
```

If you know that a client will no longer be used, or if you'd like to cancel all
outstanding requests from a client, you should close the client. On the server,
this ensures that cached network connections are closed.

```dart
Client client = new Client();
...
client.close();
```

#### Intercepting Requests & Responses from a Client
The request classes have [hooks for intercepting the request and the response](#request--response-interception)
which the `Client` class leverages to provide an API for registering a chain of
interceptors that will be applied to all requests and subsequent responses
created by the client.

```dart
class HeaderInterceptor extends HttpInterceptor {
  @override
  Future<RequestPayload> interceptRequest(RequestPayload payload) async {
    payload.request.headers['x-foo'] = 'bar';
    return payload;
  }
}

class QueryParamInterceptor extends HttpInterceptor {
  @override
  Future<RequestPayload> interceptRequest(RequestPayload payload) async {
    payload.request.updateQuery({'baz': 'bar'});
    return payload;
  }
}

main() {
  Client client = new Client()
    ..addInterceptor(new HeaderInterceptor())
    ..addInterceptor(new QueryParamInterceptor());

  // The client will create a request interceptor that chains together the logic
  // from both of the interceptors registered above. This will be set on the
  // request, meaning that this request will have an `x-foo: bar` header and a
  // `baz=bar` query parameter.
  client.newRequest().get(uri: Uri.parse('...'));
```

Obviously these examples are contrived, but this pattern enables some powerful
functionality. Consider the following interceptors as possibilities:

- **Analytics:** records types of requests, request duration, request
  failures, etc.
- **CSRF:** sets a header for CSRF verification on outgoing mutation requests
  and updates said token if the response headers include a new one.
- **OAuth2:** sets the `Authorization` header to a valid OAuth2 token.
- **Session monitoring:** watches for failures due to invalid session, like an
  HTTP 401 failure.

This interceptor logic is asynchronous, which means that you can get really
creative. Let's take the CSRF interceptor example and consider a scenario where
the initial request requires a CSRF token but one is not known at the time. We
can preempt the request and send a separate request to obtain a token:

```dart
class CsrfInterceptor extends HttpInterceptor {
  Uri csrfEndpointUri = ...;
  String token;

  @override
  Future<RequestPayload> interceptRequest(RequestPayload payload) async {
    if (token == null) {
      token = await fetchNewToken();
    }
    payload.request.headers['x-xsrf-token'] = token;
    return payload;
  }

  // Assuming we have an endpoint to retrieve a CSRF token.
  Future<String> fetchNewToken() async {
    Response response = await Http.get(csrfEndpointUri);
    return response.body.asJson()['token'];
  }
}
```


### Responses
Every request, once sent, is asynchronous and eventually returns a response. By
default, the entire response is loaded into memory and made available to you in
three different formats:

#### Bytes
The response is left in its encoded state and returned directly to you as a list
of bytes.

```dart
Response response = await Http.get(Uri.parse('/file'));
Uint8List body = response.body.asBytes();
```

#### Text
The response's `content-type` header is inspected for a `charset` parameter. If
found and if valid, the corresponding encoding will be used to decode the response
body to text. Otherwise, the default `LATIN1` encoding will be used.

```dart
Response response = await Http.get(Uri.parse('/file'));
String body = response.body.asString();
```

#### JSON
The response is decoded to text (using the above process) and then decoded into
either a `Map` or a `List`.

> This will throw if the response body is not valid JSON.

```dart
Response response = await Http.get(Uri.parse('/file'));
Map body = response.body.asJson();
```

### Streamed Responses
As mentioned above, every response is loaded in its entirety into memory by
default. This can be problematic for extremely large responses. The solution is
to request the response as a stream of data so that it's loaded asynchronously
and - if large enough - in chunks.

To request a streamed response, use the corresponding `stream` method. For
example, instead of `get()`, use `streamGet()`.

```dart
StreamedResponse response = await Http.streamGet(Uri.parse('/file'));
response.body.byteStream.listen((List<int> bytes) { ... });
```

---


## WebSocket

The WebSocket API mirrors the `dart:io.WebSocket` class to keep things simple.
If you've used the VM's WebSocket class before, then you're ready to go. The
benefit is that this same API works in the browser as well (even when configured
to use SockJS), which is a big improvement over the `dart:html.WebSocket` class.

The `WSocket` class included in this library is a `Stream` and a `StreamSink`,
so sending and receiving data is as simple as adding items to it like a sink and
listening to it like a stream.

### Establishing a Connection
```dart
WSocket webSocket = await WSocket.connect(Uri.parse('ws://echo.websocket.org'));
```

> The `connect()` method will throw if a connection cannot be established.

### Receiving Data
```dart
WSocket webSocket = await WSocket.connect(Uri.parse('ws://echo.websocket.org'));

webSocket.listen((data) {
  // Handle message.
}, onError: (error) {
  // Handle error (if desired).
  // The socket will close immediately after this.
}, onDone: () {
  // Perform any cleanup if desired.
});
```

### Sending Data
```dart
WSocket webSocket = await WSocket.connect(Uri.parse('ws://echo.websocket.org'));
webSocket.add('message');
await webSocket.addStream(new Stream.fromIterable([...]));
```

### Listening for Completion
```dart
WSocket webSocket = await WSocket.connect(Uri.parse('ws://echo.websocket.org'));
webSocket.done.then((_) {
  // Perform cleanup, reopen socket, etc.
}).catchError((error) {
  // Handle socket error, reopen socket, etc.
});
```

---

## Testing & Mocks

Just like the browser or the Dart VM, tests are considered a platform for which
this library can be configured. By configuring `w_transport` for tests, mock
implementations of all classes will be used.

```dart
import 'package:w_transport/w_transport_mock.dart';

main() {
  configureWTransportForTest();
}
```

That's it. No changes to your source code are necessary! Once configured for
test, you are in control of every HTTP request and every WebSocket connection.
The APIs for controlling these transports are exported with the
`w_transport_mock.dart` entry point as static APIs on a `MockTransports` class.

> **Resetting Mocks:**
>
> At any point, you can reset all mock expectations and handlers, giving you a
> clean state to begin a new mock setup:
>
> ```dart
> MockTransports.reset();
> ```

### Mocking HTTP

#### Expecting a request (and returning a 200 OK response by default)
```dart
MockTransports.http.expect('GET', Uri.parse('/resource'));
```

#### Expecting a request and providing a custom response
```dart
Response response = new MockResponse.unauthorized(
    body: 'Invalid access token',
    headers: {'x-session': 'ab93s...'});
MockTransports.http.expect(
    'GET',
    Uri.parse('/resource'),
    respondWith: response);
```

#### Expecting a request and causing a failure (exception)
```dart
MockTransports.http.expect(
    'GET',
    Uri.parse('/resource'),
    failWith: new Exception('Unexpected error...'));
```

#### Registering a handler (expecting multiple requests to the same URI)
```dart
MockTransports.http.when(
    Uri.parse('/resource'),
    (FinalizedRequest request) async {
      if (request.method == 'GET') {
        return new MockResponse.ok(body: '...');
      }
      if (request.method == 'DELETE') {
        return new MockResponse(204);
      }
      ...
    });
```

#### Registering a handler (expecting multiple requests with the same URI and method)
```dart
MockTransports.http.when(
    Uri.parse('/resource'),
    (FinalizedRequest request) async => new MockResponse.ok(body: '...'),
    method: 'GET');
```

#### Verifying there are no unresolved requests and/or unsatisfied expectations
```dart
MockTransports.verifyNoOutstandingExceptions();
```

> This will throw if an expected request has yet to occur or if a request was
> made for which no applicable handler was found and was not otherwise expected.


### Mocking WebSockets

#### Expecting and accepting a websocket connection
```dart
MockTransports.webSocket.expect(
    Uri.parse('/ws'),
    handler: (Uri uri,
              {Iterable<String> protocols,
              Map<String, dynamic> headers}) async {
      return new MockWSocket();
    });
```

#### Expecting and rejecting a websocket connection
```dart
MockTransports.webSocket.expect(Uri.parse('/ws'), reject: true);
```

> This will cause the `WSocket.connect(...)` clause to throw.

#### Listening to outgoing data from a mock websocket connection
```dart
MockTransports.webSocket.expect(
    Uri.parse('/ws'),
    handler: (Uri uri,
              {Iterable<String> protocols,
              Map<String, dynamic> headers}) async {
      MockWSocket ws = new MockWSocket();
      ws.onOutgoing((data) { ... });
      return ws;
    });
```

#### Sending data to the client from a mock websocket connection
```dart
MockTransports.webSocket.expect(
    Uri.parse('/ws'),
    handler: (Uri uri,
              {Iterable<String> protocols,
              Map<String, dynamic> headers}) async {
      MockWSocket ws = new MockWSocket();

      // Connected message.
      ws.add('Connected.');

      // Echo.
      ws.onOutgoing((data) {
        ws.addIncoming(data);
      });

      return ws;
    });
```

#### Triggering a close event for a mock websocket connection
```dart
MockTransports.webSocket.expect(
    Uri.parse('/ws'),
    handler: (Uri uri,
              {Iterable<String> protocols,
              Map<String, dynamic> headers}) async {
      MockWSocket ws = new MockWSocket();

      new Timer(new Duration(seconds: 5), () {
        ws.triggerServerClose();
      });

      return ws;
    });
```


---

## Credits

This library was influenced in many ways by
[the `http` package](https://github.com/dart-lang/http), especially with regard
to multipart requests, and served as a useful source for references to pertinent
IETF RFCs.


## Development

This project leverages [the `dart_dev` package](https://github.com/Workiva/dart_dev)
for most of its tooling needs, including static analysis, code formatting,
running tests, collecting coverage, and serving examples. Check out the dart_dev
readme for more information.

> **Note:** to run integration tests, you'll need two JS dependencies for a
> SockJS server. Run an `npm install` to download them.