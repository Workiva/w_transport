part of w_transport.src.mocks.mock_w_response;

abstract class WResponseSource implements WResponse {
  final Map<String, String> headers;
  final int status;
  final String statusText;
  bool _cached = false;
  List<Object> _cachedResponse = [];
  Encoding _encoding;
  Stream _source;

  WResponseSource(this._source, this.status, this.statusText, this.headers);

  Future<Object> asFuture() => _getFuture();
  Stream asStream() => _getStream();
  Future<String> asText() => _getText();

  void update(dynamic dataSource) {
    if (dataSource is! Stream) {
      dataSource = new Stream.fromIterable([dataSource]);
    }
    _cached = false;
    _cachedResponse = [];
    _source = (dataSource as Stream).transform(_cache());
  }

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

  Future<Object> _getFuture();

  Stream _getStream() =>
      _cached ? new Stream.fromIterable(_cachedResponse) : _source;

  Future<String> _getText();
}
