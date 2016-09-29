## HTTP: Streaming Requests and Responses

A `transport.StreamedRequest` accepts a byte stream (`Stream<List<int>>`) as the
request body. When a `StreamedRequest` is sent, the headers will be sent
immediately, but the request body will be sent as items are added to the stream.
Once the stream has been closed and has finished, the request will end.

> Note: the stream you supply should be a single-subscription stream (not a
> broadcast stream) to avoid losing data.

```dart
List<int> encoded = UTF8.encode('data');
Stream<List<int>> byteStream = new Stream.fromIterable(encoded);

var request = new transport.StreamedRequest()
  ..uri = Uri.parse('/bytes/')
  ..body = byteStream;
```

> **Important:** in the browser, do **not** use a `transport.StreamedRequest` to
upload files. The browser restricts access to the filesystem for security
reasons and using a `transport.StreamedRequest` to send a file will result in
the entire file being loaded into memory. Instead, use a
`transport.MultipartRequest`. This will allow us to send the `dart:html.File`
instance to the underlying XMLHttpRequest which allows the browser to handle
streaming the file contents directly from the filesystem.

Every response is loaded in its entirety into memory by default
([more info here](/docs/guides/HttpSendRequestReceiveResponseHandleFailure.md#responses)).
This can be problematic for extremely large responses. The solution is to
request the response as a stream of data so that it's loaded asynchronously
and - if large enough - in chunks.

To request a streamed response, use the corresponding `stream` method. For
example, instead of `get()`, use `streamGet()`.

```dart
transport.StreamedResponse response = await transport.Http.streamGet(Uri.parse('/file'));
response.body.byteStream.listen((List<int> bytes) { ... });
```
