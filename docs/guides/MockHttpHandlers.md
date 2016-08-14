

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
