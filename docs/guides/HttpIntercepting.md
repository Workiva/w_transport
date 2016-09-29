## HTTP: Intercepting Requests and Responses

### Intercepting Individual Requests and Responses

All of the request classes have hooks that allow request and response
interception.

> Although hooks for interception are available on the request classes, their
> purpose is to enable an API on the
> [`transport.HttpClient` class](/docs/guides/HttpClient.md) for intercepting
> every request created by the client, which is much more useful.

**Request interception** occurs right before the request is dispatched, at which
point changes (async if necessary) to the request instance can be made.

```dart
var request = new transport.Request();

// Register a hook to intercept the request.
request.requestInterceptor = (transport.Request request) async {
  // Modify the request as necessary.
};
```

**Response interception** occurs after the response is received but before it is
delivered to the caller. At this point, a finalized version of the request can
be inspected and the response instance can be modified, augmented, or replaced.
Additionally, a `transport.RequestException` instance will be available if one
occurred. Again, this interception can be async if necessary.

```dart
var request = new transport.Request();

// Register a hook to intercept the response.
request.responseInterceptor =
    (transport.FinalizedRequest request, transport.BaseResponse response,
    [transport.RequestException exception]) async {
  // Return a `transport.BaseResponse` instance, modified as necessary.
};
```

> Note that while response interceptors _can_ replace the response instance (and
> thus are expected to return a `transport.BaseResponse` instance), request
> interceptors _cannot_ do this because the request creator's reference would then be
> incorrect. For this reason, request interceptors must modify the request in
> place.


### Intercepting Requests and Responses from an HTTP Client

As seen above, the request classes have hooks for intercepting the request and
the response which the `transport.HttpClient` class leverages to provide an API
for registering a chain of interceptors that will be applied to all requests and
resulting responses created by the client.

```dart
class HeaderInterceptor extends transport.HttpInterceptor {
  @override
  Future<transport.RequestPayload> interceptRequest(transport.RequestPayload payload) async {
    payload.request.headers['x-foo'] = 'bar';
    return payload;
  }
}

class QueryParamInterceptor extends transport.HttpInterceptor {
  @override
  Future<transport.RequestPayload> interceptRequest(transport.RequestPayload payload) async {
    payload.request.updateQuery({'baz': 'bar'});
    return payload;
  }
}

class StatusCodeRecorder extends transport.HttpInterceptor {
  List<int> statusCodes = [];

  @override
  Future<transport.BaseResponse> interceptResponse(transport.ResponsePayload payload) async {
    // Always null-check the response! The response may be null for several
    // reasons (e.g. request is canceled or timed out prior to completing, or 
    // the browser hides the response due to cross-origin restrictions).
    if (payload.response != null) {
      statusCodes.add(payload.response.status);
    }
    return payload;
  }
}

main() {
  var headerInterceptor = new HeaderInterceptor();
  var queryParamInterceptor = new QueryParamInterceptor();
  var statusCodeRecorder = new StatusCodeRecorder();

  var client = new transport.HttpClient()
    ..addInterceptor(headerInterceptor)
    ..addInterceptor(queryParamInterceptor)
    ..addInterceptor(statusCodeRecorder);

  // The client will create a request interceptor that chains together the logic
  // from all three of the interceptors registered above. This will be set on the
  // request, meaning that this request will have an `x-foo: bar` header, a
  // `baz=bar` query parameter, and the status code of the response will be
  // stored in `statusCodeRecorder.statusCodes`.
  client.newRequest().get(uri: Uri.parse('...'));
```

Obviously these examples are contrived, but this pattern enables some powerful
functionality. Consider the following interceptors as possibilities:

- **Analytics:** records types of requests, request duration, request
  failures, etc.
- **CSRF:** sets a header for CSRF verification on outgoing mutation requests
  and updates said token if the response headers include a new one.
- **OAuth2:** sets the `Authorization` header to a valid OAuth2 token.
- **Session monitoring:** watches for failures due to invalid session, like an
  HTTP 401 failure.

This interceptor logic is asynchronous, which means that you can get really
creative. Let's take the CSRF interceptor example and consider a scenario where
the initial request requires a CSRF token but one is not known at the time. We
can preempt the request and send a separate request to obtain a token:

```dart
class CsrfInterceptor extends transport.HttpInterceptor {
  Uri csrfEndpointUri = ...;
  String token;

  @override
  Future<transport.RequestPayload> interceptRequest(transport.RequestPayload payload) async {
    if (token == null) {
      token = await fetchNewToken();
    }
    payload.request.headers['x-xsrf-token'] = token;
    return payload;
  }

  // Assuming we have an endpoint to retrieve a CSRF token.
  Future<String> fetchNewToken() async {
    var response = await transport.Http.get(csrfEndpointUri);
    return response.body.asJson()['token'];
  }
}
```
