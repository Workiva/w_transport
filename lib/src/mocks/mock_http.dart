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

typedef RequestHandler = Future<BaseResponse> Function(
    FinalizedRequest request);
typedef PatternRequestHandler = Future<BaseResponse> Function(
    FinalizedRequest request, Match match);

class MockHttp {
  const MockHttp();

  int get numPendingRequests => MockHttpInternal._pending.length;

  void causeFailureOnOpen(BaseRequest request) {
    MockHttpInternal._verifyRequestIsMock(request);
    // ignore: deprecated_member_use_from_same_package
    final MockBaseRequest mockRequest = request;
    mockRequest.causeFailureOnOpen();
  }

  @Deprecated(v3Deprecation)
  void completeRequest(BaseRequest request, {BaseResponse response}) {
    MockHttpInternal._verifyRequestIsMock(request);
    final MockBaseRequest mockRequest = request;
    mockRequest.complete(response: response);
    mockRequest.done.then((_) {
      MockHttpInternal._pending.remove(request);
    });
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

  @Deprecated(v3Deprecation)
  void failRequest(BaseRequest request, {Object error, BaseResponse response}) {
    MockHttpInternal._verifyRequestIsMock(request);
    final MockBaseRequest mockRequest = request;
    mockRequest.completeError(error: error, response: response);
    mockRequest.done.catchError((_) {}).then((_) {
      MockHttpInternal._pending.remove(request);
    });
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
      final requestLines =
          MockHttpInternal._pending.map((e) => '\t${e.method} ${e.uri}');
      errorMsg += requestLines.join('\n');
      errorMsg += '\n';
    }
    if (MockHttpInternal._expectations.isNotEmpty) {
      errorMsg += 'Unsatisfied requests:\n';
      final requestLines =
          MockHttpInternal._expectations.map((e) => '\t${e.method} ${e.uri}');
      errorMsg += requestLines.join('\n');
      errorMsg += '\n';
    }
    if (errorMsg.isNotEmpty) throw StateError(errorMsg);
  }

  MockHttpHandler when(Uri uri, RequestHandler handler, {String method}) {
    if (!MockHttpInternal._requestHandlers.containsKey(uri)) {
      MockHttpInternal._requestHandlers[uri] = {};
    }
    final methodKey = method == null ? '*' : method.toUpperCase();
    MockHttpInternal._requestHandlers[uri][methodKey] = handler;
    return MockHttpHandler._(() {
      final handlers = MockHttpInternal._requestHandlers[uri];
      if (handlers != null &&
          handlers[methodKey] != null &&
          handlers[methodKey] == handler) {
        MockHttpInternal._requestHandlers[uri].remove(methodKey);
      }
    });
  }

