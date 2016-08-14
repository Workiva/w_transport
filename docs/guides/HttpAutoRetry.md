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
