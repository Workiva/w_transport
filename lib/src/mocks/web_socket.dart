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

library w_transport.src.mocks.web_socket;

import 'dart:async';

import 'package:w_transport/src/web_socket/mock/w_socket.dart';
import 'package:w_transport/src/web_socket/w_socket.dart';
import 'package:w_transport/src/web_socket/w_socket_exception.dart';

typedef Future<WSocket> WSocketConnectHandler(Uri uri,
    {Iterable<String> protocols, Map<String, dynamic> headers});

List<_WebSocketConnectExpectation> _expectations = [];
Map<String, WSocketConnectHandler> _handlers = {};

Future<WSocket> handleWebSocketConnection(Uri uri,
    {Iterable<String> protocols, Map<String, dynamic> headers}) async {
  Iterable matchingExpectations = _expectations.where((e) => e.uri == uri);
  if (matchingExpectations.isNotEmpty) {
    /// If this connection was expected, resolve it as planned.
    _WebSocketConnectExpectation expectation = matchingExpectations.first;
    _expectations.remove(expectation);
    if (expectation.reject != null && expectation.reject)
      throw new WSocketException('Mock connection to $uri rejected.');
    return expectation.connectTo;
  }

  if (_handlers.containsKey(uri.toString())) {
    /// If a handler was set up for this type of connection, call the handler.
    return _handlers[uri.toString()](uri,
        protocols: protocols, headers: headers);
  }

  throw new StateError('Unexpected WSocket connection: $uri');
}

class MockWebSocket {
  const MockWebSocket();

  void expect(Uri uri, {MockWSocket connectTo, bool reject}) {
    if (connectTo != null && reject != null) {
      throw new ArgumentError('Use connectTo OR reject, but not both.');
    }
    if (connectTo == null && reject == null) {
      throw new ArgumentError('Either connectTo OR reject must be set.');
    }
    _expectations.add(new _WebSocketConnectExpectation(uri,
        connectTo: connectTo, reject: reject));
  }

  void reset() {
    _expectations = [];
    _handlers = {};
  }

  void when(Uri uri, {WSocketConnectHandler handler, bool reject}) {
    if (handler != null && reject != null) {
      throw new ArgumentError('Use handler OR reject, but not both.');
    }
    if (handler == null && reject == null) {
      throw new ArgumentError('Either handler OR reject must be set.');
    }
    if (reject != null && reject) {
      _handlers[uri.toString()] = (uri, {protocols, headers}) {
        throw new WSocketException('Mock connection to $uri rejected.');
      };
    } else {
      _handlers[uri.toString()] = handler;
    }
  }
}

class _WebSocketConnectExpectation {
  WSocket connectTo;
  bool reject;
  final Uri uri;

  _WebSocketConnectExpectation(Uri this.uri,
      {WSocket this.connectTo, bool this.reject});
}