  MockHttpHandler whenPattern(Pattern uriPattern, PatternRequestHandler handler,
      {String method}) {
    final patternKey = _Pattern(uriPattern);
    if (!MockHttpInternal._patternRequestHandlers.containsKey(patternKey)) {
      MockHttpInternal._patternRequestHandlers[patternKey] = {};
    }
    final methodKey = method == null ? '*' : method.toUpperCase();
    MockHttpInternal._patternRequestHandlers[patternKey][methodKey] = handler;
    return MockHttpHandler._(() {
      final handlers = MockHttpInternal._patternRequestHandlers[patternKey];
      if (handlers != null &&
          handlers[methodKey] != null &&
          handlers[methodKey] == handler) {
        handlers.remove(methodKey);
        if (handlers.isEmpty) {
          MockHttpInternal._patternRequestHandlers.remove(patternKey);
        }
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

// ignore: avoid_classes_with_only_static_members
class MockHttpInternal {
  static List<_RequestExpectation> _expectations = [];
  static Map<Uri, Map<String /* method */, RequestHandler>> _requestHandlers =
      {};
  static Map<_Pattern, Map<String /* method */, PatternRequestHandler>>
      _patternRequestHandlers = {};
  // ignore: deprecated_member_use_from_same_package
  static List<MockBaseRequest> _pending = [];

  // ignore: deprecated_member_use_from_same_package
  static void cancelMockRequest(MockBaseRequest request) {
    _pending.remove(request);
  }

  // ignore: deprecated_member_use_from_same_package
  static void handleMockRequest(MockBaseRequest request) {
    final matchingExpectations =
        _getMatchingExpectations(request.method, request.uri, request.headers);
    if (matchingExpectations.isNotEmpty) {
      // If this request was expected, resolve it as planned.
      _RequestExpectation expectation = matchingExpectations.first;
      if (expectation.failWith != null) {
        request.completeError(error: expectation.failWith);
      } else if (expectation.respondWith != null) {
        request.complete(response: expectation.respondWith);
      }
      _expectations.remove(expectation);
      return;
    }

    final handlerMatch = _getMatchingHandler(request.method, request.uri);
    if (handlerMatch != null) {
      // If a handler was set up for this type of request, call the handler.
      if (handlerMatch.handler is RequestHandler) {
        request.onSent.then((FinalizedRequest finalizedRequest) {
          handlerMatch.handler(finalizedRequest).then((response) {
            request.complete(response: response);
          }, onError: (error) {
            request.completeError(error: error);
          });
        });
        return;
      } else if (handlerMatch.handler is PatternRequestHandler) {
        request.onSent.then((FinalizedRequest finalizedRequest) {
          handlerMatch.handler(finalizedRequest, handlerMatch.match).then(
              (response) {
            request.complete(response: response);
          }, onError: (error) {
            request.completeError(error: error);
          });
        });
        return;
      }
    }

    // Otherwise, store this request as pending.
    _pending.add(request);
  }

  static bool hasHandlerForRequest(
      String method, Uri uri, Map<String, String> headers) {
    if (_getMatchingExpectations(method, uri, headers).isNotEmpty) return true;
    if (_getMatchingHandler(method, uri) != null) return true;
    return false;
  }

  static void _expect(String method, Object uri,
      {Object failWith,
      Map<String, String> headers,
      BaseResponse respondWith}) {
    if (failWith != null && respondWith != null) {
      throw ArgumentError('Use failWith OR respondWith, but not both.');
    }
    if (failWith == null && respondWith == null) {
      respondWith = MockResponse.ok();
    }
    _expectations.add(_RequestExpectation(method, uri,
        headers == null ? null : CaseInsensitiveMap<String>.from(headers),
        failWith: failWith, respondWith: respondWith));
  }

  static Iterable<_RequestExpectation> _getMatchingExpectations(
      String method, Uri uri, Map<String, String> headers) {
    headers = CaseInsensitiveMap<String>.from(headers);

    return _expectations.where((e) {
      final methodMatches = e.method == method;
      bool uriMatches = false;
      if (e.uri is Uri) {
        final Uri expectedUri = e.uri;
        uriMatches = uri == expectedUri;
      } else if (e.uri is Pattern) {
        final Pattern pattern = e.uri;
        uriMatches = pattern.allMatches(uri.toString()).isNotEmpty;
      }
      bool headersMatch;
      if (e.headers == null) {
        // Ignore headers check if expectation didn't specify.
        headersMatch = true;
      } else {
        headersMatch = true;
        e.headers.forEach((header, value) {
          if (!headers.containsKey(header) || headers[header] != value) {
            headersMatch = false;
          }
        });
      }
      return methodMatches && uriMatches && headersMatch;
    });
  }

  static _RequestHandlerMatch _getMatchingHandler(String method, Uri uri) {
    final matchingRequestHandlerKey = _requestHandlers.keys.firstWhere((key) {
      return key == uri;
    }, orElse: () => null);

    Match match;
    final matchingPatternRequestHandlerKey =
        _patternRequestHandlers.keys.firstWhere((pattern) {
      final matches = pattern.allMatches(uri.toString());
      if (matches.isNotEmpty) {
        match = matches.first;
        return true;
      }
      return false;
    }, orElse: () => null);

    Map<String, Object> handlersByMethod;
    if (matchingRequestHandlerKey != null) {
      handlersByMethod = _requestHandlers[matchingRequestHandlerKey];
    } else if (matchingPatternRequestHandlerKey != null) {
      handlersByMethod =
          _patternRequestHandlers[matchingPatternRequestHandlerKey];
    } else {
      handlersByMethod = {};
    }

    Object handler;
    if (handlersByMethod.isNotEmpty) {
      // Try to find an applicable handler.
      if (handlersByMethod.containsKey(method)) {
        handler = handlersByMethod[method];
      } else if (handlersByMethod.containsKey('*')) {
        handler = handlersByMethod['*'];
      }
    }
    if (handler == null) return null;
    return _RequestHandlerMatch(handler,
        match: handler is PatternRequestHandler ? match : null);
  }

  static void _verifyRequestIsMock(BaseRequest request) {
    // ignore: deprecated_member_use_from_same_package
    if (request is! MockBaseRequest) {
      throw ArgumentError.value(
          'Request must be of type MockBaseRequest. Make sure you configured w_transport for testing.');
    }
  }
}

/// An implementation of [Pattern] that ensures 2 [RegExp]s with the same pattern
/// and settings are treated as equal.
///
/// This allows us to store [Pattern]s in the keys of a [Map] with [RegExp]s
/// behaving as a developer might expect. That is, 2 equal [RegExp]s, though
/// perhaps not identical instances, will be interchangeable when used as keys.
class _Pattern implements Pattern {
  final Pattern _pattern;

  _Pattern(this._pattern);

  @override
  Iterable<Match> allMatches(String string, [int start = 0]) =>
      _pattern.allMatches(string, start);

  @override
  Match matchAsPrefix(String string, [int start = 0]) =>
      _pattern.matchAsPrefix(string, start);

  @override
  int get hashCode {
    if (_pattern is RegExp) {
      final RegExp r = _pattern;
      return hashObjects([
        r.pattern,
        r.isCaseSensitive,
        r.isDotAll,
        r.isMultiLine,
        r.isUnicode,
      ]);
    }
    return _pattern.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (other is _Pattern) {
      if (_pattern is RegExp && other._pattern is RegExp) {
        final RegExp a = _pattern;
        final RegExp b = other._pattern;
        return a.pattern == b.pattern &&
            a.isCaseSensitive == b.isCaseSensitive &&
            a.isDotAll == b.isDotAll &&
            a.isMultiLine == b.isMultiLine &&
            a.isUnicode == b.isUnicode;
      }
      return _pattern == other._pattern;
    }
    return _pattern == other;
  }

  @override
  String toString() => _pattern.toString();
}

class _RequestHandlerMatch {
  final Function handler;
  final Match match;

  _RequestHandlerMatch(this.handler, {this.match});
}

class _RequestExpectation {
  Object failWith;
  final Map<String, String> headers;
  final String method;
  BaseResponse respondWith;
  final Object uri;

  _RequestExpectation(this.method, this.uri, this.headers,
      {this.failWith, this.respondWith});
}
