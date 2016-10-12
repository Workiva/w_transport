part of w_transport.src.mocks.mock_transports;

class MockWebSocketConnection {
  final Map<String, dynamic> headers;
  final Iterable<String> protocols;
  final Uri uri;

  final MockWSocket _connectedClient;

  MockWebSocketConnection._(this._connectedClient, this.uri,
      {Map<String, dynamic> headers, Iterable<String> protocols})
      : headers = new Map.unmodifiable(headers ?? {}),
        protocols = new List.unmodifiable(protocols ?? []);

  Future<Null> close([int code, String reason]) {
    return _connectedClient.close(code, reason);
  }

  void onData(callback(dynamic data)) {
    _connectedClient.onOutgoing(callback);
  }

  void send(Object data) {
    _connectedClient.addIncoming(data);
  }
}

class MockWebSocketServer {
  List<MockWSocket> _connectedClients = [];

  StreamController<MockWebSocketConnection> _onClientConnected =
      new StreamController<MockWebSocketConnection>();

  Stream<MockWebSocketConnection> get onClientConnected =>
      _onClientConnected.stream;

  Future<Null> shutDown() async {
    final futures = _connectedClients.map((client) => client.close());
    await Future.wait(futures);
  }

  void _connectClient(MockWSocket client, Uri uri,
      {Map<String, dynamic> headers, Iterable<String> protocols}) {
    _connectedClients.add(client);
    client.done.then((_) {
      _connectedClients.remove(client);
    }).catchError((_) {
      _connectedClients.remove(client);
    });
    _onClientConnected.add(new MockWebSocketConnection._(client, uri,
        headers: headers, protocols: protocols));
  }
}
