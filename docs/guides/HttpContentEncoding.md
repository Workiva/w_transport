## HTTP: Encoding, Content-Type, and Content-Length

### Encoding

Every request instance has an `Encoding encoding` property that defaults to
UTF8. The encoding can be set to something else (e.g. ASCII or LATIN1), but for
most cases the default UTF8 should be sufficient.

The selected encoding is significant for three reasons:

- The HTTP logic in this library may use the selected encoded to encode or
  decode the request body prior to sending. For example, if you set the request
  body as a `String`, it may be encoded to a `Uint8List` byte list or a
  `ByteBuffer` and then sent in that form.

- The `content-length` will be calculated from the encoded request body. This is
  necessary because the number of bytes once encoded can vary based on the
  encoding used. (See the ["Content-Length" section](#content-length) below.)

- The `content-type` request header will include the `charset` parameter and it
  will be set to the string representation of the encoding. This tells the
  server how the request body will be encoded so that it can successfully decode
  the body.
  
  ```dart
  import 'dart:convert';
  
  ...
  
  var request = new transport.Request();
  
  // For a plain-text request, the default encoding is "UTF8" and the default
  // mime-type is "text/plain".
  print(request.contentType); // plain/text; charset=utf-8

  // If we update the encoding, the charset parameter will reflect this change.
  request.encoding = LATIN1;
  print(request.contentType); // plain/text; charset=iso-8859-1
  ```
  
  > **Exception:** if the `contentType` property is ever set manually, the
  > charset parameter will no longer be updated when the `encoding` changes.
  > This is explained below in the ["Content-Type" section](#content-type).


### Content-Type

All of the request classes have a default value for the `content-type` based on
the type of data being sent in the request body:

- `transport.Request`: `text/plain`
- `transport.FormRequest`: `application/x-www-form-urlencoded`
- `transport.JsonRequest`: `application/json`
- `transport.MultipartRequest`: `multipart/form-data`
- `transport.StreamedRequest`: `text/plain`

> The default content-type for `transport.StreamedRequest` is `text/plain`
> because it is unknown at the time of dispatch what data will be sent in the
> request body.

The content-type of a request is available via a `MediaType contentType`
property (`MediaType` is from
[the `http_parser` package](https://github.com/dart-lang/http_parser)).

As mentioned above in the ["Encoding" section](#encoding), the `charset`
parameter in the content-type is updated automatically whenever the `encoding`
property changes. **However, once you manually set `contentType`, this behavior will stop.** In
other words, we are assuming that if you set `contentType` manually, you are
intentionally overriding the defaults and are taking responsibility for setting
the charset parameter appropriately.


### Content-Length

The `content-length` is set automatically for all `Request` classes since the
length of the body in bytes is known before sending. The content-length of a
request is available as a read-only `int contentLength` property and is the
number of bytes of the request body when encoded.

> The exception to this is `transport.StreamedRequest` since the body is sent
> asynchronously. When using `transport.StreamedRequest`, **you must set the
> `contentLength` value manually.**

Consider the following plain-text request:
```dart
var request = new transport.Request()
  ..body = 'Hello World ®';

print(request.contentType.toString());
// content-type: text/plain; charset=utf-8
print(request.contentLength);
// 14
```

As you can see, the content-type is `text/plain` because the request body is
plain-text and the charset is `utf-8` because UTF8 encoding is used by default.

If we change the encoding, the content-type and content-length will be updated
accordingly:
```dart
var request = new transport.Request()
  ..body = 'Hello World ®'
  ..encoding = LATIN1;

print(request.contentType.toString());
// content-type: text/plain; charset=iso-8859-1
print(request.contentLength);
// 13
```
