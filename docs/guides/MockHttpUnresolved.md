
#### Verifying there are no unresolved requests and/or unsatisfied expectations
```dart
MockTransports.verifyNoOutstandingExceptions();
```

> This will throw if an expected request has yet to occur or if a request was
> made for which no applicable handler was found and was not otherwise expected.
