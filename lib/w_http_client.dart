/**
 * Copyright 2015 Workiva Inc.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

/// A fluent-style HTTP request library for use in the browser.
/// Supports simple request construction and response retrieval
/// for most use cases, with the option to configure the outgoing
/// [HttpRequest] if necessary.
///
/// To use this library in your code:
///
///     import 'package:w_transport/w_http_client.dart';
///
///     void main() {
///       new WHttp().get(Uri.parse('example.com')).then((WResponse response) {
///         print(response.text);
///       });
///     }
///
///
/// ## [WRequest]
/// [WRequest] is the class used to create and send HTTP requests from the browser.
/// It supports headers, request data, progress monitoring, withCredentials,
/// request cancellation, and sending requests with these HTTP methods:
///
/// * DELETE
/// * GET
/// * HEAD
/// * OPTIONS
/// * PATCH
/// * POST
/// * PUT
///
/// Additionally, [WRequest] extends [UrlMutation] for convenient request URL
/// construction.
///
///
/// ## [WResponse]
/// [WResponse] is the class that contains the response to a [WRequest]. All expected
/// relevant information is available: response headers, status code (200), status text ('OK'),
/// and response data.

library w_transport.w_http_client;

export 'src/http/w_http_client.dart';