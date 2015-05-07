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

library w_transport.src.http.w_http;

import 'dart:async';
import 'dart:convert';

import 'package:fluri/fluri.dart';

import 'w_http_common.dart' as common;

/// [WHttp] is a platform-agnostic HTTP client useful for quickly
/// sending HTTP requests. If used on the server side, an [HttpClient]
/// is used internally, allowing for network connection caching.
class WHttp {
  static Future<WResponse> delete(Uri uri) => new WRequest().delete(uri);
  static Future<WResponse> get(Uri uri) => new WRequest().get(uri);
  static Future<WResponse> head(Uri uri) => new WRequest().head(uri);
  static Future<WResponse> options(Uri uri) => new WRequest().options(uri);
  static Future<WResponse> patch(Uri uri, [Object data]) =>
      new WRequest().patch(uri, data);
  static Future<WResponse> post(Uri uri, [Object data]) =>
      new WRequest().post(uri, data);
  static Future<WResponse> put(Uri uri, [Object data]) =>
      new WRequest().put(uri, data);
  static Future<WResponse> trace(Uri uri) => new WRequest().trace(uri);

  dynamic _client;

  WHttp() : _client = common.getNewHttpClient();

  /// Generates a new WRequest instance that should use this client
  /// to send the request.
  WRequest newRequest() => new WRequest._withClient(_client);

  /// Closes the client, cancelling or closing any outstanding connections.
  void close() {
    if (_client != null) {
      _client.close();
    }
  }
}

/// An exception that is raised when a response to a request returns with
/// an unsuccessful status code.
class WHttpException implements Exception {
  /// Descriptive error message that includes the request method & URL and the response status.
  final String message;

  /// Failed request.
  final WRequest request;

  /// Response to the failed request (some of the properties may be unavailable).
  final WResponse response;

  /// URL of the attempted/unsuccessful request.
  final Uri uri;

  WHttpException(this.message, [this.uri, this.request, this.response]);
}

/// Platform-agnostic transport class for HTTP requests.
class WRequest extends Object with FluriMixin {
  dynamic _request;
  dynamic _client;

  /// Create a WRequest that will use its own, new HttpClient instance.
  WRequest()
      : super(),
        _client = common.getNewHttpClient(),
        encoding = UTF8 {
    common.verifyWHttpConfigurationIsSet();
  }

  /// Create a WRequest with a pre-existing HttpClient instance.
  /// The given HttpClient instance will be used instead of a new one.
  /// WHttpClient uses this constructor.
  WRequest._withClient(client)
      : super(),
        _client = client;

  /// Gets and sets the content length of the request. If the size of
  /// the request is not known in advance set content length to -1.
  int contentLength;

  /// Data to send on the HTTP request.
  /// On the client side, data type can be one of:
  ///   - [ByteBuffer]
  ///   - [Document]
  ///   - [FormData]
  ///   - [String]
  /// On the server side, data type can be one of:
  ///   - [Stream]
  ///   - [String]
  void set data(Object data) {
    common.validateDataType(data);
    _data = data;
  }
  Object get data => _data;
  Object _data;

  /// Encoding to use on the request data.
  Encoding encoding = UTF8;

  /// Headers to send with the HTTP request.
  Map<String, String> headers = {};

  /// Whether or not to send the request with credentials.
  bool withCredentials = false;

  /// [WProgress] stream for this HTTP request's upload.
  StreamController<WProgress> _uploadProgressController =
      new StreamController<WProgress>();
  Stream<WProgress> get uploadProgress => _uploadProgressController.stream;

  /// [WProgress] stream for this HTTP request's download.
  StreamController<WProgress> _downloadProgressController =
      new StreamController<WProgress>();
  Stream<WProgress> get downloadProgress => _downloadProgressController.stream;

  /// Allows more advanced configuration of the request prior to sending.
  /// The supplied callback [configureRequest] should be called after opening,
  /// but prior to sending, the request. The [request] parameter should be the
  /// instance of either dart:html.HttpRequest or dart:io.HttpClientRequest,
  /// depending on the implementation. If [configureRequest] returns a Future,
  /// the request should not be sent until the returned Future completes.
  void configure(configure(request)) {
    _configure = configure;
  }
  Function _configure;

