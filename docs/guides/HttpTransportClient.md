

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
