## Testing/Mocks: HTTP Handlers

Once registered, handlers continue to serve matching requests until canceled or
until the transport mocks are reset/uninstalled.

### Registering a handler to match requests by URI

> The expected URI must match exactly, including scheme, host, path, and query.

```dart
MockTransports.http.when(
    Uri.parse('https://example.org/resource'),
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

### Registering a handler to match requests by URI and method

```dart
MockTransports.http.when(
    Uri.parse('https://example.org/resource'),
    (FinalizedRequest request) async => new MockResponse.ok(body: '...'),
    method: 'GET');
```

### Registering a handler to match requests by a URI pattern

Just like HTTP expectations, there is an alternate way to register handlers that
allows matching via a `Pattern` for greater flexibility. This is especially
useful for handlers since it essentially lets you define mock endpoints that can
handle dynamic parameters in the path or query.

```dart
MockTransports.http.whenPattern(
    new RegExp('.*/notes/(\w+)$'),
    (FinalizedRequest request, Match match) async {
      var id = match.group(1);
      if (id == null) {
        // return all notes
      } else {
        // return note identified by the ID from the URI
      }
    });
```

### Canceling a handler

Both `when()` and `whenPattern()` return a `MockHttpHandler` instance that can
be used to cancel/unregister the handler.

```dart
var mockHandler = MockTransports.http.when(...);
...
mockHandler.cancel();
```
