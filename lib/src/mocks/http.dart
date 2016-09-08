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

class MockHttp {
  const MockHttp();

  int get numPendingRequests => MockHttpInternal._pending.length;

  void causeFailureOnOpen(BaseRequest request) {
    MockHttpInternal._verifyRequestIsMock(request);
    (request as MockBaseRequest).causeFailureOnOpen();
  }

  void completeRequest(BaseRequest request, {BaseResponse response}) {
    MockHttpInternal._verifyRequestIsMock(request);
    (request as MockBaseRequest).complete(response: response);
    MockHttpInternal._pending.remove(request);
  }

  void expect(String method, Uri uri,
      {Object failWith,
      Map<String, String> headers,
      BaseResponse respondWith}) {
    MockHttpInternal._expect(method, uri,
        failWith: failWith, headers: headers, respondWith: respondWith);
  }

  void expectPattern(String method, Pattern uriPattern,
      {Object failWith,
      Map<String, String> headers,
      BaseResponse respondWith}) {
    MockHttpInternal._expect(method, uriPattern,
        failWith: failWith, headers: headers, respondWith: respondWith);
  }

  void failRequest(BaseRequest request, {Object error, BaseResponse response}) {
    MockHttpInternal._verifyRequestIsMock(request);
    (request as MockBaseRequest)
        .completeError(error: error, response: response);
    MockHttpInternal._pending.remove(request);
  }

  void reset() {
    MockHttpInternal._expectations = [];
    MockHttpInternal._patternRequestHandlers = {};
    MockHttpInternal._pending = [];
    MockHttpInternal._requestHandlers = {};
  }

  void verifyNoOutstandingExceptions() {
    String errorMsg = '';
    if (MockHttpInternal._pending.isNotEmpty) {
      errorMsg += 'Unresolved mock requests:\n';
      var requestLines =
          MockHttpInternal._pending.map((e) => '\t${e.method} ${e.uri}');
      errorMsg += requestLines.join('\n');
      errorMsg += '\n';
    }
    if (MockHttpInternal._expectations.isNotEmpty) {
      errorMsg += 'Unsatisfied requests:\n';
      var requestLines =
          MockHttpInternal._expectations.map((e) => '\t${e.method} ${e.uri}');
      errorMsg += requestLines.join('\n');
      errorMsg += '\n';
    }
    if (errorMsg.isNotEmpty) throw new StateError(errorMsg);
  }

  MockHttpHandler when(Uri uri, RequestHandler handler, {String method}) {
    // Note: there's really no reason to use `_getUriKey()` here - it strips the
    // fragment and query from the uri, but neither of those pieces of info are
    // used anywhere else. The consumer should just be expected to pass in an
    // exact match here. At the next breaking release, this method and related
    // ones should be cleaned up & clarified.
    String uriKey = MockHttpInternal._getUriKey(uri);
    if (!MockHttpInternal._requestHandlers.containsKey(uriKey)) {
      MockHttpInternal._requestHandlers[uriKey] = {};
    }
    var methodKey = method == null ? '*' : method.toUpperCase();
    MockHttpInternal._requestHandlers[uriKey][methodKey] = handler;
    return new MockHttpHandler._(() {
      var handlers = MockHttpInternal._requestHandlers[uriKey];
      if (handlers != null &&
          handlers[methodKey] != null &&
          handlers[methodKey] == handler) {
        MockHttpInternal._requestHandlers[uriKey].remove(methodKey);
      }
    });
  }

  MockHttpHandler whenPattern(Pattern uriPattern, PatternRequestHandler handler,
      {String method}) {
    if (!MockHttpInternal._patternRequestHandlers.containsKey(uriPattern)) {
      MockHttpInternal._patternRequestHandlers[uriPattern] = {};
    }
    var methodKey = method == null ? '*' : method.toUpperCase();
    MockHttpInternal._patternRequestHandlers[uriPattern][methodKey] = handler;
    return new MockHttpHandler._(() {
      var handlers = MockHttpInternal._patternRequestHandlers[uriPattern];
      if (handlers != null &&
          handlers[methodKey] != null &&
          handlers[methodKey] == handler) {
        MockHttpInternal._patternRequestHandlers[uriPattern].remove(methodKey);
      }
    });
  }
}

class MockHttpHandler {
  Function _cancel;
  MockHttpHandler._(this._cancel);

  void cancel() {
    _cancel();
  }
}

class MockHttpInternal {
  static List<_RequestExpectation> _expectations = [];
  static Map<String, Map<String, RequestHandler>> _requestHandlers = {};
  static Map<Pattern, Map<String, PatternRequestHandler>>
      _patternRequestHandlers = {};
  static List<MockBaseRequest> _pending = [];

  static void cancelMockRequest(MockBaseRequest request) {
    if (_pending.contains(request)) {
      _pending.remove(request);
    }
  }

  static void handleMockRequest(MockBaseRequest request) {
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

    var handlersByMethod = <String, dynamic>{};
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

  static void _expect(String method, dynamic uri,
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

  // TODO: remove in 3.0.0
  static String _getUriKey(Uri uri) =>
      uri.replace(query: '', fragment: '').toString();

  static void _verifyRequestIsMock(BaseRequest request) {
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
