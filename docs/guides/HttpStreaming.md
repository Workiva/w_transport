

#### `StreamedRequest`
A `StreamedRequest` accepts a byte stream (`Stream<List<int>>`) as the request
body. When a `StreamedRequest` is sent, the headers will be sent immediately,
but the request body will be sent as items are added to the stream. Once the
stream has been closed and has finished, the request will end.

```dart
List<int> encoded = UTF8.encode('data');
Stream<List<int>> byteStream = new Stream.fromIterable(encoded);

StreamedRequest request = new StreamedRequest()
  ..uri = Uri.parse('/bytes/')
  ..body = byteStream;
```

> Note: the stream you supply should be a single-subscription stream (not a
> broadcast stream) to avoid losing data.


### Streamed Responses
As mentioned above, every response is loaded in its entirety into memory by
default. This can be problematic for extremely large responses. The solution is
to request the response as a stream of data so that it's loaded asynchronously
and - if large enough - in chunks.

To request a streamed response, use the corresponding `stream` method. For
example, instead of `get()`, use `streamGet()`.

```dart
StreamedResponse response = await Http.streamGet(Uri.parse('/file'));
response.body.byteStream.listen((List<int> bytes) { ... });
```
