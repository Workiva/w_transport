## Testing/Mocks: Mock Responses

When using the HTTP mock APIs you'll most likely want to provide custom mocked
responses. To assist with this, there's a `MockResponse` class available that
makes it easy to create mock responses with any status code, headers, and body.

```dart
var ok = new MockResponse.ok();
print(ok.status); // 200

var notFound = new MockResponse.notFound();
print(notFound.status); // 404

var serverError = new MockResponse.internalServerError();
print(serverError.status); // 500

var customResponse = new MockResponse(499);
print(customResponse.status); // 499

var responseWithHeaders = new MockResponse.ok(headers: {'x-token': 'abc123'});
print(responseWithHeaders.headers); // {'x-token': 'abc123'}

var responseWithBody = new MockResponse.ok(body: 'example');
print(responseWithBody.body.asString()); // 'example'

var body = {'result': 'success'};
var responseWithJsonBody = new MockResponse.ok(body: JSON.encode(body));
print(responseWithJsonBody.body.asJson()); // {'result': 'success'}
```

If you need to provide a streamed response, there is a `MockStreamedResponse`
that can be used just like the `MockResponse` class above. The only difference
is that the body would need to be a stream of bytes.
