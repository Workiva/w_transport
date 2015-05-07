/*
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

/// Classes for sending and receiving data over HTTP designed with a
/// single, platform-agnostic API to make client and server usage easy.
///
/// If possible, APIs built using these classes should also avoid
/// importing `dart:html` or `dart:io` in order to remain platform-agnostic,
/// as it provides a much greater reuse value.
library w_transport.src.http.w_http;

import 'dart:async';
import 'dart:convert';

import 'package:fluri/fluri.dart';

import 'w_http_common.dart' as common;

/// An HTTP client useful for quickly sending HTTP requests.
/// If used on the server side, an [HttpClient] is used internally, allowing
/// for network connection caching.
///
/// For simple requests, use the static methods on [WHttp]:
///
///     import 'package:w_transport/w_http.dart';
///
///     void main() {
///       Uri uri = Uri.parse('example.com');
///       WHttp.delete(uri);
///       WHttp.get(uri);
///       WHttp.head(uri);
///       WHttp.options(uri);
///       WHttp.patch(uri, 'data');
///       WHttp.post(uri, 'data');
///       WHttp.put(uri, 'data');
///       WHttp.trace(uri);
///     }
///
/// If you're going to be sending many HTTP requests and want to take
/// advantage of cached network connections, construct a new [WHttp]
/// instance and use it to create and send requests.
///
///     import 'dart:async';
///     import 'package:w_transport/w_http.dart';
///
///     WHttp http;
///     Timer timer;
///
///     void startPolling() {
///       http = new WHttp();
///       timer = new Timer.periodic(new Duration(seconds: 2), (_) {
///         http.newRequest().get(Uri.parse('example.com'));
///       });
///     }
///
///     void stopPolling() {
///       timer.cancel();
///       http.close();
///     }
///
///     void main() {
///       startPolling();
///       new Timer(new Duration(seconds: 10), stopPolling);
///     }
///
/// If you do create an instance of [WHttp], be sure to close it when done.
/// This shuts down the underlying [HttpClient] and closes idle network
/// connections.
///
///     import 'package:w_transport/w_http.dart';
///
///     void main() {
///       WHttp http = new WHttp();
///       ...
///       http.close();
///     }
class WHttp {
  /// Sends a DELETE request to the given [uri].
  static Future<WResponse> delete(Uri uri) => new WRequest().delete(uri);
  /// Sends a GET request to the given [uri].
  static Future<WResponse> get(Uri uri) => new WRequest().get(uri);
  /// Sends a HEAD request to the given [uri].
  static Future<WResponse> head(Uri uri) => new WRequest().head(uri);
  /// Sends an OPTIONS request to the given [uri].
  static Future<WResponse> options(Uri uri) => new WRequest().options(uri);
  /// Sends a PATCH request to the given [uri].
  /// Attaches [data], if given.
  static Future<WResponse> patch(Uri uri, [Object data]) =>
      new WRequest().patch(uri, data);
  /// Sends a POST request to the given [uri].
  /// Attaches [data], if given.
  static Future<WResponse> post(Uri uri, [Object data]) =>
      new WRequest().post(uri, data);
  /// Sends a PUT request to the given [uri].
  /// Attaches [data], if given.
  static Future<WResponse> put(Uri uri, [Object data]) =>
      new WRequest().put(uri, data);
  /// Sends a TRACE request to the given [uri].
  ///
  /// **Note:** For security reasons, TRACE requests are forbidden in the browser.
  static Future<WResponse> trace(Uri uri) => new WRequest().trace(uri);

  dynamic _client;

  /// Construct a new WHttp instance. If used on the server,
  /// an underlying [HttpClient] instance will be used to cache
  /// network connections.
  WHttp() : _client = common.getNewHttpClient();

  /// Generates a new [WRequest] instance that will use this client
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
  String get message =>
      'WHttpException: $method ${response.status} ${response.statusText} $uri';

  /// HTTP method.
  final String method;

  /// Failed request.
  final WRequest request;

  /// Response to the failed request (some of the properties may be unavailable).
  final WResponse response;

  /// URL of the attempted/unsuccessful request.
  Uri get uri => request.uri;

  WHttpException(this.method, this.request, this.response);
}

/// A class for creating and sending HTTP requests.
///
///     import 'dart:convert';
///     import 'package:w_transport/w_http.dart';
///
///     main() async {
///       var data = ...;
///       WRequest request = new WRequest()
///         ..uri = Uri.parse('example.com')
///         ..path = '/path/to/resource'
///         ..data = JSON.encode(data);
///
///       request.uploadProgress.listen((WProgress progress) =>
///           print('UL: ${progress.percent}%'));
///       request.downloadProgress.listen((WProgress progress) =>
///           print('DL: ${progress.percent}%'));
///
///       WResponse response = await request.post();
///       print('Success: ${response.status} ${response.statusText}');
///       print(response.headers);
///       print(await response.text);
///     }
class WRequest extends Object with FluriMixin {
  dynamic _request;
  dynamic _client;

  /// Create a new [WRequest] ready to be modified, opened, and sent.
  WRequest()
      : super(),
        _client = common.getNewHttpClient(),
        encoding = UTF8 {
    common.verifyWHttpConfigurationIsSet();
  }

  /// Create a [WRequest] with a pre-existing [HttpClient] instance.
  /// The given [HttpClient] instance will be used instead of a new one.
  /// [WHttp] uses this constructor.
  WRequest._withClient(client)
      : super(),
        _client = client;

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
  Stream<WProgress> get uploadProgress => _uploadProgressController.stream;
  StreamController<WProgress> _uploadProgressController =
      new StreamController<WProgress>();

  /// [WProgress] stream for this HTTP request's download.
  Stream<WProgress> get downloadProgress => _downloadProgressController.stream;
  StreamController<WProgress> _downloadProgressController =
      new StreamController<WProgress>();

  /// Allows more advanced configuration of this request prior to sending.
  /// The supplied callback [configureRequest] should be called after opening,
  /// but prior to sending, this request. The [request] parameter will either
  /// be an instance of [HttpRequest] or [HttpClientRequest],
  /// depending on the w_transport usage. If [configureRequest] returns a Future,
  /// the request will not be sent until the returned Future completes.
  void configure(configure(request)) {
    _configure = configure;
  }
  Function _configure;

  /// Cancel this request. If the request has already finished, this will do nothing.
  void abort() {
    if (_request == null) throw new StateError(
        'Can\'t cancel a request that has not yet been opened.');
    common.abort(_request);
  }

  /// Sends a DELETE request to the given [uri].
  /// If [uri] is null, the uri on this [WRequest] will be used.
  Future<WResponse> delete([Uri uri]) {
    return _send('DELETE', uri);
  }
  /// Sends a GET request to the given [uri].
  /// If [uri] is null, the uri on this [WRequest] will be used.
  Future<WResponse> get([Uri uri]) {
    return _send('GET', uri);
  }
  /// Sends a HEAD request to the given [uri].
  /// If [uri] is null, the uri on this [WRequest] will be used.
  Future<WResponse> head([Uri uri]) {
    return _send('HEAD', uri);
  }
  /// Sends an OPTIONS request to the given [uri].
  /// If [uri] is null, the uri on this [WRequest] will be used.
  Future<WResponse> options([Uri uri]) {
    return _send('OPTIONS', uri);
  }
  /// Sends a PATCH request to the given [uri].
  /// If [uri] is null, the uri on this [WRequest] will be used.
  /// Attaches [data], if given, or uses the data from this [WRequest].
  Future<WResponse> patch([Uri uri, Object data]) {
    return _send('PATCH', uri, data);
  }
  /// Sends a POST request to the given [uri].
  /// If [uri] is null, the uri on this [WRequest] will be used.
  /// Attaches [data], if given, or uses the data from this [WRequest].
  Future<WResponse> post([Uri uri, Object data]) {
    return _send('POST', uri, data);
  }
  /// Sends a PUT request to the given [uri].
  /// If [uri] is null, the uri on this [WRequest] will be used.
  /// Attaches [data], if given, or uses the data from this [WRequest].
  Future<WResponse> put([Uri uri, Object data]) {
    return _send('PUT', uri, data);
  }
  /// Sends a TRACE request to the given [uri].
  /// If [uri] is null, the uri on this [WRequest] will be used.
  ///
  /// **Note:** For security reasons, TRACE requests are forbidden in the browser.
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
  ///
  ///   - `Blob`
  ///   - `ByteBuffer`
  ///   - `Document`
  ///   - `String`
  ///
  /// On the server side, the type of data will be:
  ///
  ///   - `List<int>`
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

/// A representation of a progress event at a specific point in time
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
