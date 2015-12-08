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

library w_transport.src.http.common.client;

import 'package:http_parser/http_parser.dart' show CaseInsensitiveMap;

import 'package:w_transport/src/http/base_request.dart';
import 'package:w_transport/src/http/client.dart';

/// HTTP client logic that can be shared across platforms.
abstract class CommonClient implements Client {
  CaseInsensitiveMap<String> _headers = new CaseInsensitiveMap();

  /// Whether or not this HTTP client has been closed.
  bool _isClosed = false;

  /// List of outstanding requests.
  List<BaseRequest> _requests = [];

  Map<String, String> get headers => _headers;
  set headers(Map<String, String> headers) {
    _headers = new CaseInsensitiveMap.from(headers);
  }

  /// Whether or not this HTTP client has been closed.
  @override
  bool get isClosed => _isClosed;

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

  /// Closes the client, canceling or closing any outstanding connections.
  @override
  void close() {
    if (isClosed) return;
    _isClosed = true;
    closeClient();
    for (var request in _requests) {
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
    request
      ..headers = _headers
      ..timeoutThreshold = timeoutThreshold;
    if (withCredentials == true) {
      request.withCredentials = true;
    }
    _requests.add(request);
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
