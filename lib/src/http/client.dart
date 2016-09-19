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

import 'package:w_transport/src/constants.dart' show v3Deprecation;
import 'package:w_transport/src/http/auto_retry.dart';
import 'package:w_transport/src/http/http_client.dart';
import 'package:w_transport/src/http/http_interceptor.dart';
import 'package:w_transport/src/http/requests.dart';
import 'package:w_transport/src/transport_platform.dart';

/// An HTTP client acts as a single point from which many requests can be
/// constructed. All requests constructed from a client will inherit [headers],
/// the [withCredentials] flag, and the [timeoutThreshold].
///
/// On the server, the Dart VM will also be able to take advantage of cached
/// network connections between requests that share a client.
///
/// TODO: Remove this class in 4.0.0 and move the abstract definition into the `HttpClient` class.
@Deprecated(v3Deprecation + 'Use `HttpClient` instead.')
abstract class Client {
  factory Client({TransportPlatform transportPlatform}) =>
      new HttpClient(transportPlatform: transportPlatform);

  /// Configuration of automatic request retrying for failed requests. Use this
  /// object to enable or disable automatic retrying, configure the criteria
  /// that determines whether or not a request should be retried, as well as the
  /// number of retries to attempt.
  ///
  /// Every request created by this client will inherit this automatic retry
  /// configuration.
  AutoRetryConfig autoRetry;

  /// A base URI that all requests from this client should inherit.
  Uri baseUri;

  /// Get and set request headers that will be applied to all requests created
  /// by this HTTP client.
  Map<String, String> headers;

  /// Whether or not the HTTP client has been closed.
  bool get isClosed;

  /// Amount of time to wait for a request created by this client to finish
  /// before canceling it and considering it "timed out" (results in a
  /// [RequestException] being thrown).
  ///
  /// If null, no timeout threshold will be enforced.
  Duration timeoutThreshold;

  /// Whether or not to send requests from this client with credentials. Only
  /// applicable to requests in the browser, but does not adversely affect any
  /// other platform.
  bool withCredentials;

  void addInterceptor(HttpInterceptor interceptor);

  /// Closes the client, cancelling or closing any outstanding connections.
  void close();

  /// Constructs a new [FormRequest] that will use this client to send the
  /// request. Throws a [StateError] if this client has been closed.
  FormRequest newFormRequest();

  /// Constructs a new [JsonRequest] that will use this client to send the
  /// request. Throws a [StateError] if this client has been closed.
  JsonRequest newJsonRequest();

  /// Constructs a new [MultipartRequest] that will use this client to send the
  /// request. Throws a [StateError] if this client has been closed.
  MultipartRequest newMultipartRequest();

  /// Constructs a new [Request] that will use this client to send the request.
  /// Throws a [StateError] if this client has been closed.
  Request newRequest();

  /// Constructs a new [StreamedRequest] that will use this client to send the
  /// request. Throws a [StateError] if this client has been closed.
  StreamedRequest newStreamedRequest();
}
