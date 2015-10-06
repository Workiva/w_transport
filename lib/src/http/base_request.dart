library w_transport.src.http.base_request;

import 'dart:async';
import 'dart:convert';

import 'package:fluri/fluri.dart';
import 'package:http_parser/http_parser.dart';

import 'package:w_transport/src/http/request_dispatchers.dart';
import 'package:w_transport/src/http/request_progress.dart';

/// A common API that applies to all request types. The piece that is missing is
/// that which is specific to the request body. Setting the request body differs
/// based on the type of request being sent (plain-text, JSON, form, multipart,
/// or streamed). As such, that piece of the API is delegated to the specific
/// request classes.
abstract class BaseRequest implements FluriMixin, RequestDispatchers {
  /// Gets and sets the content-length of the request, in bytes. If the size of
  /// the request is not known in advance, set this to null.
  int contentLength;

  /// Content-type of this request.
  ///
  /// By default, the mime-type is "text/plain" and the charset is "UTF8".
  /// When the request body or the encoding is set or updated, the content-type
  /// will be updated accordingly.
  MediaType get contentType;

  /// Future that resolves when the request has completed (successful or
  /// otherwise).
  Future<Null> get done;

  /// [RequestProgress] stream for this HTTP request's download.
  Stream<RequestProgress> get downloadProgress;

  /// Encoding to use when encoding or decoding the request body. Setting this
  /// will also update the [contentType]'s charset.
  ///
  /// Defaults to UTF8.
  Encoding encoding = UTF8;

  /// Headers to send with the HTTP request. Headers are case-insensitive.
  ///
  /// Note that the "content-type" header will be set automatically based on the
  /// type of data in this request's body and the [encoding].
  Map<String, String> headers = {};

  /// HTTP method ('GET', 'POST', etc). Set automatically when the request is
  /// sent via one of the request dispatch methods.
  String get method;

  /// [RequestProgress] stream for this HTTP request's upload.
  Stream<RequestProgress> get uploadProgress;

  /// Whether or not to send the request with credentials. Only applicable to
  /// requests in the browser, but does not adversely affect any other platform.
  bool withCredentials = false;

  /// Cancel this request. If the request has already finished, this will do
  /// nothing.
  void abort([Object error]);

  /// Allows more advanced configuration of this request prior to sending. The
  /// supplied callback [configure] will be called after opening, but prior to
  /// sending, this request. The [request] parameter will either be an instance
  /// of [HttpRequest] or [HttpClientRequest], depending on the platform. If
  /// [configure] returns a `Future`, the request will not be sent until the
  /// returned `Future` completes.
  void configure(configure(request));
}
