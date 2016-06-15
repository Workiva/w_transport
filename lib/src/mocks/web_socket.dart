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
typedef Future<WSocket> WSocketPatternConnectHandler(Uri uri,
    {Iterable<String> protocols, Map<String, dynamic> headers, Match match});

List<_WebSocketConnectExpectation> _expectations = [];
Map<String, WSocketConnectHandler> _handlers = {};
Map<Pattern, WSocketPatternConnectHandler> _patternHandlers = {};

Future<WSocket> handleWebSocketConnection(Uri uri,
    {Iterable<String> protocols, Map<String, dynamic> headers}) async {
  Iterable matchingExpectations = _expectations.where((e) {
    if (e.uri is Uri) {
      return e.uri == uri;
    } else if (e.uri is Pattern) {
      return (e.uri as Pattern).allMatches(uri.toString()).isNotEmpty;
    }
  });
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

  Match match;
  var matchingHandlerKey = _patternHandlers.keys.firstWhere((uriPattern) {
    var matches = uriPattern.allMatches(uri.toString());
    if (matches.isNotEmpty) {
      match = matches.first;
      return true;
    }
    return false;
  }, orElse: () => null);

  if (matchingHandlerKey != null) {
    /// The uri matched the pattern specified by this handler.
    return _patternHandlers[matchingHandlerKey](uri,
        protocols: protocols, headers: headers, match: match);
  }

  throw new StateError('Unexpected WSocket connection: $uri');
}

class MockWebSocket {
  const MockWebSocket();

  void expect(Uri uri, {MockWSocket connectTo, bool reject}) {
    _expect(uri, connectTo: connectTo, reject: reject);
  }

  void expectPattern(Pattern uriPattern, {MockWSocket connectTo, bool reject}) {
    _expect(uriPattern, connectTo: connectTo, reject: reject);
  }

  void reset() {
    _expectations = [];
    _handlers = {};
    _patternHandlers = {};
  }

  void when(Uri uri, {WSocketConnectHandler handler, bool reject}) {
    _validateWhenParams(handler: handler, reject: reject);
    if (reject != null && reject) {
      _handlers[uri.toString()] = (uri, {protocols, headers}) {
        throw new WSocketException('Mock connection to $uri rejected.');
      };
    } else {
      _handlers[uri.toString()] = handler;
    }
  }

  void whenPattern(Pattern uriPattern,
      {WSocketPatternConnectHandler handler, bool reject}) {
    _validateWhenParams(handler: handler, reject: reject);
    if (reject != null && reject) {
      _patternHandlers[uriPattern] = (uri, {protocols, headers, match}) {
        throw new WSocketException('Mock connection to $uri rejected.');
      };
    } else {
      _patternHandlers[uriPattern] = handler;
    }
  }

  void _expect(dynamic uri, {MockWSocket connectTo, bool reject}) {
    if (connectTo != null && reject != null) {
      throw new ArgumentError('Use connectTo OR reject, but not both.');
    }
    if (connectTo == null && reject == null) {
      throw new ArgumentError('Either connectTo OR reject must be set.');
    }
    _expectations.add(new _WebSocketConnectExpectation(uri,
        connectTo: connectTo, reject: reject));
  }

  void _validateWhenParams({WSocketConnectHandler handler, bool reject}) {
    if (handler != null && reject != null) {
      throw new ArgumentError('Use handler OR reject, but not both.');
    }
    if (handler == null && reject == null) {
      throw new ArgumentError('Either handler OR reject must be set.');
    }
  }
}

class _WebSocketConnectExpectation {
  WSocket connectTo;
  bool reject;
  final dynamic uri;

  _WebSocketConnectExpectation(this.uri, {this.connectTo, this.reject});
}
