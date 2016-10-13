## HTTP: Canceling and Timing-out Requests

All of the request classes support cancellation. At any time, the `.abort()`
method can be called. If the request has not completed yet, it will be canceled.
If it has already completed, it has no effect.

```dart
var request = new transport.Request();
request.get(Uri.parse('/notes/'));
...
request.abort();
```

Additionally, a timeout threshold can be set on any request. If the request
takes longer than the set duration, the request will be canceled.

```dart
var request = new transport.Request()
  ..uri = Uri.parse('/notes/')
  ..timeoutThreshold = new Duration(seconds: 15);
request.get();
// This will throw if the request takes longer than 15 seconds.
```
