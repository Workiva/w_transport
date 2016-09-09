// Copyright 2015 Workiva Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:typed_data';

import 'package:w_transport/src/http/base_request.dart';
import 'package:w_transport/src/http/multipart_file.dart';
import 'package:w_transport/src/platform_adapter.dart';

/// Representation of an HTTP request where the request body is a form that will
/// be encoded as a url query string.
///
/// This request will be sent with content-type:
/// application/x-www-form-urlencoded
abstract class FormRequest extends BaseRequest {
  factory FormRequest() => PlatformAdapter.retrieve().newFormRequest();

  /// Gets this request's body as a `Map` where each key-value pair is a form
  /// field's name and value.
  ///
  /// By default, the body of this [FormRequest] is an empty `Map`.
  ///
  /// The returned `Map` is modifiable, allowing incremental field assignment
  /// like so:
  ///
  ///     FormRequest request = new FormRequest()
  ///       ..fields['foo'] = 'bar'
  ///       ..fields['bar'] = 'baz';
  ///
  /// To set multiple values for a single key, use a `Iterable<String>`:
  ///
  ///     FormRequest request = new FormRequest()
  ///       ..fields['names'] = ['foo', 'bar'];
  ///
  /// Prior to sending, this request body will be translated to the equivalent
  /// query string. Depending on the platform, this may then be encoded to
  /// bytes. Be sure to set [encoding] if this request body should be encoded
  /// with something other than the default UTF8.
  Map<String, dynamic> get fields;

  /// Sets this request's form fields. The given `Map` should represent the form
  /// fields where each key-value pair is a field's name and value.
  ///
  /// Prior to sending, this request body will be translated to the equivalent
  /// query string. Depending on the platform, this may then be encoded to
  /// bytes. Be sure to set [encoding] if this request body should be encoded
  /// with something other than the default UTF8.
  set fields(Map<String, dynamic> fields);

  /// Returns an clone of this request.
  @override
  FormRequest clone();
}

/// Representation of an HTTP request where the request body is a json-encodable
/// Map or List.
///
/// This request will be sent with content-type: application/json
abstract class JsonRequest extends BaseRequest {
  factory JsonRequest() => PlatformAdapter.retrieve().newJsonRequest();

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
  dynamic get body;

  /// Sets this request's form body. The given `Map` should represent the form
  /// fields where each key-value pair is a field's name and value.
  ///
  /// Prior to sending, this request body will be translated to the equivalent
  /// query string. Depending on the platform, this may then be encoded to
  /// bytes. Be sure to set [encoding] if this request body should be encoded
  /// with something other than the default UTF8.
  set body(dynamic body);

  /// Returns an clone of this request.
  @override
  JsonRequest clone();
}

/// Representation of an HTTP request where the request body is comprised of
/// one or more parts. Each part can be either a field name and value or a file.
///
/// This request will be sent with content-type: multipart/form-data
abstract class MultipartRequest extends BaseRequest {
  /// Get and set this request's text fields as a Map of field names to their
  /// values.
  ///
  /// The returned `Map` is modifiable. Fields can be set like so:
  ///
  ///     MultipartRequest request = new MultipartRequest()
  ///       ..fields['key1'] = 'value1'
  ///       ..fields['key2'] = 'value2';
  Map<String, String> fields;

  /// Get and set this request's file fields as a Map of field names to files.
  /// The value can be a [MultipartFile] or, if in the browser, a [Blob].
  ///
  /// The returned `Map` is modifiable. Files can be set like so:
  ///
  ///     MultipartFile file = new MultipartFile(...);
  ///     MultipartRequest request = new MultipartRequest()
  ///       ..files['file1'] = file;
  Map<String, dynamic> files;

  factory MultipartRequest() =>
      PlatformAdapter.retrieve().newMultipartRequest();

  /// Returns an clone of this request.
  @override
  MultipartRequest clone();
}

/// Representation of an HTTP request where the request body is plain-text.
///
/// This request will be sent with content-type: text/plain
abstract class Request extends BaseRequest {
  factory Request() => PlatformAdapter.retrieve().newRequest();

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

  /// Returns an clone of this request.
  @override
  Request clone();
}

/// Representation of an HTTP request where the request body is sent
/// asynchronously as a stream. The [content-type] should be set manually.
abstract class StreamedRequest extends BaseRequest {
  factory StreamedRequest() => PlatformAdapter.retrieve().newStreamedRequest();

  /// Get the byte stream that will be sent as this request's body.
  Stream<List<int>> get body;

  /// Set this request's body to be a byte stream. The given stream should be a
  /// single subscription string to avoid losing data. This request's body will
  /// be sent asynchronously by listening to this stream.
  ///
  /// Be sure to set [encoding] if the byte stream should be decoded with
  /// something other than the default UTF8.
  set body(Stream<List<int>> byteStream);

  /// Cloning a StreamedRequest is not supported. This will throw an
  /// [UnsupportedError].
  @override
  StreamedRequest clone();
}
