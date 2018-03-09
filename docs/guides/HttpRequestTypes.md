## HTTP: Request Types

The [basic guide to sending requests](https://github.com/Workiva/w_transport/blob/master/docs/guides/HttpSendRequestReceiveResponseHandleFailure.md)
introduced the API common to all request classes. Each class, however, is
designed to transport a specific type of data.

- [`transport.Request`](#transport-request-plain-text)
- [`transport.JsonRequest`](#transport-jsonrequest)
- [`transport.FormRequest`](#transport-formrequest)
- [`transport.MultipartRequest`](#transport-multipartrequest)


---


#### `transport.Request` (plain-text)

A `transport.Request` sets the content-type to `text/plain` and accepts either a
`String` or a list of bytes (`List<int>`) as the body.

```dart
// Request body as string
var request = new transport.Request()
  ..uri = Uri.parse('/notes/')
  ..body = 'My notes.';

// Request body as bytes
var request = new transport.Request()
  ..uri = Uri.parse('/notes/')
  ..bodyBytes = UTF8.encode('My notes.');
```

The latter approach is useful if you are already dealing with encoded data - no
need to translate back and forth between bytes and text just to fit the API.

> Be sure to set `encoding` if using something other than the default UTF8.


#### `transport.JsonRequest`

A `transport.JsonRequest` sets the content-type to `application/json` and
accepts JSON-encodable `Map`s or `List`s for the request body.

```dart
var note = {
  'title': 'My Note',
  'contents': '...',
  'date': new DateTime.now().toString()
};
var request = new transport.JsonRequest()
  ..uri = Uri.parse('/notes/')
  ..body = note;
await request.post();
```

Prior to sending a `transport.JsonRequest`, the request body will be encoded to
an appropriate format (text or bytes, depending on the platform).


#### `transport.FormRequest`

A `transport.FormRequest` sets the content-type to
`application/x-www-form-urlencoded` and accepts a `Map<String, String>` for the
request body where each key-value pair represents a form field's name and value.

By default, a `transport.FormRequest`'s body is an empty `Map`, allowing you to
incrementally set each field.

```dart
var request = new transport.FormRequest()
  ..uri = Uri.parse('/notes/')
  ..fields['title'] = 'My Note'
  ..fields['contents'] = '...'
  ..fields['date'] = new DateTime.now().toString();
await request.post();
```


#### `transport.MultipartRequest`
A `transport.MultipartRequest` sets the content-type to `multipart/form-data`
and accepts both fields and files for the request body. The
`transport.MultipartRequest` class takes care of generating a unique boundary
string used to separate each part of the request body.

The fields are key-value pairs representing a form field's name and value, just
like the `transport.FormRequest`:

```dart
var request = new transport.MultipartRequest()
  ..uri = Uri.parse('/notes/')
  ..fields['title'] = 'My Note'
  ..fields['date'] = new DateTime.now().toString();
```

The files are also key-value pairs, but each pair represents a file's name and
object. The actual file object can be several different types.

> This is one area where the API is _not_ entirely platform-independent because
> the APIs for file I/O in the browser are so restricted that they cannot easily
> be abstracted.

This library includes a `transport.MultipartFile` class as an option for a
platform-independent file abstraction, but it requires that you have access to
a byte stream to construct an instance.

The `files` map accepts the following types:

- `transport.MultipartFile` (any platform)
- `dart:html.File` (browser)
- `dart:html.Blob` (browser)

```dart
Stream<List<int>> byteStream = ...;
int length = ...;
var file = new transport.MultipartFile(byteStream, length);

var request = new transport.MultipartRequest()
  ..uri = Uri.parse('/notes/')
  ..fields['title'] = 'My Note'
  ..files['attachment'] = file;
```
