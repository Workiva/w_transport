library w_transport.src.http.requests;

import 'dart:async';
import 'dart:typed_data';

import 'package:w_transport/src/http/base_request.dart';
import 'package:w_transport/src/http/multipart_file.dart';
import 'package:w_transport/src/platform_adapter.dart';

abstract class FormRequest extends BaseRequest {
  /// Gets this request's body as a `Map` where each key-value pair is a form
  /// field's name and value.
  ///
  /// By default, the body of this [FormRequest] will is an empty `Map`.
  ///
  /// The returned `Map` is modifiable, allowing incremental field assignment
  /// like so:
  ///
  ///     FormRequest request = new FormRequest()
  ///       ..body['foo'] = 'bar'
  ///       ..body['bar'] = 'baz';
  ///
  /// Prior to sending, this request body will be translated to the equivalent
  /// query string. Depending on the platform, this may then be encoded to
  /// bytes. Be sure to set [encoding] if this request body should be encoded
  /// with something other than the default UTF8.
  Map<String, String> get fields;

  /// Sets this request's form fields. The given `Map` should represent the form
  /// fields where each key-value pair is a field's name and value.
  ///
  /// Prior to sending, this request body will be translated to the equivalent
  /// query string. Depending on the platform, this may then be encoded to
  /// bytes. Be sure to set [encoding] if this request body should be encoded
  /// with something other than the default UTF8.
  set fields(Map<String, String> fields);

  factory FormRequest() => PlatformAdapter.retrieve().newFormRequest();
}

abstract class JsonRequest extends BaseRequest {
  /// Gets this request's body as a JSON `Map` or `List`.
  ///
  /// By default, the body of this [FormRequest] will is an empty `Map`.
  ///
  /// The returned `Map` is modifiable, allowing incremental field assignment
  /// like so:
  ///
  ///     FormRequest request = new FormRequest()
  ///       ..body['foo'] = 'bar'
  ///       ..body['bar'] = 'baz';
  ///
  /// Prior to sending, this request body will be translated to the equivalent
  /// query string. Depending on the platform, this may then be encoded to
  /// bytes. Be sure to set [encoding] if this request body should be encoded
  /// with something other than the default UTF8.
  Map<String, String> get body;

  /// Sets this request's form body. The given `Map` should represent the form
  /// fields where each key-value pair is a field's name and value.
  ///
  /// Prior to sending, this request body will be translated to the equivalent
  /// query string. Depending on the platform, this may then be encoded to
  /// bytes. Be sure to set [encoding] if this request body should be encoded
  /// with something other than the default UTF8.
  set body(Map<String, String> body);

  factory JsonRequest() => PlatformAdapter.retrieve().newJsonRequest();
}

/// TODO
abstract class MultipartRequest extends BaseRequest {
  /// TODO
  Map<String, String> get fields;

  /// TODO
  Map<String, dynamic> get files;

  factory MultipartRequest() => PlatformAdapter.retrieve().newMultipartRequest();
}

abstract class Request extends BaseRequest {
  /// Gets this request's body.
  String get body;

  /// Sets this request's plain-text body.
  ///
  /// Depending on the platform, this may be encoded to bytes prior to sending.
  /// Be sure to set [encoding] if this request body should be encoded with
  /// something other than the default UTF8.
  set body(String body);

  /// Gets this request's body as bytes (encoded version of [body]).
  Uint8List get bodyBytes;

  /// Sets this request's body from bytes (encoded version of [body]).
  ///
  /// Depending on the platform, this may be decoded to text prior to sending.
  /// Be sure to set [encoding] if this request body should be decoded with
  /// something other than the default UTF8.
  set bodyBytes(List<int> bytes);

  factory Request() => PlatformAdapter.retrieve().newRequest();
}

abstract class StreamedRequest extends BaseRequest {
  /// Get the byte stream that will be sent as this request's body.
  Stream<List<int>> get body;

  /// Set this request's body to be a byte stream. The given stream should be a
  /// single subscription string to avoid losing data. This request's body will
  /// be sent asynchronously by listening to this stream.
  ///
  /// Be sure to set [encoding] if the byte stream should be decoded with
  /// something other than the default UTF8.
  set body(Stream<List<int>> byteStream);

  factory StreamedRequest() => PlatformAdapter.retrieve().newStreamedRequest();
}