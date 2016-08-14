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
