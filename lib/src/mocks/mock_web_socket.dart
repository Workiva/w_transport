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

typedef Future<dynamic /*WSocket|MockWebSocketServer*/ > WebSocketConnectHandler(
    Uri uri,
    {Map<String, dynamic> headers,
    Iterable<String> protocols});
typedef Future<dynamic /*WSocket|MockWebSocketServer*/ > WebSocketPatternConnectHandler(
    Uri uri,
    {Map<String, dynamic> headers,
    Match match,
    Iterable<String> protocols});

class MockWebSockets {
  const MockWebSockets();

  void expect(Uri uri,
      {dynamic /*MockWSocket|MockWebSocketServer*/ connectTo, bool reject}) {
    MockWebSocketInternal._expect(uri, connectTo: connectTo, reject: reject);
  }

  void expectPattern(Pattern uriPattern,
      {dynamic /*MockWSocket|MockWebSocketServer*/ connectTo, bool reject}) {
    MockWebSocketInternal._expect(uriPattern,
        connectTo: connectTo, reject: reject);
  }

  void reset() {
    MockWebSocketInternal._expectations = [];
    MockWebSocketInternal._handlers = {};
    MockWebSocketInternal._patternHandlers = {};
  }

  MockWebSocketHandler when(Uri uri,
      {WebSocketConnectHandler handler, bool reject}) {
    MockWebSocketInternal._validateWhenParams(handler: handler, reject: reject);
    if (reject != null && reject) {
      handler = (uri, {protocols, headers}) {
        throw new WebSocketException('Mock connection to $uri rejected.');
      };
    }
    MockWebSocketInternal._handlers[uri.toString()] = handler;

    return new MockWebSocketHandler._(() {
      final currentHandler = MockWebSocketInternal._handlers[uri.toString()];
      if (currentHandler != null && currentHandler == handler) {
        MockWebSocketInternal._handlers.remove(uri.toString());
      }
    });
  }

  MockWebSocketHandler whenPattern(Pattern uriPattern,
      {WebSocketPatternConnectHandler handler, bool reject}) {
    MockWebSocketInternal._validateWhenParams(handler: handler, reject: reject);
    if (reject == true) {
      handler = (uri, {protocols, headers, match}) {
        throw new WebSocketException('Mock connection to $uri rejected.');
      };
    }
    MockWebSocketInternal._patternHandlers[uriPattern] = handler;

    return new MockWebSocketHandler._(() {
      final currentHandler = MockWebSocketInternal._patternHandlers[uriPattern];
      if (currentHandler != null && currentHandler == handler) {
        MockWebSocketInternal._patternHandlers.remove(uriPattern);
      }
    });
  }
}

class MockWebSocketHandler {
  Function _cancel;
  MockWebSocketHandler._(this._cancel);

  void cancel() {
    _cancel();
  }
}

class MockWebSocketInternal {
  static List<_WebSocketConnectExpectation> _expectations = [];
  static Map<String, WebSocketConnectHandler> _handlers = {};
  static Map<Pattern, WebSocketPatternConnectHandler> _patternHandlers = {};

