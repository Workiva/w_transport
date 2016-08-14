#### Content-Length, Content-Type and Encoding
All of the request classes set the `content-type` automatically based on the
type of data being sent in the request body, and the `charset` parameter is set
using the encoding's name.

> By default, UTF8 encoding is used for requests.

The content-type of a request is available as `.contentType` and is of type
`MediaType` from [the `http_parser` package](https://github.com/dart-lang/http_parser).

> This property is read-only and is updated based on the type of data in the
> request body and the encoding. The exception to this is a streamed request
> where the request body is asynchronous and thus not known ahead of time.

Additionally, the `content-length` is set automatically for all `Request`
classes since the length of the body in bytes is known before sending. The
content-length of a request is available as the read-only property
`.contentLength` and is the number of bytes of the request body when encoded.

> Again, the exception to this is `StreamedRequest` since the body is sent
> asynchronously.

Consider the following plain-text request:
```dart
Request request = new Request()
  ..body = 'Hello World ®';

print(request.contentType.toString());
// content-type: text/plain; charset=utf-8
print(request.contentLength);
// 14
```

As you can see, the content-type is `text/plain` because the request body is
plain-text and the charset is `utf-8` because UTF8 encoding is used by default.

Let's change the encoding:
```dart
Request request = new Request()
  ..body = 'Hello World ®'
  ..encoding = LATIN1;

print(request.contentType.toString());
// content-type: text/plain; charset=iso-8859-1
print(request.contentLength);
// 13
```

The content-type value will change based on the type of request being sent. For
plain `Request`s, it will always be `text/plain`. The other supported request
types will set the content-type as follows:

* `FormRequest`: `application/x-www-form-urlencoded`
* `JsonRequest`: `application/json`
* `MultipartRequest`: `multipart/form-data`
