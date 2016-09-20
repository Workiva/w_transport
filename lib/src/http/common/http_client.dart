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

import 'package:http_parser/http_parser.dart' show CaseInsensitiveMap;

import 'package:w_transport/src/http/auto_retry.dart';
import 'package:w_transport/src/http/base_request.dart';
import 'package:w_transport/src/http/http_interceptor.dart';
import 'package:w_transport/src/http/http_client.dart';

/// HTTP client logic that can be shared across platforms.
abstract class CommonHttpClient implements HttpClient {
  /// Configuration of automatic request retrying for failed requests. Use this
  /// object to enable or disable automatic retrying, configure the criteria
  /// that determines whether or not a request should be retried, as well as the
  /// number of retries to attempt.
  ///
  /// Every request created by this client will inherit this automatic retry
  /// configuration.
  @override
  AutoRetryConfig autoRetry = new AutoRetryConfig();

  /// A base URI that all requests created by this client should inherit.
  @override
  Uri baseUri;

  /// Amount of time to wait for the request to finish before canceling it and
  /// considering it "timed out" (results in a [RequestException] being thrown).
  ///
  /// If null, no timeout threshold will be enforced.
  @override
  Duration timeoutThreshold;

  /// Whether or not to send the request with credentials. Only applicable to
  /// requests in the browser, but does not adversely affect any other platform.
  @override
  bool withCredentials;

  /// Headers to be inherited by all requests created from this client.
  CaseInsensitiveMap<String> _headers = new CaseInsensitiveMap();

  /// Whether or not this HTTP client has been closed.
  bool _isClosed = false;

  /// List of outstanding requests.
  List<BaseRequest> _requests = [];

  Pathway<RequestPayload> _requestPathway = new Pathway();
  Pathway<ResponsePayload> _responsePathway = new Pathway();

  @override
  Map<String, String> get headers => _headers;

  @override
  set headers(Map<String, String> headers) {
    _headers = new CaseInsensitiveMap<String>.from(headers);
  }

  /// Whether or not this HTTP client has been closed.
  @override
  bool get isClosed => _isClosed;

  @override
  void addInterceptor(HttpInterceptor interceptor) {
    _requestPathway.addInterceptor(interceptor.interceptRequest);
    _responsePathway.addInterceptor(interceptor.interceptResponse);
  }

  /// Closes the client, canceling or closing any outstanding connections.
  @override
  void close() {
    if (isClosed) return;
    _isClosed = true;
    closeClient();
    for (final request in _requests) {
      request.abort(new Exception(
          'HTTP client was closed before this request could complete.'));
    }
  }

  /// Sub-classes should override this and close the platform-specific client
  /// being used.
  void closeClient() {}

  /// Registers a request created by this client so that it will be canceled if
  /// still incomplete when this client is closed. Also decorates the request by
  /// adding headers that are set on this client and setting the withCredentials
  /// flag.
  void registerAndDecorateRequest(BaseRequest request) {
    _requests.add(request);
    request
      ..uri = baseUri
      ..headers = _headers
      ..timeoutThreshold = timeoutThreshold;
    if (withCredentials == true) {
      request.withCredentials = true;
    }
    request.autoRetry
      ..backOff = autoRetry.backOff
      ..enabled = autoRetry.enabled
      ..forHttpMethods = autoRetry.forHttpMethods
      ..forStatusCodes = autoRetry.forStatusCodes
      ..forTimeouts = autoRetry.forTimeouts
      ..maxRetries = autoRetry.maxRetries
      ..test = autoRetry.test;
    if (_requestPathway.hasInterceptors) {
      request.requestInterceptor = (request) async {
        await _requestPathway.process(new RequestPayload(request));
      };
    }
    if (_responsePathway.hasInterceptors) {
      request.responseInterceptor = (request, response, [exception]) async {
        final payload = new ResponsePayload(request, response, exception);
        return (await _responsePathway.process(payload)).response;
      };
    }
    request.done.then((_) {
      _requests.remove(request);
    });
  }

  /// Throws a [StateError] if this client has been closed.
  void verifyNotClosed() {
    if (isClosed)
      throw new StateError(
          'HTTP Client has been closed, can\'t create a new request.');
  }
}
