part of w_transport.src.mocks.mock_w_request;

abstract class WRequestSource extends Object with FluriMixin
    implements WRequest {
  int contentLength;
  Object data;
  Encoding encoding = UTF8;
  Map<String, String> headers = {};
  bool withCredentials = false;
  Object _cancellationError;
  bool _canceled = false;
  dynamic _client;
  Function _configure;
  Object _data;
  StreamController<WProgress> _downloadProgressController =
      new StreamController<WProgress>();
  String _method;
  dynamic _request;
  StreamController<WProgress> _uploadProgressController =
      new StreamController<WProgress>();
  bool _single;

  WRequestSource()
      : super(),
        _single = true;

  Stream<WProgress> get downloadProgress => _downloadProgressController.stream;
  String get method => _method;
  Stream<WProgress> get uploadProgress => _uploadProgressController.stream;

  void abort([Object error]) {
    if (_request != null) {
      _abortRequest(_request);
    }
    _canceled = true;
    _cancellationError = error;
  }

  void configure(configure(request)) {
    _configure = configure;
  }

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

  void _abortRequest(request);

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

  Future<WResponse> _getResponse();

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
    _validateData();
    _checkForCancellation();
    return _getResponse();
  }

  void _validateData();
}
