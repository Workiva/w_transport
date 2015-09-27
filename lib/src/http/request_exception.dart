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

library w_transport.src.http.request_exception;

import 'package:w_transport/src/http/base_request.dart';
import 'package:w_transport/src/http/response.dart';

/// An exception that is raised when a response to a request returns with
/// an unsuccessful status code.
class RequestException implements Exception {
  /// HTTP method.
  final String method;

  /// Failed request.
  final BaseRequest request;

  /// Response to the failed request (some of the properties may be unavailable).
  final Response response;

  /// URL of the attempted/unsuccessful request.
  final Uri uri;

  /// Original error, if any.
  var _error;

  /// Construct a new instance of [WHttpException] using information from
  /// an HTTP request and response.
  RequestException(this.method, this.uri, this.request, this.response,
      [this._error]);

  /// Descriptive error message that includes the request method & URL and the response status.
  String get message {
    String msg = '$method';
    if (response != null) {
      msg += ' ${response.status} ${response.statusText}';
    }
    msg += ' $uri';
    if (_error != null) {
      msg += '\n\t$_error';
    }
    return msg;
  }

  @override
  String toString() => 'RequestException: $message';
}