  static Future<WebSocket> handleWebSocketConnection(Uri uri,
      {Map<String, dynamic> headers, Iterable<String> protocols}) async {
    final matchingExpectations = _getMatchingExpectations(uri);
    if (matchingExpectations.isNotEmpty) {
      // If this connection was expected, resolve it as planned.
      _WebSocketConnectExpectation expectation = matchingExpectations.first;
      _expectations.remove(expectation);
      if (expectation.reject != null && expectation.reject) {
        throw new WebSocketException('Mock connection to $uri rejected.');
      }

      // For backwards compatibility, it is still allowed to pass in a `WSocket`
      // instance for the `connectTo` param. If that happens, return it here and
      // it should function as expected.
      // ignore: deprecated_member_use
      if (expectation.connectTo is WSocket) return expectation.connectTo;

      // The new behavior is to pass in a `MockWebSocketServer` for the
      // `connectTo` param. When this is done, we have to create a mock
      // `WebSocket` instance, return it, and notify the mock server that this
      // new client has connected.
      // ignore: deprecated_member_use
      final mockWebSocket = new MockWSocket();
      MockWebSocketServer mockWebSocketServer = expectation.connectTo;
      mockWebSocketServer._connectClient(mockWebSocket, uri,
          headers: headers, protocols: protocols);
      return mockWebSocket;
    }

    final handlerMatch = _getMatchingHandler(uri);
    if (handlerMatch != null) {
      // If a handler was set up for this type of connection, call the handler.
      dynamic result;
      if (handlerMatch.handler is WebSocketPatternConnectHandler) {
        result = handlerMatch.handler(uri,
            headers: headers, match: handlerMatch.match, protocols: protocols);
      } else {
        result =
            handlerMatch.handler(uri, headers: headers, protocols: protocols);
      }

      if (result is Future) {
        result = await result;
      }
      // ignore: deprecated_member_use
      if (result is! WSocket && result is! MockWebSocketServer) {
        throw new ArgumentError('Mock WebSocket handlers must return an '
            'instance of MockWSocket or MockWebSocketServer.');
      }

      // For backwards compatibility, it is still allowed to return a `WSocket`
      // instance from the handler. If that happens, return it here and it
      // should function as expected.
      // ignore: deprecated_member_use
      if (result is WSocket) return result;

      // The new behavior is to return a `MockWebSocketServer` from the handler.
      // When this is done, we have to create a mock `WebSocket` instance,
      // return it, and notify the mock server that this new client has
      // connected.
      // ignore: deprecated_member_use
      final mockWebSocket = new MockWSocket();
      MockWebSocketServer mockWebSocketServer = result;
      mockWebSocketServer._connectClient(mockWebSocket, uri,
          headers: headers, protocols: protocols);
      return mockWebSocket;
    }

    return null;
  }

  static bool hasHandlerForWebSocket(Uri uri) {
    if (_getMatchingExpectations(uri).isNotEmpty) return true;
    if (_getMatchingHandler(uri) != null) return true;
    return false;
  }

  static void _expect(Object uri,
      {dynamic /*MockWSocket|MockWebSocketServer*/ connectTo, bool reject}) {
    if (connectTo != null && reject != null) {
      throw new ArgumentError('Use connectTo OR reject, but not both.');
    }
    if (connectTo == null && reject == null) {
      throw new ArgumentError('Either connectTo OR reject must be set.');
    }
    if (connectTo != null &&
        // ignore: deprecated_member_use
        connectTo is! MockWSocket &&
        connectTo is! MockWebSocketServer) {
      throw new ArgumentError(
          'connectTo must be an MockWSocket instance or a MockWebSocketServer instance.');
    }
    _expectations.add(new _WebSocketConnectExpectation(uri,
        connectTo: connectTo, reject: reject));
  }

  static Iterable<_WebSocketConnectExpectation> _getMatchingExpectations(
      Uri uri) {
    return _expectations.where((e) {
      if (e.uri is Uri) {
        return e.uri == uri;
      } else if (e.uri is Pattern) {
        final Pattern pattern = e.uri;
        return pattern.allMatches(uri.toString()).isNotEmpty;
      }
    });
  }

  static _WebSocketHandlerMatch _getMatchingHandler(Uri uri) {
    if (_handlers.containsKey(uri.toString())) {
      return new _WebSocketHandlerMatch(_handlers[uri.toString()]);
    }

    Match match;
    final matchingHandlerKey = _patternHandlers.keys.firstWhere((uriPattern) {
      final matches = uriPattern.allMatches(uri.toString());
      if (matches.isNotEmpty) {
        match = matches.first;
        return true;
      }
      return false;
    }, orElse: () => null);

    if (matchingHandlerKey != null) {
      return new _WebSocketHandlerMatch(_patternHandlers[matchingHandlerKey],
          match: match);
    }

    return null;
  }

  static void _validateWhenParams({dynamic handler, bool reject}) {
    if (handler != null && reject != null) {
      throw new ArgumentError('Use handler OR reject, but not both.');
    }
    if (handler == null && reject == null) {
      throw new ArgumentError('Either handler OR reject must be set.');
    }
  }
}

class _WebSocketConnectExpectation {
  dynamic /*MockWSocket|MockWebSocketServer*/ connectTo;
  bool reject;
  final Object uri;

  _WebSocketConnectExpectation(this.uri, {this.connectTo, this.reject});
}

class _WebSocketHandlerMatch {
  final Object handler;
  final Match match;

  _WebSocketHandlerMatch(this.handler, {this.match});
}
