## Testing/Mocks: HTTP Expectations

Expectations are one-time only. Every time a mock-aware request is dispatched,
it is compared against the list of unsatisfied expectations and chooses the
first match (if one exists) to use to resolve said request.

### Expecting a request (and returning a 200 OK response by default)

By default, an expected request is resolved with a successful 200 OK response.

> The expected URI must match exactly, including scheme, host, path, and query.

```dart
var uri = Uri.parse('https://example.org/resource');
MockTransports.http.expect('GET', uri);
var response = await transport.Http.get(uri);
print(response.status); // 200
```

### Expecting a request and providing a custom response

Alternatively, you can specify a response to use.

```dart
var uri = Uri.parse('https://example.org/resource');
var response = new MockResponse.unauthorized(
    body: 'Invalid access token',
    headers: {'x-session': 'ab93s...'});
MockTransports.http.expect(
    'GET',
    uri,
    respondWith: response);
try {
  await transport.Http.get(uri);
} on transport.RequestException catch (e) {
  print(e.response.status); // 401
  print(e.response.body.asString()); // 'Invalid access token'
}
```

### Expecting a request and causing a failure (exception)

Causing a failure is slightly different than returning a mock response with a
non-200 response code. The following example simulates an exception that would
be thrown during the transport logic prior to sending a request or after
receiving a response (e.g. a request/response interceptor throwing).

```dart
var uri = Uri.parse('https://example.org/resource');
MockTransports.http.expect(
    'GET',
    uri,
    failWith: new Exception('Unexpected error...'));
try {
  await transport.Http.get(uri);
} on transport.RequestException catch (e) {
  print(e.error); // 'Unexpected error...'
}
```

> Note that the request logic always wraps errors and exceptions that happen
> during the request attempt in a `transport.RequestException`. The original
> error (if applicable) can be found via the `error` property as seen above.

### Expecting a request that matches a URI pattern

Using `expect()` requires that the request matches the given URI exactly.
If you don't know the exact URI or would like to be more flexible in your
matching, you can use `expectPattern()`.

```dart
var uriPattern = new RegExp('.*/example');
MockTransports.http.expectPattern('GET', uriPattern);
var response = await transport.Http.get(Uri.parse('http://localhost:8080/example'));
print(response.status); // 200
```
