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

library w_transport.src.mocks.http;

import 'dart:async';

import 'package:collection/equality.dart' as equality;
import 'package:http_parser/http_parser.dart' show CaseInsensitiveMap;
import 'package:w_transport/src/http/mock/w_request.dart';
import 'package:w_transport/src/http/mock/w_response.dart';

import 'package:w_transport/src/http/w_response.dart';
import 'package:w_transport/src/http/w_request.dart';

typedef Future<WResponse> WRequestHandler(WRequest request);

List<_RequestExpectation> _expectations = [];
Map<String, Map<String, WRequestHandler>> _handlers = {};
List<WRequest> _pending = [];

void cancelMockRequest(MockWRequest request) {
  if (_pending.contains(request)) {
    _pending.remove(request);
  }
}

handleMockRequest(MockWRequest request) {
  var mapEquality = new equality.MapEquality();

  Iterable matchingExpectations = _expectations.where((e) {
    bool methodMatches = e.method == request.method;
    bool uriMatches = e.uri == request.uri;
    bool headersMatch;
    if (e.headers == null) {
      // Ignore headers check if expectation didn't specify.
      headersMatch = true;
    } else if (e.headers.isEmpty) {
      headersMatch = request.headers.isEmpty;
    } else {
      headersMatch = mapEquality.equals(e.headers, request.headers);
    }
    return methodMatches && uriMatches && headersMatch;
  });

  if (matchingExpectations.isNotEmpty) {
    /// If this request was expected, resolve it as planned.
    _RequestExpectation expectation = matchingExpectations.first;
    if (expectation.failWith != null) {
      request.completeError(error: expectation.failWith);
    } else if (expectation.respondWith != null) {
      request.complete(response: expectation.respondWith);
    }
    _expectations.remove(expectation);
    return;
  }

  if (_handlers.containsKey(_getUriKey(request.uri))) {
    var reqHandlers = _handlers[_getUriKey(request.uri)];

    /// Try to find an applicable handler.
    var handler;
    if (reqHandlers.containsKey(request.method)) {
      handler = reqHandlers[request.method];
    } else if (reqHandlers.containsKey('*')) {
      handler = reqHandlers['*'];
    }

    /// If a handler was set up for this type of request, call the handler.
    if (handler != null) {
      handler(request).then((response) {
        request.complete(response: response);
      }, onError: (error) {
        request.completeError(error: error);
      });
      return;
    }
  }

  /// Otherwise, store this request as pending.
  _pending.add(request);
}

String _getUriKey(Uri uri) => uri.replace(query: '', fragment: '').toString();

class MockHttp {
  const MockHttp();

  int get numPendingRequests => _pending.length;

  void causeFailureOnOpen(WRequest request) {
    _verifyRequestIsMock(request);
    (request as MockWRequest).causeFailureOnOpen();
  }

  void completeRequest(WRequest request, {WResponse response}) {
    _verifyRequestIsMock(request);
    (request as MockWRequest).complete(response: response);
    _pending.remove(request);
  }

  void expect(String method, Uri uri,
      {Object failWith, Map<String, String> headers, WResponse respondWith}) {
    if (failWith != null && respondWith != null) {
      throw new ArgumentError('Use failWith OR respondWith, but not both.');
    }
    if (failWith == null && respondWith == null) {
      respondWith = new MockWResponse.ok();
    }
    _expectations.add(new _RequestExpectation(method, uri,
        headers == null ? null : new CaseInsensitiveMap.from(headers),
        failWith: failWith, respondWith: respondWith));
  }

  void failRequest(WRequest request, {Object error, WResponse response}) {
    _verifyRequestIsMock(request);
    (request as MockWRequest).completeError(error: error, response: response);
    _pending.remove(request);
  }

  void reset() {
    _expectations = [];
    _handlers = {};
    _pending = [];
  }

  void verifyNoOutstandingExceptions() {
    String errorMsg = '';
    if (_pending.isNotEmpty) {
      errorMsg += 'Unresolved mock requests:\n';
      var requestLines = _pending.map((e) => '\t${e.method} ${e.uri}');
      errorMsg += requestLines.join('\n');
      errorMsg += '\n';
    }
    if (_expectations.isNotEmpty) {
      errorMsg += 'Unsatisfied requests:\n';
      var requestLines = _expectations.map((e) => '\t${e.method} ${e.uri}');
      errorMsg += requestLines.join('\n');
      errorMsg += '\n';
    }
    if (errorMsg.isNotEmpty) throw new StateError(errorMsg);
  }

  void when(Uri uri, WRequestHandler handler, {String method}) {
    String uriKey = _getUriKey(uri);
    if (!_handlers.containsKey(uriKey)) {
      _handlers[uriKey] = {};
    }
    if (method == null) {
      _handlers[uriKey]['*'] = handler;
    } else {
      _handlers[uriKey][method.toUpperCase()] = handler;
    }
  }

  void _verifyRequestIsMock(WRequest request) {
    if (request is! MockWRequest) {
      throw new ArgumentError.value(
          'Request must be of type MockWRequest. Make sure you configured w_transport for mocking.');
    }
  }
}

class _RequestExpectation {
  Object failWith;
  final Map<String, String> headers;
  final String method;
  WResponse respondWith;
  final Uri uri;

  _RequestExpectation(
      String this.method, Uri this.uri, Map<String, String> this.headers,
      {Object this.failWith, WResponse this.respondWith});
}