  /// Cancel the request. If the request has already finished, this will do nothing.
  void abort() {
    if (_request == null) throw new StateError(
        'Can\'t cancel a request that has not yet been opened.');
    common.abort(_request);
  }

  /// The following methods should send an HTTP request with the appropriate HTTP method,
  /// returning a Future that should complete with the response.
  Future<WResponse> delete([Uri uri]) {
    return _send('DELETE', uri);
  }
  Future<WResponse> get([Uri uri]) {
    return _send('GET', uri);
  }
  Future<WResponse> head([Uri uri]) {
    return _send('HEAD', uri);
  }
  Future<WResponse> options([Uri uri]) {
    return _send('OPTIONS', uri);
  }
  Future<WResponse> patch([Uri uri, Object data]) {
    return _send('PATCH', uri, data);
  }
  Future<WResponse> post([Uri uri, Object data]) {
    return _send('POST', uri, data);
  }
  Future<WResponse> put([Uri uri, Object data]) {
    return _send('PUT', uri, data);
  }
  Future<WResponse> trace([Uri uri]) {
    return _send('TRACE', uri);
  }

  Future<WResponse> _send(String method, [Uri uri, Object data]) async {
    if (uri != null) {
      this.uri = uri;
    }
    if (data != null) {
      this.data = data;
    }

    if (this.uri == null ||
        this.uri.toString() == null ||
        this.uri.toString() == '') {
      throw new StateError('WRequest: Cannot send a request without a URL.');
    }

    _request = await common.openRequest(method, this.uri, _client);
    return common.send(method, this, _request, _downloadProgressController,
        _uploadProgressController, _configure);
  }
}

/// Content of and meta data about a response to an HTTP request.
/// All meta data (headers, status, statusText) are available immediately.
/// Response content (data, text, or stream) is available asynchronously.
class WResponse {
  final Encoding _encoding;
  final dynamic _response;
  final int _total;
  final StreamController<WProgress> _downloadProgressController;

  /// Headers sent with the response to the HTTP request.
  final Map<String, String> headers;

  /// Status code of the response to the HTTP request.
  /// 200, 404, etc.
  final int status;

  /// Status text of the response to the HTTP request.
  /// 'OK', 'Not Found', etc.
  final String statusText;

  /// The data received as a response from the request.
  ///
  /// On the client side, the type of data will be one of:
  ///   - Blob
  ///   - ByteBuffer
  ///   - Document
  ///   - String
  /// On the server side, the type of data will be:
  ///   - List<int>
  Future<Object> get data =>
      common.parseResponseData(_response, _total, _downloadProgressController);

  /// The data received as a response from the request in String format.
  Future<String> get text => common.parseResponseText(
      _response, _encoding, _total, _downloadProgressController);

  /// The data stream received as a response from the request.
  Stream get stream => common.parseResponseStream(
      _response, _total, _downloadProgressController);

  WResponse(response, this._encoding,
      [this._total = -1, this._downloadProgressController])
      : _response = response,
        headers = common.parseResponseHeaders(response),
        status = common.parseResponseStatus(response),
        statusText = common.parseResponseStatusText(response);
}

/// [WProgress] depicts a progress event at a specific point in time
/// either for an HTTP request upload or download. Based on [ProgressEvent]
/// but with an additional [percent] property for convenience.
class WProgress {
  /// Indicates whether or not the progress is measurable.
  bool get lengthComputable => _lengthComputable;
  bool _lengthComputable;

  /// Amount of work already done.
  final int loaded;

  /// Total amount of work being performed. This only represents the content
  /// itself, not headers and other overhead.
  final int total;

  /// Percentage of work done.
  double get percent => _percent;
  double _percent;

  WProgress([this.loaded = 0, this.total = -1]) {
    _lengthComputable = total > -1;
    _percent = lengthComputable ? loaded * 100.0 / total : 0.0;
  }
}
