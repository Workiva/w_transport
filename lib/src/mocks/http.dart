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
typedef Future<BaseResponse> PatternRequestHandler(
    FinalizedRequest request, Match match);

List<_RequestExpectation> _expectations = [];
Map<String, Map<String, RequestHandler>> _requestHandlers = {};
Map<Pattern, Map<String, PatternRequestHandler>> _patternRequestHandlers = {};
List<MockBaseRequest> _pending = [];

void cancelMockRequest(MockBaseRequest request) {
  if (_pending.contains(request)) {
    _pending.remove(request);
  }
}

handleMockRequest(MockBaseRequest request) {
  var matchingExpectations = _expectations.where((e) {
    bool methodMatches = e.method == request.method;
    bool uriMatches = false;
    if (e.uri is Uri) {
      uriMatches = e.uri == request.uri;
    } else if (e.uri is Pattern) {
      uriMatches =
          (e.uri as Pattern).allMatches(request.uri.toString()).isNotEmpty;
    }
    bool headersMatch;
    if (e.headers == null) {
      // Ignore headers check if expectation didn't specify.
      headersMatch = true;
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

  var matchingRequestHandlerKey = _requestHandlers.keys.firstWhere((key) {
    return key == _getUriKey(request.uri);
  }, orElse: () => null);

  Match match;
  var matchingPatternRequestHandlerKey =
      _patternRequestHandlers.keys.firstWhere((pattern) {
    var matches = pattern.allMatches(request.uri.toString());
    if (matches.isNotEmpty) {
      match = matches.first;
      return true;
    }
    return false;
  }, orElse: () => null);

  var handlersByMethod = [];
  if (matchingRequestHandlerKey != null) {
    handlersByMethod = _requestHandlers[matchingRequestHandlerKey];
  } else if (matchingPatternRequestHandlerKey != null) {
    handlersByMethod =
        _patternRequestHandlers[matchingPatternRequestHandlerKey];
  }

  if (handlersByMethod.isNotEmpty) {
    /// Try to find an applicable handler.
    var handler;
    if (handlersByMethod.containsKey(request.method)) {
      handler = handlersByMethod[request.method];
    } else if (handlersByMethod.containsKey('*')) {
      handler = handlersByMethod['*'];
    }

    /// If a handler was set up for this type of request, call the handler.
    if (handler != null) {
      if (handler is RequestHandler) {
        request.onSent.then((FinalizedRequest finalizedRequest) {
          handler(finalizedRequest).then((response) {
            request.complete(response: response);
          }, onError: (error) {
            request.completeError(error: error);
          });
        });
        return;
      } else if (handler is PatternRequestHandler) {
        request.onSent.then((FinalizedRequest finalizedRequest) {
          handler(finalizedRequest, match).then((response) {
            request.complete(response: response);
          }, onError: (error) {
            request.completeError(error: error);
          });
        });
        return;
      }
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
    _expect(method, uri,
        failWith: failWith, headers: headers, respondWith: respondWith);
  }

  void expectPattern(String method, Pattern uriPattern,
      {Object failWith,
      Map<String, String> headers,
      BaseResponse respondWith}) {
    _expect(method, uriPattern,
        failWith: failWith, headers: headers, respondWith: respondWith);
  }

  void failRequest(BaseRequest request, {Object error, BaseResponse response}) {
    _verifyRequestIsMock(request);
    (request as MockBaseRequest)
        .completeError(error: error, response: response);
    _pending.remove(request);
  }

  void reset() {
    _expectations = [];
    _requestHandlers = {};
    _patternRequestHandlers = {};
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
    // Note: there's really no reason to use `_getUriKey()` here - it strips the
    // fragment and query from the uri, but neither of those pieces of info are
    // used anywhere else. The consumer should just be expected to pass in an
    // exact match here. At the next breaking release, this method and related
    // ones should be cleaned up & clarified.
    String uriKey = _getUriKey(uri);
    if (!_requestHandlers.containsKey(uriKey)) {
      _requestHandlers[uriKey] = {};
    }
    if (method == null) {
      _requestHandlers[uriKey]['*'] = handler;
    } else {
      _requestHandlers[uriKey][method.toUpperCase()] = handler;
    }
  }

  void whenPattern(Pattern uriPattern, PatternRequestHandler handler,
      {String method}) {
    if (!_patternRequestHandlers.containsKey(uriPattern)) {
      _patternRequestHandlers[uriPattern] = {};
    }
    if (method == null) {
      _patternRequestHandlers[uriPattern]['*'] = handler;
    } else {
      _patternRequestHandlers[uriPattern][method.toUpperCase()] = handler;
    }
  }

  void _expect(String method, dynamic uri,
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
  final dynamic uri;

  _RequestExpectation(this.method, this.uri, this.headers,
      {this.failWith, this.respondWith});
}
