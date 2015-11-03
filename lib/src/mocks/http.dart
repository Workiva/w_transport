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

import 'package:http_parser/http_parser.dart' show CaseInsensitiveMap;
import 'package:w_transport/w_transport.dart';

import 'package:w_transport/src/http/finalized_request.dart';
import 'package:w_transport/src/http/mock/base_request.dart';
import 'package:w_transport/src/http/mock/response.dart';
import 'package:w_transport/src/http/response.dart';

typedef Future<BaseResponse> RequestHandler(FinalizedRequest request);

List<_RequestExpectation> _expectations = [];
Map<String, Map<String, RequestHandler>> _handlers = {};
List<MockBaseRequest> _pending = [];

void cancelMockRequest(MockBaseRequest request) {
  if (_pending.contains(request)) {
    _pending.remove(request);
  }
}

handleMockRequest(MockBaseRequest request) {
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
      headersMatch = true;
      e.headers.forEach((header, value) {
        if (!request.headers.containsKey(header) ||
            request.headers[header] != value) {
          headersMatch = false;
        }
      });
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
      request.onSent.then((FinalizedRequest finalizedRequest) {
        handler(finalizedRequest).then((response) {
          request.complete(response: response);
        }, onError: (error) {
          request.completeError(error: error);
        });
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

  void causeFailureOnOpen(BaseRequest request) {
    _verifyRequestIsMock(request);
    (request as MockBaseRequest).causeFailureOnOpen();
  }

  void completeRequest(BaseRequest request, {BaseResponse response}) {
    _verifyRequestIsMock(request);
    (request as MockBaseRequest).complete(response: response);
    _pending.remove(request);
  }

  void expect(String method, Uri uri,
      {Object failWith,
      Map<String, String> headers,
      BaseResponse respondWith}) {
    if (failWith != null && respondWith != null) {
      throw new ArgumentError('Use failWith OR respondWith, but not both.');
    }
    if (failWith == null && respondWith == null) {
      respondWith = new MockResponse.ok();
    }
    _expectations.add(new _RequestExpectation(method, uri,
        headers == null ? null : new CaseInsensitiveMap.from(headers),
        failWith: failWith, respondWith: respondWith));
  }

  void failRequest(BaseRequest request, {Object error, BaseResponse response}) {
    _verifyRequestIsMock(request);
    (request as MockBaseRequest)
        .completeError(error: error, response: response);
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

  void when(Uri uri, RequestHandler handler, {String method}) {
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

  void _verifyRequestIsMock(BaseRequest request) {
    if (request is! MockBaseRequest) {
      throw new ArgumentError.value(
          'Request must be of type MockBaseRequest. Make sure you configured w_transport for testing.');
    }
  }
}

class _RequestExpectation {
  Object failWith;
  final Map<String, String> headers;
  final String method;
  BaseResponse respondWith;
  final Uri uri;

  _RequestExpectation(
      String this.method, Uri this.uri, Map<String, String> this.headers,
      {Object this.failWith, BaseResponse this.respondWith});
}
