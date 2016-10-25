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
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:http_parser/http_parser.dart';

import 'package:w_transport/src/http/auto_retry.dart';
import 'package:w_transport/src/http/request_progress.dart';

/// RegExp that only matches strings containing only ASCII-compatible chars.
final _asciiOnly = new RegExp(r'^[\x00-\x7F]+$');

/// Base used when calculating the exponential backoff.
const _exponentialBase = 2;

/// Calculate the backoff duration based on [RequestAutoRetry] configuration.
/// Returns [null] if backoff is not applicable.
Duration calculateBackOff(RequestAutoRetry autoRetry) {
  Duration backOff;
  switch (autoRetry.backOff.method) {
    case RetryBackOffMethod.exponential:
      backOff = _calculateExponentialBackOff(autoRetry);
      break;
    case RetryBackOffMethod.fixed:
      backOff = _calculateFixedBackOff(autoRetry);
      break;
    case RetryBackOffMethod.none:
    default:
      break;
  }
  return backOff;
}

Duration _calculateExponentialBackOff(RequestAutoRetry autoRetry) {
  int backOffInMs = autoRetry.backOff.interval.inMilliseconds *
      pow(_exponentialBase, autoRetry.numAttempts);
  backOffInMs = min(autoRetry.backOff.maxInterval.inMilliseconds, backOffInMs);

  if (autoRetry.backOff.withJitter == true) {
    final random = new Random();
    backOffInMs = random.nextInt(backOffInMs);
  }
  return new Duration(milliseconds: backOffInMs);
}

Duration _calculateFixedBackOff(RequestAutoRetry autoRetry) {
  Duration backOff;

  if (autoRetry.backOff.withJitter == true) {
    final random = new Random();
    backOff = new Duration(
        milliseconds: autoRetry.backOff.interval.inMilliseconds ~/ 2 +
            random.nextInt(autoRetry.backOff.interval.inMilliseconds).toInt());
  } else {
    backOff = autoRetry.backOff.interval;
  }

  return backOff;
}

/// Returns true if all characters in [value] are ASCII-compatible chars.
/// Returns false otherwise.
bool isAsciiOnly(String value) => _asciiOnly.hasMatch(value);

/// Converts a [Map] of field names to values to a query string. The resulting
/// query string can be used as a URI query string or the body of a
/// `application/x-www-form-urlencoded` request or response.
String mapToQuery(Map<String, Object> map, {Encoding encoding}) {
  final params = <String>[];
  map.forEach((key, value) {
    // Support fields with multiple values.
    final valueList = value is List ? value : [value];
    for (final v in valueList) {
      final encoded = <String>[
        Uri.encodeQueryComponent(key, encoding: encoding ?? UTF8),
        Uri.encodeQueryComponent(v, encoding: encoding ?? UTF8),
      ];
      params.add(encoded.join('='));
    }
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
  headers = new CaseInsensitiveMap<String>.from(headers);
  if (headers['content-type'] != null) {
    return new MediaType.parse(headers['content-type']);
  }
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
  final encoding = Encoding.getByName(contentType.parameters['charset']);
  return encoding ?? fallback;
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
  final encoding =
      parseEncodingFromContentType(contentType, fallback: fallback);
  if (encoding != null) return encoding;
  final charset =
      contentType != null ? contentType.parameters['charset'] : null;
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
  final contentType = parseContentTypeFromHeaders(headers);
  return parseEncodingFromContentType(contentType, fallback: fallback);
}

/// Converts a query string to a [Map] of parameter names to values. Works for
/// URI query string or an `application/x-www-form-urlencoded` body.
Map<String, Object> queryToMap(String query, {Encoding encoding}) {
  final fields = <String, Object>{};
  for (final pair in query.split('&')) {
    final pieces = pair.split('=');
    if (pieces.isEmpty) continue;

    String key = pieces.first;
    String value = pieces.length > 1 ? pieces.sublist(1).join('') : '';

    key = Uri.decodeQueryComponent(key, encoding: encoding ?? UTF8);
    value = Uri.decodeQueryComponent(value, encoding: encoding ?? UTF8);

    if (fields.containsKey(key)) {
      if (fields[key] is! List) {
        fields[key] = [fields[key]];
      }
      final List currentFields = fields[key];
      currentFields.add(value);
    } else {
      fields[key] = value;
    }
  }
  return fields;
}

/// Reduces a byte stream to a single list of bytes.
Future<Uint8List> reduceByteStream(Stream<List<int>> byteStream) async {
  try {
    final bytes = await byteStream.reduce((prev, next) {
      return new List<int>.from(prev)..addAll(next);
    });
    return new Uint8List.fromList(bytes);
  } on StateError {
    // StateError is thrown if stream was empty.
    return new Uint8List.fromList([]);
  }
}

class ByteStreamProgressListener {
  StreamController<RequestProgress> _progressController =
      new StreamController<RequestProgress>();

  Stream<List<int>> _transformed;

  ByteStreamProgressListener(Stream<List<int>> byteStream, {int total}) {
    _transformed = _listenTo(byteStream, total: total);
  }

  Stream<List<int>> get byteStream => _transformed;

  Stream<RequestProgress> get progressStream => _progressController.stream;

  Stream<List<int>> _listenTo(Stream<List<int>> byteStream, {int total}) {
    int loaded = 0;

    final progressListener = new StreamTransformer<List<int>, List<int>>(
        (Stream<List<int>> input, bool cancelOnError) {
      StreamController<List<int>> controller;
      StreamSubscription<List<int>> subscription;

      controller = new StreamController<List<int>>(onListen: () {
        subscription = input.listen(
            (bytes) {
              controller.add(bytes);
              try {
                loaded += bytes.length;
                _progressController.add(new RequestProgress(loaded, total));
              } catch (e) {
                // If one item from the stream is not of type List<int>,
                // attempting to add the length to the `loaded` counter would
                // throw. Fail quietly if that happens.
              }
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
