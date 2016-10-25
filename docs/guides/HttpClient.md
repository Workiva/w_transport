## HTTP: Client

An HTTP client acts as a single point from which many requests can be
constructed. All requests constructed from a client will inherit the following:

- Base URI
- Request headers
- Timeout threshold
- `withCredentials` flag
- Automatic retrying config
- Request & response interceptors

On the server, the Dart VM will also be able to take advantage of cached
network connections between requests that share a client.

```dart
var client = new transport.HttpClient()
  ..headers['x-xsrf-token'] = 'ab93c...'
  ..withCredentials = true;

// This request will inherit the above header and withCredentials value.
// Once created, it can be used and dispatched as expected.
var request = client.newRequest();
```

If you know that a client will no longer be used, or if you'd like to cancel all
outstanding requests from a client, you should close the client. On the server,
this ensures that cached network connections are closed.

```dart
var client = new transport.HttpClient();
...
client.close();
```
