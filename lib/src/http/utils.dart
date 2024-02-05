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
import 'package:meta/meta.dart';

import 'package:w_transport/src/http/auto_retry.dart';
import 'package:w_transport/src/http/request_progress.dart';

/// RegExp that only matches strings containing only ASCII-compatible chars.
final _asciiOnly = RegExp(r'^[\x00-\x7F]+$');

/// Base used when calculating the exponential backoff.
const _exponentialBase = 2;

/// Calculate the backoff duration based on [RequestAutoRetry] configuration.
/// Returns [null] if backoff is not applicable.
Duration? calculateBackOff(
  RequestAutoRetry autoRetry, {
  @visibleForTesting Random? random,
  AdvancedBackOffCalculator? calculator,
}) {
  Duration? backOff;
  switch (autoRetry.backOff.method) {
    case RetryBackOffMethod.exponential:
      backOff = _calculateExponentialBackOff(autoRetry,
          random: random, calculator: calculator);
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

Duration _calculateExponentialBackOff(RequestAutoRetry autoRetry,
    {@visibleForTesting Random? random,
    AdvancedBackOffCalculator? calculator}) {
  if (autoRetry.backOff.withJitter) {
    if (calculator == null) {
      throw StateError(
          'Cannot calculate advanced jitter without an instance of AdvancedBackOffCalculator');
    }
    final jitteredBackOff =
        calculator.calculateAdvancedExponentialJitteredBackOffInMs(
            autoRetry.numAttempts, autoRetry.backOff.interval!,
            random: random);
    // If we're over the maximum duration, fall back to a fixed maxInterval with full jitter
    if (jitteredBackOff > autoRetry.backOff.maxInterval!.inMilliseconds) {
      return Duration(
          milliseconds:
              (autoRetry.backOff.maxInterval!.inMilliseconds.toDouble() *
                      (random ?? Random()).nextDouble())
                  .toInt());
    }
    return Duration(milliseconds: jitteredBackOff);
  }

  return Duration(
      milliseconds: _calculateUnjitteredExponentialBackOffInMs(autoRetry));
}

/// Use this class to calculate exponential backoff with jitter.
///
/// This is wrapped in a class because the algorithm used uses values from
/// previous calculations in future calculations, and therefore must carry some
/// state.
class AdvancedBackOffCalculator {
  /// This number is used in the advanced jitter algorithm to carry some state
  /// between subsequent calls on the same request, and has no meaningful value
  /// outside of that context.
  double _previous = 0.0;

  /// Returns the jittered backoff delay in ms using an advanced jittering algorithm.
  ///
  /// Taken from https://github.com/Polly-Contrib/Polly.Contrib.WaitAndRetry/blob/master/src/Polly.Contrib.WaitAndRetry/Backoff.DecorrelatedJitterV2.cs#L35-L65
  /// See the details here: https://github.com/Polly-Contrib/Polly.Contrib.WaitAndRetry#wait-and-retry-with-jittered-back-off
  int calculateAdvancedExponentialJitteredBackOffInMs(
      int numTotalAttempts, Duration backOffInterval,
      {@visibleForTesting Random? random}) {
    // We subtract 1 from the numAttempts since the algorithm uses previous
    // _retry_ attempts, and `numTotalAttempts` is _total_ attempts, meaning
    // it will always be 1 greater than the number of _retry_ attempts.
    final t =
        numTotalAttempts.toDouble() - 1.0 + (random ?? Random()).nextDouble();
    final next = pow(2, t) * _tanh(sqrt(4.0 * t));
    final num unscaledBackOff = next - _previous;
    final backoffInMs =
        unscaledBackOff * 1 / 1.4 * (backOffInterval.inMilliseconds);
    _previous = next;
    return backoffInMs.toInt();
  }
}

int _calculateUnjitteredExponentialBackOffInMs(autoRetry) {
  int backOffInMs = autoRetry.backOff.interval.inMilliseconds *
      pow(_exponentialBase, autoRetry.numAttempts);
  return min(autoRetry.backOff.maxInterval.inMilliseconds, backOffInMs);
}

/// Calculate the hyperbolic tangent of [angle] in radians.
///
/// Taken from `dart_numerics` package, which is not used here because it is not
/// supported for web applications.
///
/// Original source: https://github.com/zlumyo/dart_numerics/blob/7d872186c800e92dbfeff408d109a9138f126f63/lib/src/trigonometry.dart#L119-L131
double _tanh(double angle) {
  if (angle > 19.1) {
    return 1.0;
  }

  if (angle < -19.1) {
    return -1.0;
  }

  final e1 = exp(angle);
  final e2 = exp(-angle);
  return (e1 - e2) / (e1 + e2);
}

Duration _calculateFixedBackOff(RequestAutoRetry autoRetry) {
  if (autoRetry.backOff.withJitter) {
    final random = Random();
    return Duration(
        milliseconds: autoRetry.backOff.interval!.inMilliseconds ~/ 2 +
            random.nextInt(autoRetry.backOff.interval!.inMilliseconds).toInt());
  } else {
    return autoRetry.backOff.interval!;
  }
}

/// Returns true if all characters in [value] are ASCII-compatible chars.
/// Returns false otherwise.
bool isAsciiOnly(String value) => _asciiOnly.hasMatch(value);

/// Converts a [Map] of field names to values to a query string. The resulting
/// query string can be used as a URI query string or the body of a
/// `application/x-www-form-urlencoded` request or response.
String mapToQuery(Map<String, dynamic> map, {Encoding? encoding}) {
  final params = <String>[];
  map.forEach((key, value) {
    // Support fields with multiple values.
    final valueList = value is List ? value : [value];
    for (final v in valueList) {
      final encoded = <String>[
        Uri.encodeQueryComponent(key, encoding: encoding ?? utf8),
        Uri.encodeQueryComponent(v, encoding: encoding ?? utf8),
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
  headers = CaseInsensitiveMap<String>.from(headers);
  var contentType = headers['content-type'];
  if (contentType != null && contentType.trim().isNotEmpty) {
    return MediaType.parse(contentType);
  }
  return MediaType('application', 'octet-stream');
}

/// Returns the [Encoding] specified by the `charset` parameter of
/// [contentType].
///
/// If no `charset` parameter is specified or if a corresponding [Encoding]
/// cannot be found for the given `charset`, the [fallback] encoding will be
/// returned.
Encoding? parseEncodingFromContentType(MediaType? contentType,
    {Encoding? fallback}) {
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
Encoding parseEncodingFromContentTypeOrFail(MediaType? contentType,
    {Encoding? fallback}) {
  final encoding =
      parseEncodingFromContentType(contentType, fallback: fallback);
  if (encoding != null) return encoding;
  final charset =
      contentType != null ? contentType.parameters['charset'] : null;
  throw FormatException('Unsupported charset: $charset');
}

/// Parses the content-type from [headers] and uses its `charset` parameter to
/// find and return the corresponding [Encoding].
///
/// If a content-type header is not specified in [headers] or cannot be parsed,
/// or if the `charset` parameter is not specified, or if a corresponding
/// [Encoding] cannot be found for the parsed `charset`, the [fallback] encoding
/// will be returned.
Encoding? parseEncodingFromHeaders(Map<String, String> headers,
    {Encoding? fallback}) {
  final contentType = parseContentTypeFromHeaders(headers);
  return parseEncodingFromContentType(contentType, fallback: fallback);
}

/// Converts a query string to a [Map] of parameter names to values. Works for
/// URI query string or an `application/x-www-form-urlencoded` body.
Map<String, Object> queryToMap(String query, {Encoding? encoding}) {
  final fields = <String, Object>{};
  for (final pair in query.split('&')) {
    final pieces = pair.split('=');
    if (pieces.isEmpty) continue;

    String key = pieces.first;
    String value = pieces.length > 1 ? pieces.sublist(1).join('') : '';

    key = Uri.decodeQueryComponent(key, encoding: encoding ?? utf8);
    value = Uri.decodeQueryComponent(value, encoding: encoding ?? utf8);

    if (fields.containsKey(key)) {
      if (fields[key] is! List) {
        fields[key] = [fields[key]];
      }
      final currentFields = fields[key]! as List<dynamic>;
      currentFields.add(value);
    } else {
      fields[key] = value;
    }
  }
  return fields;
}

/// Reduces a byte stream to a single list of bytes.
Future<Uint8List> reduceByteStream(Stream<List<int>?> byteStream) async {
  try {
    final bytes = await (byteStream.reduce((prev, next) {
      return List<int>.from(prev!)..addAll(next!);
    }));
    return Uint8List.fromList(bytes!);
  } on StateError {
    // StateError is thrown if stream was empty.
    return Uint8List.fromList([]);
  }
}

class ByteStreamProgressListener {
  StreamController<RequestProgress> _progressController =
      StreamController<RequestProgress>();

  late Stream<List<int>> _transformed;

  ByteStreamProgressListener(Stream<List<int>> byteStream, {int? total}) {
    _transformed = _listenTo(byteStream, total: total);
  }

  Stream<List<int>> get byteStream => _transformed;

  Stream<RequestProgress> get progressStream => _progressController.stream;

  Stream<List<int>> _listenTo(Stream<List<int>> byteStream, {int? total}) {
    int loaded = 0;
    final progressListener = StreamTransformer<List<int>, List<int>>(
        (Stream<List<int>> input, bool cancelOnError) {
      late StreamController<List<int>> controller;
      late StreamSubscription<List<int>> subscription;

      controller = StreamController<List<int>>(onListen: () {
        subscription = input.listen(
            (bytes) {
              controller.add(bytes);
              try {
                loaded += bytes.length;
                _progressController.add(RequestProgress(loaded, total ?? -1));
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
