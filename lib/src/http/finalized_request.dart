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

import 'package:w_transport/src/http/http_body.dart';

/// A finalized, read-only representation of a request.
class FinalizedRequest {
  /// The request body. Will either be an instance of [HttpBody] or
  /// [StreamedHttpBody].
  final BaseHttpBody body;

  /// The request headers. Case-insensitive.
  final Map<String, String> headers;

  /// The HTTP method (get, post, put, etc.).
  final String method;

  /// The URI the request will be opened against.
  final Uri uri;

  /// Whether or not credentials (secure cookies) will be sent with this
  /// request. Applicable only to the browser platform.
  final bool withCredentials;

  FinalizedRequest(this.method, this.uri, Map<String, String> headers,
      this.body, this.withCredentials)
      : this.headers = new Map<String, String>.unmodifiable(
            new CaseInsensitiveMap<String>.from(headers));
}
