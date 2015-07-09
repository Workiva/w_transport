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

import 'package:w_transport/src/http/w_http_common.dart' as common;

/// An HTTP client useful for quickly sending HTTP requests.
/// If used on the server side, an [HttpClient] is used internally, allowing
/// for network connection caching.
///
/// For simple requests, use the static methods on [WHttp]:
///
///     import 'package:w_transport/w_transport.dart';
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
///     import 'package:w_transport/w_transport.dart';
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
///     import 'package:w_transport/w_transport.dart';
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

  /// HTTP client used to create and send HTTP requests.
  /// In the browser, this will be unnecessary.
  /// On the server, this will be an instance of [HttpClient].
  dynamic _client;

  /// Whether or not the HTTP client has been closed.
  bool _closed = false;

  /// Construct a new WHttp instance. If used on the server,
  /// an underlying [HttpClient] instance will be used to cache
  /// network connections.
  WHttp() {
    common.verifyWHttpConfigurationIsSet();
    _client = common.getNewHttpClient();
  }

  /// Closes the client, cancelling or closing any outstanding connections.
  void close() {
    _closed = true;
    if (_client != null) {
      _client.close();
    }
  }

  /// Generates a new [WRequest] instance that will use this client
  /// to send the request.
  WRequest newRequest() {
    if (_closed) throw new StateError(
        'WHttp client has been closed, can\'t create a new request.');
    return new WRequest._withClient(_client);
  }
}

/// An exception that is raised when a response to a request returns with
/// an unsuccessful status code.
class WHttpException implements Exception {
  /// HTTP method.
  final String method;

  /// Failed request.
  final WRequest request;

  /// Response to the failed request (some of the properties may be unavailable).
  final WResponse response;

  /// URL of the attempted/unsuccessful request.
  final Uri uri;

  /// Original error, if any.
  var _error;

  /// Construct a new instance of [WHttpException] using information from
  /// an HTTP request and response.
  WHttpException(this.method, this.uri, this.request, this.response,
      [this._error]);

  /// Descriptive error message that includes the request method & URL and the response status.
  String get message {
    String msg = 'WHttpException: $method';
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
  String toString() => message;
}

/// A class for creating and sending HTTP requests.
///
///     import 'dart:convert';
///     import 'package:w_transport/w_transport.dart';
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

  /// Error associated with a cancellation.
  Object _cancellationError;

  /// Whether or not the request has been canceled by the caller.
  bool _canceled = false;

  /// HTTP client (if any) used to send requests.
  dynamic _client;

  /// Configuration callback for advanced request configuration.
  /// See [configure].
  Function _configure;

  /// Data to send on the HTTP request.
  Object _data;

  /// [WProgress] stream controller for this HTTP request's download.
  StreamController<WProgress> _downloadProgressController =
      new StreamController<WProgress>();

  /// HTTP method ('GET', 'POST', etc).
  String _method;

  /// Underlying HTTP request object. Either an instance of
  /// [HttpRequest] or [HttpClientRequest].
  dynamic _request;

  /// [WProgress] stream controller for this HTTP request's upload.
  StreamController<WProgress> _uploadProgressController =
      new StreamController<WProgress>();

  /// Whether or not this request is the only request that will be
  /// sent by its HTTP client. If that is the case, the client
  /// will have to be closed immediately after sending.
  bool _single;

  /// Create a new [WRequest] ready to be modified, opened, and sent.
  WRequest()
      : super(),
        _single = true {
    common.verifyWHttpConfigurationIsSet();
    _client = common.getNewHttpClient();
  }

  /// Create a [WRequest] with a pre-existing [HttpClient] instance.
  /// The given [HttpClient] instance will be used instead of a new one.
  /// [WHttp] uses this constructor.
  WRequest._withClient(client)
      : super(),
        _client = client,
        _single = false;

  /// [WProgress] stream for this HTTP request's download.
  Stream<WProgress> get downloadProgress => _downloadProgressController.stream;

  /// HTTP method ('GET', 'POST', etc).
  String get method => _method;

  /// [WProgress] stream for this HTTP request's upload.
  Stream<WProgress> get uploadProgress => _uploadProgressController.stream;

  /// Cancel this request. If the request has already finished, this will do nothing.
  void abort([Object error]) {
    if (_request != null) {
      _abortRequest(_request);
    }
    _canceled = true;
    _cancellationError = error;
  }

  /// Allows more advanced configuration of this request prior to sending.
  /// The supplied callback [configureRequest] should be called after opening,
  /// but prior to sending, this request. The [request] parameter will either
  /// be an instance of [HttpRequest] or [HttpClientRequest],
  /// depending on the w_transport usage. If [configureRequest] returns a Future,
  /// the request will not be sent until the returned Future completes.
  void configure(configure(request)) {
    _configure = configure;
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

  void _abortRequest(request) {
    common.abort(_request);
  }

  void _checkForCancellation({WResponse response}) {
    if (_canceled) {
      throw new WHttpException(_method, this.uri, this, response,
          _cancellationError != null
              ? _cancellationError
              : new Exception('Request canceled.'));
    }
  }

  void _cleanUp() {
    if (_single && _client != null) {
      _client.close();
    }
  }

  Future<WResponse> _getResponse() async {
    WResponse response;
    try {
      _request = await common.openRequest(method, this.uri, _client);
      _checkForCancellation();
      response = await common.send(method, this, _request,
          _downloadProgressController, _uploadProgressController, _configure);
    } catch (e) {
      _cleanUp();
      _checkForCancellation(response: response);
      throw e;
    }
    _cleanUp();
    _checkForCancellation(response: response);
    return response;
  }

  void _initializeRequestInfo(String method, [Uri uri, Object data]) {
    _method = method;
    if (uri != null) {
      this.uri = uri;
    }
    if (this.uri == null || this.uri.toString() == '') {
      throw new StateError('WRequest: Cannot send a request without a URL.');
    }
    if (data != null) {
      this.data = data;
    }
  }

  Future<WResponse> _send(String method, [Uri uri, Object data]) async {
    _initializeRequestInfo(method, uri, data);
    _checkForCancellation();
    common.validateDataType(this.data);
    return _getResponse();
  }
}

/// Content of and meta data about a response to an HTTP request.
/// All meta data (headers, status, statusText) are available immediately.
/// Response content (data, text, or stream) is available asynchronously.
class WResponse {
  /// Headers sent with the response to the HTTP request.
  final Map<String, String> headers;

