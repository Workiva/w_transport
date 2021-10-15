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

part of w_transport.src.mocks.mock_transports;

class MockWebSocketConnection {
  final Map<String, dynamic> headers;
  final Iterable<String> protocols;
  final Uri uri;

  final MockWebSocket _connectedClient;

  MockWebSocketConnection._(this._connectedClient, this.uri,
      {Map<String, dynamic> headers, Iterable<String> protocols})
      : headers = Map.unmodifiable(headers ?? {}),
        protocols = List.unmodifiable(protocols ?? []);

  int get closeCode => _connectedClient.closeCode;

  String get closeReason => _connectedClient.closeReason;

  Future<Null> get done => _connectedClient.done;

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
  List<MockWebSocket> _connectedClients = [];

  StreamController<MockWebSocketConnection> _onClientConnected =
      StreamController<MockWebSocketConnection>();

  Stream<MockWebSocketConnection> get onClientConnected =>
      _onClientConnected.stream;

  Future<Null> shutDown() async {
    final futures = _connectedClients.map((client) => client.close());
    await Future.wait(futures);
  }

  void _connectClient(MockWebSocket client, Uri uri,
      {Map<String, dynamic> headers, Iterable<String> protocols}) {
    _connectedClients.add(client);
    client.done.then((_) {
      _connectedClients.remove(client);
    }).catchError((_) {
      _connectedClients.remove(client);
    });
    _onClientConnected.add(MockWebSocketConnection._(client, uri,
        headers: headers, protocols: protocols));
  }
}
