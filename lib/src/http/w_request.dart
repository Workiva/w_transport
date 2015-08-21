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

library w_transport.src.http.w_request;

import 'dart:async';
import 'dart:convert';

import 'package:fluri/fluri.dart';

import 'package:w_transport/src/http/w_response.dart';
import 'package:w_transport/src/http/w_progress.dart';
import 'package:w_transport/src/platform_adapter.dart';

abstract class WRequest implements FluriMixin {
  /// Gets and sets the content length of the request. If the size of
  /// the request is not known in advance set content length to -1.
  int contentLength;

  /// Data to send on the HTTP request.
  /// On the client side, data type can be one of:
  ///
  ///   - `ByteBuffer`
  ///   - `Document`
  ///   - `FormData`
  ///   - `String`
  ///
  /// On the server side, data type can be one of:
  ///
  ///   - `Stream`
  ///   - `String`
  Object data;

  /// Encoding to use on the request data.
  Encoding encoding = UTF8;

  /// Headers to send with the HTTP request.
  Map<String, String> headers = {};

  /// Whether or not to send the request with credentials.
  bool withCredentials = false;

  factory WRequest() => PlatformAdapter.retrieve().newWRequest();

  /// [WProgress] stream for this HTTP request's download.
  Stream<WProgress> get downloadProgress;

  /// HTTP method ('GET', 'POST', etc).
  String get method;

  /// [WProgress] stream for this HTTP request's upload.
  Stream<WProgress> get uploadProgress;

  /// Cancel this request. If the request has already finished, this will do nothing.
  void abort([Object error]);

  /// Allows more advanced configuration of this request prior to sending.
  /// The supplied callback [configureRequest] should be called after opening,
  /// but prior to sending, this request. The [request] parameter will either
  /// be an instance of [HttpRequest] or [HttpClientRequest],
  /// depending on the w_transport usage. If [configureRequest] returns a Future,
  /// the request will not be sent until the returned Future completes.
  void configure(configure(request));

  /// Sends a DELETE request to the given [uri].
  /// If [uri] is null, the uri on this [WRequest] will be used.
  Future<WResponse> delete([Uri uri]);

  /// Sends a GET request to the given [uri].
  /// If [uri] is null, the uri on this [WRequest] will be used.
  Future<WResponse> get([Uri uri]);

  /// Sends a HEAD request to the given [uri].
  /// If [uri] is null, the uri on this [WRequest] will be used.
  Future<WResponse> head([Uri uri]);

  /// Sends an OPTIONS request to the given [uri].
  /// If [uri] is null, the uri on this [WRequest] will be used.
  Future<WResponse> options([Uri uri]);

  /// Sends a PATCH request to the given [uri].
  /// If [uri] is null, the uri on this [WRequest] will be used.
  /// Attaches [data], if given, or uses the data from this [WRequest].
  Future<WResponse> patch([Uri uri, Object data]);

  /// Sends a POST request to the given [uri].
  /// If [uri] is null, the uri on this [WRequest] will be used.
  /// Attaches [data], if given, or uses the data from this [WRequest].
  Future<WResponse> post([Uri uri, Object data]);

  /// Sends a PUT request to the given [uri].
  /// If [uri] is null, the uri on this [WRequest] will be used.
  /// Attaches [data], if given, or uses the data from this [WRequest].
  Future<WResponse> put([Uri uri, Object data]);

  /// Sends a TRACE request to the given [uri].
  /// If [uri] is null, the uri on this [WRequest] will be used.
  ///
  /// **Note:** For security reasons, TRACE requests are forbidden in the browser.
  Future<WResponse> trace([Uri uri]);
}
