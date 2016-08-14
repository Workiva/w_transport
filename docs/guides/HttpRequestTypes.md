### Request Types
Now that we've established the API common across all of our `Request` classes,
let's dive into the different types of requests that are supported.

* `Request`
* `JsonRequest`
* `FormRequest`
* `MultipartRequest`


#### `Request` (plain-text)
A `Request` sets the content-type to `text/plain` and accepts either a `String`
or a list of bytes (`List<int>`) as the body.

```dart
// Request body as string
Request request = new Request()
  ..uri = Uri.parse('/notes/')
  ..body = 'My notes.';

// Request body as bytes
Request request = new Request()
  ..uri = Uri.parse('/notes/')
  ..bodyBytes = UTF8.encode('My notes.');
```

The latter approach is useful if you are already dealing with encoded data - no
need to translate back and forth between bytes and text just to fit the API.

> Be sure to set `encoding` if using something other than the default UTF8.


#### `JsonRequest`
A `JsonRequest` sets the content-type to `application/json` and accepts
JSON-encodable `Map`s or `List`s for the request body.

```dart
var note = {
  'title': 'My Note',
  'contents': '...',
  'date': new DateTime.now().toString()
};
JsonRequest request = new JsonRequest()
  ..uri = Uri.parse('/notes/')
  ..body = note;
await request.post();
```

Prior to sending a `JsonRequest`, the request body will be encoded to an
appropriate format (text or bytes, depending on the platform).


#### `FormRequest`
A `FormRequest` sets the content-type to `application/x-www-form-urlencoded` and
accepts a `Map<String, String>` for the request body where each key-value pair
represents a form field's name and value.

By default, a `FormRequest`'s body is an empty `Map`, allowing you to
incrementally set each field.

```dart
FormRequest request = new FormRequest()
  ..uri = Uri.parse('/notes/')
  ..fields['title'] = 'My Note'
  ..fields['contents'] = '...'
  ..fields['date'] = new DateTime.now().toString();
await request.post();
```


#### `MultipartRequest`
A `MultipartRequest` sets the content-type to `multipart/form-data` and accepts
both fields and files for the request body. The `MultipartRequest` class takes
care of generating a unique boundary string used to separate each part of the
request body.

The fields are key-value pairs representing a form field's name and value, just
like the `FormRequest`:

```dart
MultipartRequest request = new MultipartRequest()
  ..uri = Uri.parse('/notes/')
  ..fields['title'] = 'My Note'
  ..fields['date'] = new DateTime.now().toString();
```

The files are also key-value pairs, but each pair represents a file's name and
object. The actual file object can be several different types.

> This is one area where the API is _not_ entirely platform-independent because
> the APIs for file I/O in the browser are so restricted that they cannot easily
> be abstracted.

This library includes a `MultipartFile` class as an option for a
platform-independent file abstraction, but it requires that you have access to
a byte stream to construct an instance.

The `files` map accepts the following types:

- `MultipartFile` (any platform)
- `dart:html.File` (browser)
- `dart:html.Blob` (browser)

```dart
Stream<List<int>> byteStream;
int length;
MultipartFile file = new MultipartFile(byteStream, length);

MultipartRequest request = new MultipartRequest()
  ..uri = Uri.parse('/notes/')
  ..fields['title'] = 'My Note'
  ..files['attachment'] = file;
```
