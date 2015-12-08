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

library w_transport.src.http.utils;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http_parser/http_parser.dart';

import 'package:w_transport/src/http/request_progress.dart';

/// RegExp that only matches strings containing only ASCII-compatible chars.
final RegExp _asciiOnly = new RegExp(r"^[\x00-\x7F]+$");

/// Returns true if all characters in [value] are ASCII-compatible chars.
/// Returns false otherwise.
bool isAsciiOnly(String value) => _asciiOnly.hasMatch(value);

/// Converts a [Map] of field names to values to a query string. The resulting
/// query string can be used as a URI query string or the body of a
/// `application/x-www-form-urlencoded` request or response.
String mapToQuery(Map<String, String> map, {Encoding encoding}) {
  List<String> params = [];
  map.forEach((key, value) {
    var encoded;
    if (encoding != null) {
      encoded = [
        Uri.encodeQueryComponent(key, encoding: encoding),
        Uri.encodeQueryComponent(value, encoding: encoding)
      ];
    } else {
      encoded = [
        Uri.encodeQueryComponent(key),
        Uri.encodeQueryComponent(value)
      ];
    }
    params.add(encoded.join('='));
  });
  return params.join('&');
}

/// Parses the content-type from a set of HTTP [headers].
///
/// If a content-type header is not specified in [headers], a default content-
/// type of "application/octet-stream" will be returned (as per RFC 2616
/// http://www.w3.org/Protocols/rfc2616/rfc2616-sec7.html#sec7.2.1).
MediaType parseContentTypeFromHeaders(Map<String, String> headers) {
  // Ensure the headers are case-insensitive.
  headers = new CaseInsensitiveMap.from(headers);
  if (headers['content-type'] != null)
    return new MediaType.parse(headers['content-type']);
  return new MediaType('application', 'octet-stream');
}

/// Returns the [Encoding] specified by the `charset` parameter of
/// [contentType].
///
/// If no `charset` parameter is specified or if a corresponding [Encoding]
/// cannot be found for the given `charset`, the [fallback] encoding will be
/// returned.
Encoding parseEncodingFromContentType(MediaType contentType,
    {Encoding fallback}) {
  if (contentType == null) return fallback;
  if (contentType.parameters['charset'] == null) return fallback;
  var encoding = Encoding.getByName(contentType.parameters['charset']);
  return encoding != null ? encoding : fallback;
}

/// Returns the [Encoding] specified by the `charset` parameter of
/// [contentType].
///
/// If no `charset` parameter is specified or if a corresponding [Encoding]
/// cannot be found for the given `charset`, the [fallback] encoding will be
/// returned as long as it is not null. If [fallback] is null, then a
/// [FormatException] will be thrown.
Encoding parseEncodingFromContentTypeOrFail(MediaType contentType,
    {Encoding fallback}) {
  var encoding = parseEncodingFromContentType(contentType, fallback: fallback);
  if (encoding != null) return encoding;
  var charset = contentType != null ? contentType.parameters['charset'] : null;
  throw new FormatException('Unsupported charset: $charset');
}

/// Parses the content-type from [headers] and uses its `charset` parameter to
/// find and return the corresponding [Encoding].
///
/// If a content-type header is not specified in [headers] or cannot be parsed,
/// or if the `charset` parameter is not specified, or if a corresponding
/// [Encoding] cannot be found for the parsed `charset`, the [fallback] encoding
/// will be returned.
Encoding parseEncodingFromHeaders(Map<String, String> headers,
    {Encoding fallback}) {
  MediaType contentType = parseContentTypeFromHeaders(headers);
  return parseEncodingFromContentType(contentType, fallback: fallback);
}

/// Converts a query string to a [Map] of parameter names to values. Works for
/// URI query string or an `application/x-www-form-urlencoded` body.
Map<String, String> queryToMap(String query, {Encoding encoding}) {
  var fields = {};
  for (var pair in query.split('&')) {
    var pieces = pair.split('=');
    if (pieces.isEmpty) continue;
    var key = pieces.first;
    var value = pieces.length > 1 ? pieces.sublist(1).join('') : '';
    if (encoding != null) {
      key = Uri.decodeQueryComponent(key, encoding: encoding);
      value = Uri.decodeQueryComponent(value, encoding: encoding);
    } else {
      key = Uri.decodeQueryComponent(key);
      value = Uri.decodeQueryComponent(value);
    }
    fields[key] = value;
  }
  return fields;
}

/// Reduces a byte stream to a single list of bytes.
Future<Uint8List> reduceByteStream(Stream<List<int>> byteStream) async {
  try {
    List<int> bytes = await byteStream.reduce((prev, next) {
      var combined = new List.from(prev)..addAll(next);
      return combined;
    });
    return new Uint8List.fromList(bytes);
  } on StateError {
    // StateError is thrown if stream was empty.
    return new Uint8List.fromList([]);
  }
}

class ByteStreamProgressListener {
  StreamController<RequestProgress> _progressController =
      new StreamController();

  Stream<List<int>> _transformed;

  ByteStreamProgressListener(Stream<List<int>> byteStream, {int total}) {
    _transformed = _listenTo(byteStream, total: total);
  }

  Stream<List<int>> get byteStream => _transformed;

  Stream<RequestProgress> get progressStream => _progressController.stream;

  Stream<List<int>> _listenTo(Stream<List<int>> byteStream, {int total}) {
    int loaded = 0;

    var progressListener =
        new StreamTransformer((Stream<List<int>> input, bool cancelOnError) {
      StreamController controller;
      StreamSubscription subscription;

      controller = new StreamController(onListen: () {
        subscription = input.listen(
            (bytes) {
              controller.add(bytes);
              try {
                loaded += (bytes as List<int>).length;
                _progressController.add(new RequestProgress(loaded, total));
              } catch (e) {}
            },
            onError: controller.addError,
            onDone: () {
              controller.close();
              _progressController.close();
            },
            cancelOnError: cancelOnError);
      }, onPause: () {
        subscription.pause();
      }, onResume: () {
        subscription.resume();
      }, onCancel: () {
        subscription.cancel();
      });

      return controller.stream.listen(null);
    });

    return byteStream.transform(progressListener);
  }
}
