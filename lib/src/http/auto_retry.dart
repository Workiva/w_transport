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

import 'package:w_transport/src/constants.dart' show v3Deprecation;

import 'package:w_transport/src/http/base_request.dart';
import 'package:w_transport/src/http/finalized_request.dart';
import 'package:w_transport/src/http/request_exception.dart';
import 'package:w_transport/src/http/requests.dart';
import 'package:w_transport/src/http/response.dart';

typedef Future<bool> RetryTest(
    FinalizedRequest request, BaseResponse response, bool willRetry);

/// The valid retry back-off methods.
enum RetryBackOffMethod { exponential, fixed, none }

/// Deciding whether or not to retry a failed request is determined by the
/// settings defined in fields in this class.
///
/// To turn automatic retrying on, set [enabled] to `true`.
///
/// The decision to retry a request or not can usually be made based solely on
/// the request method and the response status code. For this reason, the
/// [forHttpMethods] and [forStatusCodes] fields define a list of methods and
/// status codes, respectively, for which retrying is acceptable.
///
/// There is also a [test] field for a custom test function that can make the
/// decision based on more information.
///
/// If [test] is defined (not null), then it is called with:
///
/// 1. A [FinalizedRequest] instance,
/// 2. A [BaseResponse] instance, and
/// 3. A `willRetry` boolean representing whether or not the HTTP method and
///    status code checks passed.
///
/// The [test] then makes the final decision (retry or no retry) by
/// asynchronously returning a boolean.
///
/// If, however, [test] is null, then the decision is made based solely on
/// whether or not the HTTP method and status code checks passed.
class AutoRetryConfig {
  /// Back-off method to use between retries. By default, there is no back-off.
  RetryBackOff backOff = const RetryBackOff.none();

  /// Whether or not automatic retrying is enabled.
  bool enabled = false;

  /// The set of HTTP methods that are considered eligible for retrying.
  ///
  /// By default, non-mutable HTTP methods included here (GET, HEAD, OPTIONS).
  /// This is to avoid issues with requests that may not be idempotent.
  List<String> forHttpMethods = ['GET', 'HEAD', 'OPTIONS'];

  /// The set of status codes that are considered eligible for retrying.
  ///
  /// By default, 500, 502, 503, and 504 are included here because they
  /// represent server errors that may be transient.
  List<int> forStatusCodes = [500, 502, 503, 504];

  /// When [enabled] is true, this determines whether or not to retry requests
  /// that fail due to exceeding the timeout threshold.
  bool forTimeouts = true;

  /// Maximum number of retries to attempt. This excludes the original request.
  /// For example, a request with `maxRetries = 2` will produce up to 3 requests
  /// total - the first request and 2 retries.
  int maxRetries = 2;

  /// A custom [test] function that decides whether or not a request should be
  /// retried. It will be called with:
  ///
  /// 1. A [FinalizedRequest] instance,
  /// 2. A [BaseResponse] instance, and
  /// 3. A `willRetry` boolean representing whether or not the HTTP method and
  ///    status code checks passed.
  ///
  /// The [test] then makes the final decision (retry or no retry) by
  /// asynchronously returning a boolean.
  ///
  ///     // Example of auto retry with a custom check for a CSRF failure that
  ///     // can only be identified by a message in the response body.
  ///
  ///     var request = new Request();
  ///     request.autoRetry
  ///       ..enabled = true
  ///       ..test = (FinalizedRequest request, BaseResponse response,
  ///           bool willRetry) async {
  ///         // Check for a special case (CSRF failure) by reading the body.
  ///         // If it's determined that it is a CSRF failure, return `true`
  ///         // to indicate the request should be retried.
  ///         if (response is Response &&
  ///             response.status == 403 &&
  ///             response.body.asString().contains('CSRF failure')) return true;
  ///
  ///         // Otherwise, return whatever the value of `willRetry` is.
  ///         // In other words, we defer to the HTTP method & status code checks.
  ///         return willRetry;
  ///       };
  RetryTest test;
}

/// Representation of a single request's auto-retry configuration along with
/// contextual information about the retries. This extends [AutoRetryConfig] and
/// thus inherits the same configuration fields.
///
/// The additional fields include information like the number of attempts made,
/// previous failures, and whether or not request retrying is supported for the
/// associated [BaseRequest] instance.
class RequestAutoRetry extends AutoRetryConfig {
  /// Get a list of the [RequestException] instances for each failed attempt.
  List<RequestException> failures = [];

  /// The number of attempts for this request, including the original request.
  /// This will be incremented each time an attempt is sent.
  int numAttempts = 0;

  /// The _original_ request instance with which this information is associated.
  BaseRequest _request;

  /// Construct an [RequestAutoRetry] instance to be associated with [request].
  RequestAutoRetry(BaseRequest request) : _request = request;

  /// Whether or not the number of attempts has exceeded the maximum.
  bool get didExceedMaxNumberOfAttempts => numAttempts > maxRetries;

  /// Whether or not retrying is supported for this request instance. This
  /// depends on the type of request (Form, Multipart, Streamed, etc) and the
  /// type of data in the request body.
  ///
  /// [StreamedRequest]s cannot be retried because the streamed request body can
  /// only be read once.
  ///
  /// [MultipartRequest]s can be retried only if all of the parts are `String`
  /// field/value pairs. If the request contains files (byte streams or blobs),
  /// it cannot be retried because they cannot be read more than once.
  bool get supported {
    final request = _request;
    if (request is StreamedRequest) return false;
    if (request is MultipartRequest && request.files.isNotEmpty) return false;
    return true;
  }
}

/// Representation of the back-off method to use when retrying requests. A fixed
/// back-off will space retries out by [interval]. An exponential back-off will
/// delay retries by `d*2^n` where `d` is [interval] and `n` is the number of
/// attempts so far.
class RetryBackOff {
  /// The default maximum duration between retries. (5 minutes)
  static const Duration defaultMaxInterval = const Duration(minutes: 5);

  /// The base duration from which the delay between retries will be calculated.
  /// For fixed back-off, the delay will always be this value. For exponential
  /// back-off, the delay will be this value multiplied by 2^n where `n` is the
  /// number of attempts so far.
  final Duration interval;

  /// The maximum duration between retries.
  final Duration maxInterval;

  /// The back-off method to use. One of none, fixed, or exponential.
  final RetryBackOffMethod method;

  /// Whether to enable jitter or not.
  final bool withJitter;

  /// Construct a new exponential back-off representation where [interval] is
  /// the base duration from which each delay will be calculated.
  const RetryBackOff.exponential(this.interval,
      {bool withJitter: true, Duration maxInterval})
      : method = RetryBackOffMethod.exponential,
        withJitter = withJitter,
        maxInterval = maxInterval ?? defaultMaxInterval;

  /// Construct a new fixed back-off representation where [interval] is the
  /// delay between each retry.
  const RetryBackOff.fixed(this.interval, {bool withJitter: true})
      : method = RetryBackOffMethod.fixed,
        withJitter = withJitter,
        maxInterval = null;

  /// Construct a null back-off representation, meaning no delay between retry
  /// attempts.
  const RetryBackOff.none()
      : interval = null,
        method = RetryBackOffMethod.none,
        withJitter = false,
        maxInterval = null;

  /// Use [interval] instead.
  @Deprecated(v3Deprecation)
  Duration get duration => interval;
}
