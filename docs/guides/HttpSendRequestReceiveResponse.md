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


### TODO: RequestException
