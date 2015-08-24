library w_transport.src.http.common.w_response;

import 'dart:async';

abstract class CommonWResponse {
  /// Headers sent with the response to the HTTP request.
  final Map<String, String> headers;

  /// Status code of the response to the HTTP request.
  /// 200, 404, etc.
  final int status;

  /// Status text of the response to the HTTP request.
  /// 'OK', 'Not Found', etc.
  final String statusText;

  /// The list of cached response chunks, if the response has been cached.
  List<Object> _cachedResponse = [];

  /// Whether or not the response has been cached.
  bool _isCached = false;

  /// Source for the response body.
  Stream _source;

  CommonWResponse(int this.status, String this.statusText,
      Map<String, String> this.headers, Stream source) {
    _source = source.transform(_cache());
  }

  Stream get source =>
      _isCached ? new Stream.fromIterable(_cachedResponse) : _source;

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
  void update(dynamic dataSource) {
    if (dataSource is! Stream) {
      dataSource = new Stream.fromIterable([dataSource]);
    }
    _isCached = false;
    _cachedResponse = [];
    _source = (dataSource as Stream).transform(_cache());
  }

  /// Caches the response data stream to enable multiple accesses.
  StreamTransformer<Object, Object> _cache() =>
      new StreamTransformer<Object, Object>(
          (Stream<Object> input, bool cancelOnError) {
        StreamController<Object> controller;
        StreamSubscription<Object> subscription;
        controller = new StreamController<Object>(onListen: () {
          _isCached = true;
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
}
