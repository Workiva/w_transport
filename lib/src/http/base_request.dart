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

import 'package:fluri/fluri.dart';
import 'package:http_parser/http_parser.dart';

import 'package:w_transport/src/http/auto_retry.dart';
import 'package:w_transport/src/http/finalized_request.dart';
import 'package:w_transport/src/http/request_dispatchers.dart';
import 'package:w_transport/src/http/request_exception.dart';
import 'package:w_transport/src/http/request_progress.dart';
import 'package:w_transport/src/http/response.dart';

typedef Future<Null> RequestInterceptor(BaseRequest request);
typedef Future<BaseResponse> ResponseInterceptor(
    FinalizedRequest request, BaseResponse response,
    [RequestException error]);

/// A common API that applies to all request types. The piece that is missing is
/// that which is specific to the request body. Setting the request body differs
/// based on the type of request being sent (plain-text, JSON, form, multipart,
/// or streamed). As such, that piece of the API is delegated to the specific
/// request classes.
abstract class BaseRequest implements FluriMixin, RequestDispatchers {
  /// Configuration of automatic request retrying for failed requests. Use this
  /// object to enable or disable automatic retrying, configure the criteria
  /// that determines whether or not a request should be retried, as well as the
  /// number of retries to attempt.
  ///
  /// Information about this request related to retries is also available here.
  /// This includes the current number of attempts and the current list of
  /// failures.
  RequestAutoRetry autoRetry;

  /// Gets and sets the content-length of the request, in bytes. If the size of
  /// the request is not known in advance, set this to null.
  int contentLength;

  /// Content-type of this request.
  ///
  /// By default, the mime-type is "text/plain" and the charset is "UTF8".
  /// When the request body or the encoding is set or updated, the content-type
  /// will be updated accordingly.
  MediaType contentType;

  /// Future that resolves when the request has completed (successful or
  /// otherwise).
  Future<Null> get done;

  /// [RequestProgress] stream for this HTTP request's download.
  Stream<RequestProgress> get downloadProgress;

  /// Encoding to use when encoding or decoding the request body. Setting this
  /// will also update the [contentType]'s charset.
  ///
  /// Defaults to UTF8.
  Encoding encoding = UTF8;

  /// Headers to send with the HTTP request. Headers are case-insensitive.
  ///
  /// Note that the "content-type" header will be set automatically based on the
  /// type of data in this request's body and the [encoding].
  Map<String, String> headers = {};

  /// Returns `true` if this request is complete (successful or failed), `false`
  /// otherwise.
  bool get isDone;

  /// Hook into the request lifecycle right before the request is sent.
  ///
  /// If not null, this function will be called with the [BaseRequest] instance
  /// as the first argument. This function should return a `Future`, and the
  /// request will not be sent until the returned `Future` completes.
  ///
  /// _The request instance cannot be replaced, it must be modified in place._
  RequestInterceptor requestInterceptor;

  /// Hook into the request lifecycle after the response has been received and
  /// before the request is considered "complete" (in other words, before the
  /// response is delivered to the caller).
  ///
  /// If not null, this function will be called with three arguments: the
  /// [FinalizedRequest] instance, the [BaseResponse] instance, and a
  /// [RequestException] if the request failed. This function should return a
  /// `Future<BaseResponse>`, allowing the opportunity to modify, augment, or
  /// replace the response before considering it "complete".
  ResponseInterceptor responseInterceptor;

  /// HTTP method ('GET', 'POST', etc). Set automatically when the request is
  /// sent via one of the request dispatch methods.
  String get method;

  /// Amount of time to wait for the request to finish before canceling it and
  /// considering it "timed out" (results in a [RequestException] being thrown).
  ///
  /// If null, no timeout threshold will be enforced.
  Duration timeoutThreshold;

  /// [RequestProgress] stream for this HTTP request's upload.
  Stream<RequestProgress> get uploadProgress;

  /// Whether or not to send the request with credentials. Only applicable to
  /// requests in the browser, but does not adversely affect any other platform.
  bool withCredentials = false;

  /// Cancel this request. If the request has already finished, this will do
  /// nothing.
  ///
  /// If automatic retrying is enabled, this will also cancel a retry attempt if
  /// one is in flight and prevent any further retry attempts.
  void abort([Object error]);

  /// Returns an clone of this request.
  BaseRequest clone();

  /// Allows more advanced configuration of this request prior to sending. The
  /// supplied callback [configure] will be called after opening, but prior to
  /// sending, this request. The [request] parameter will either be an instance
  /// of [HttpRequest] or [HttpClientRequest], depending on the platform. If
  /// [configure] returns a `Future`, the request will not be sent until the
  /// returned `Future` completes.
  void configure(configure(Object request));

  /// Retry this request. Throws a `StateError` if this request did not or has
  /// yet to fail.
  Future<Response> retry();

  /// Retry this request and stream the response. Throws a `StateError` if this
  /// request did not or has yet to fail.
  Future<StreamedResponse> streamRetry();
}
