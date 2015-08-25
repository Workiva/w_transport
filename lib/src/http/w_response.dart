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

library w_transport.src.http.w_response;

import 'dart:async';

/// Content of and meta data about a response to an HTTP request.
/// All meta data (headers, status, statusText) are available immediately.
/// Response content (data, text, or stream) is available asynchronously.
abstract class WResponse {
  /// Headers sent with the response to the HTTP request.
  Map<String, String> get headers;

  /// Status code of the response to the HTTP request.
  /// 200, 404, etc.
  int get status;

  /// Status text of the response to the HTTP request.
  /// 'OK', 'Not Found', etc.
  String get statusText;

  /// The data received as a response from the request.
  ///
  /// On the client side, the type of data will be one of:
  ///
  ///   - `Blob`
  ///   - `ByteBuffer`
  ///   - `Document`
  ///   - `String`
  ///
  /// On the server side, the type of data will be:
  ///
  ///   - `List<int>`
  Future<Object> asFuture();

  /// The data stream received as a response from the request.
  Stream asStream();

  /// The data received as a response from the request in String format.
  Future<String> asText();

  /// Update the underlying response data source.
  /// [asFuture], [asText], and [asStream] all use this data source.
  void update(dynamic dataSource);
}