  /// Status code of the response to the HTTP request.
  /// 200, 404, etc.
  final int status;

  /// Status text of the response to the HTTP request.
  /// 'OK', 'Not Found', etc.
  final String statusText;

  /// Whether or not the response has been cached.
  bool _cached = false;

  /// The list of cached response chunks, if the response has been cached.
  List<Object> _cachedResponse = [];

  /// Controls the stream of download progress events.
  final StreamController<WProgress> _downloadProgressController;

  /// Encoding to use when decoding the response into text.
  /// Inherited from the the [WRequest] instance.
  final Encoding _encoding;

  /// Source for the response body.
  Stream _source;

  /// Total size of the response body, if known.
  final int _total;

  WResponse._(response, this._encoding,
      [this._total = -1, this._downloadProgressController])
      : headers = common.parseResponseHeaders(response),
        status = common.parseResponseStatus(response),
        statusText = common.parseResponseStatusText(response) {
    _source = common.parseResponseStream(
        response, _total, _downloadProgressController);
    _source = _source.transform(_cache());
  }

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
  Future<Object> asFuture() => _getFuture();

  /// The data stream received as a response from the request.
  Stream asStream() => _getStream();

  /// The data received as a response from the request in String format.
  Future<String> asText() => _getText();

  /// Update the underlying response data source.
  /// [asFuture], [asText], and [asStream] all use this data source.
  void update(dynamic dataSource) {
    if (dataSource is! Stream) {
      dataSource = new Stream.fromIterable([dataSource]);
    }
    _cached = false;
    _cachedResponse = [];
    _source = (dataSource as Stream).transform(_cache());
  }

  /// Caches the response data stream to enable multiple accesses.
  StreamTransformer<Object, Object> _cache() =>
      new StreamTransformer<Object, Object>((Stream<Object> input,
          bool cancelOnError) {
    StreamController<Object> controller;
    StreamSubscription<Object> subscription;
    controller = new StreamController<Object>(onListen: () {
      _cached = true;
      subscription = input.listen((Object value) {
        controller.add(value);
        _cachedResponse.add(value);
      },
          onError: controller.addError,
          onDone: controller.close,
          cancelOnError: cancelOnError);
    }, onPause: () {
      subscription.pause();
    }, onResume: () {
      subscription.resume();
    }, onCancel: () {
      subscription.cancel();
    });
    return controller.stream.listen(null);
  });

  /// Gets the response data as an untyped object.
  Future<Object> _getFuture() => common.parseResponseData(_getStream());

  /// Gets the response data source stream. Returns a new stream from
  /// the cache if available, returns the original stream otherwise.
  Stream _getStream() =>
      _cached ? new Stream.fromIterable(_cachedResponse) : _source;

  /// Gets the response data in String format.
  Future<String> _getText() => common
      .parseResponseText(_getStream().transform(decodeAttempt(_encoding)));
}

/// A representation of a progress event at a specific point in time
/// either for an HTTP request upload or download. Based on [ProgressEvent]
/// but with an additional [percent] property for convenience.
class WProgress {
  /// Amount of work already done.
  final int loaded;

  /// Total amount of work being performed. This only represents the content
  /// itself, not headers and other overhead.
  final int total;

  /// Indicates whether or not the progress is measurable.
  bool _lengthComputable;

  /// Percentage of work done.
  double _percent;

  WProgress([this.loaded = 0, this.total = -1]) {
    _lengthComputable = total > -1;
    _percent = lengthComputable ? loaded * 100.0 / total : 0.0;
  }

  /// Indicates whether or not the progress is measurable.
  bool get lengthComputable => _lengthComputable;

  /// Percentage of work done.
  double get percent => _percent;
}

StreamTransformer decodeAttempt(Encoding encoding) {
  return new StreamTransformer((Stream input, bool cancelOnError) {
    StreamController controller;
    StreamSubscription subscription;
    controller = new StreamController(onListen: () {
      subscription = input.listen((data) {
        try {
          data = encoding.decode(data);
        } catch (e) {}
        controller.add(data);
      }, onError: controller.addError, onDone: () {
        controller.close();
      }, cancelOnError: cancelOnError);
    }, onPause: () {
      subscription.pause();
    }, onResume: () {
      subscription.resume();
    }, onCancel: () {
      subscription.cancel();
    });
    return controller.stream.listen(null);
  });
}

WResponse wResponseFactory(response, Encoding encoding,
    [int total = 1, StreamController<WProgress> downloadProgressController]) {
  return new WResponse._(response, encoding, total, downloadProgressController);
}
