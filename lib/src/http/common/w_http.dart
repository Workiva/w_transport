library w_transport.src.http.common.w_http;

class CommonWHttp {
  /// HTTP client used to create and send HTTP requests.
  /// In the browser, this will be unnecessary.
  /// On the server, this will be an instance of [HttpClient].
  dynamic client;

  /// Whether or not this HTTP client has been closed.
  bool isClosed = false;

  /// Closes the client, cancelling or closing any outstanding connections.
  void close() {
    if (isClosed) return;
    isClosed = true;
    if (client != null) {
      client.close();
    }
  }

  /// Throws a [StateError] if this client has been closed.
  void verifyNotClosed() {
    if (isClosed) throw new StateError(
        'WHttp client has been closed, can\'t create a new request.');
  }
}
