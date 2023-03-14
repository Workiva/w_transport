## HTTP: Sending a Request, Receiving a Response, and Handling a Failure


### Static Request Methods

For one-off or simple requests, use the static methods on the `Http` class:
```dart
await transport.Http.get(Uri.parse('/ping'));
await transport.Http.post(Uri.parse('/tasks/2'), body: 'new task');
```

These standard HTTP methods are supported:

* DELETE : `transport.Http.delete()`
* GET : `transport.Http.get()`
* HEAD : `transport.Http.head()`
* OPTIONS : `transport.Http.options()`
* PATCH : `transport.Http.patch()`
* POST : `transport.Http.post()`
* PUT : `transport.Http.put()`

If you need to send a request with a non-standard HTTP method, use `send()`:
```dart
await transport.Http.send('COPY', Uri.parse('/tasks/4'));
```


### Request Classes

The above works well for simple requests, but what if you need to send JSON? Or
use a different encoding? Send a multi-part request? Or maybe you just want more
explicit control over the request. In these cases, you'll want to use one of the
exposed request classes:

* `transport.Request`
* `transport.FormRequest`
* `transport.JsonRequest`
* `transport.MultipartRequest`
* `transport.StreamedRequest`

> Every request class extends from `transport.BaseRequest`.

Each request type has some idiosyncrasies, but they share a common underlying
API. To start, we'll demonstrate sending requests using the plain-text
`transport.Request` class. (To see usages of the other types of requests,
[check out this guide](/docs/HttpRequestTypes.md).)


### Creating & Sending a Request

```dart
var request = new transport.Request();
```

At this point, there's nothing special about this request, and you'd use it
almost exactly like you'd use the static request methods from above:

```dart
var request = new transport.Request();
await request.post(uri: Uri.parse('/notes/'),
                   headers: {'x-auth-token': 'a390bn'},
                   body: 'A note.');
```

As you'll notice, all of the parameters are optional - even the `uri` - because
they can be set directly on the `transport.Request` instance before being sent:

```dart
var request = new transport.Request()
  ..uri = Uri.parse('/notes/')
  ..headers = {'x-auth-token': 'a390bn'}
  ..body = 'A note.';
await request.post();
```

> For simpler requests, it's recommended that you follow the first example and
> set the `uri`, `headers`, and/or `body` when dispatching the request (in other
> words, when you call `.get()`, `.post()`, etc).
>
> For requests with more configuration or where the configuration may need to
> be broken up into several steps, follow the latter example and set these
> properties on the request instance directly.

Again, all of the standard HTTP methods are supported and each has its own
method (`get()`, `post()`, etc). If you need to send a request with a custom
HTTP method, use `send()`:

```dart
var request = new transport.Request();
await request.send('COPY', uri: Uri.parse('/notes/6'));
```


### Responses

Every request, once sent, is asynchronous and eventually returns a response.

```dart
var request = new transport.Request()
  ..uri = Uri.parse('/notes/')
  ..body = 'A note.';
var response = await request.post();
```

This `transport.Response` instance contains meta information about the response:

```dart
var response = await transport.Http.get(Uri.parse('/notes/1'));

// Status code (e.g. 200)
print(response.status);

// Response headers (e.g. {'x-user': 'example', ...})
print(response.headers);

// Content-length parsed from headers (e.g. 110)
print(response.contentLength);

// Content-type parsed from headers (e.g. 'text/plain')
print(response.contentType);
```

The `transport.Response` instance also includes the response body. By default,
the entire response body is loaded into memory and made available to you in
three different formats:

#### Response Body: Bytes
The response is left in its encoded state and returned directly to you as a list
of bytes.

```dart
var response = await transport.Http.get(Uri.parse('/file'));
Uint8List body = response.body.asBytes();
```

> Note: In the browser, requests are sent via XHR and non-streamed responses are
> received as text rather than as a blob. In cases where you're expecting a
> binary response format and plan to read that response via `.asBytes()`,
> prefer using `streamGet()` instead. This will result in the response being
> received as a blob so that no encoding is necessary when calling `.asBytes()`.

#### Response Body: Text
The response's `content-type` header is inspected for a `charset` parameter. If
found and if valid, the corresponding encoding will be used to decode the
response body to text. Otherwise, the default `LATIN1` encoding will be used.

```dart
var response = await transport.Http.get(Uri.parse('/file'));
String body = response.body.asString();
```

#### Response Body: JSON
The response is decoded to text (using the above process) and then decoded into
either a `Map` or a `List`.

> This will throw if the response body is not valid JSON.

```dart
var response = await transport.Http.get(Uri.parse('/file'));
Map body = response.body.asJson();
```


### Failed Requests (`RequestException`)

As shown above, every request when dispatched returns a `Future` that eventually
resolves with a response. **This is only the case when the request returns
successfully with a 200-level status code (>=200, <300).**

If a request returns with a non-200 status code, the `Future` will resolve with
a `transport.RequestException`. This `transport.RequestException` instance
includes the original request instance, the request URI and HTTP method, and the
response (if available).

```dart
transport.Response response;
try {
  response = await transport.Http.get(Uri.parse('/notes/'));
} on transport.RequestException catch (e) {
  String method = e.method;
  Uri uri = e.uri;
  transport.Request request = e.request;
  transport.Response response = e.response;
}
```
