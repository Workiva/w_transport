/*
 * Copyright 2015 Workiva Inc.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

@TestOn('browser || content-shell')
library w_transport.test.w_http_client_test;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';

import 'package:w_transport/src/http/client/util.dart' as client_util;
import 'package:w_transport/src/http/client/w_http.dart';
import 'package:w_transport/src/http/client/w_request.dart';
import 'package:w_transport/src/http/client/w_response.dart';

class MockProgressEvent extends Mock implements ProgressEvent {
  final bool lengthComputable;
  final int loaded;
  final int total;
  MockProgressEvent(this.lengthComputable, [this.loaded, this.total]);

  // this tells Dart analyzer you meant not to implement all methods,
  // and not to hint/warn that methods are missing
  noSuchMethod(i) => super.noSuchMethod(i);
}

class MockHttpRequest extends Mock implements HttpRequest {
  // this tells Dart analyzer you meant not to implement all methods,
  // and not to hint/warn that methods are missing
  noSuchMethod(i) => super.noSuchMethod(i);
}

class MockHttpRequestUpload extends Mock implements HttpRequestUpload {
  // this tells Dart analyzer you meant not to implement all methods,
  // and not to hint/warn that methods are missing
  noSuchMethod(i) => super.noSuchMethod(i);
}

void main() {
  group('Http Utils (Client)', () {
    group('wProgressTransformer', () {
      test('should convert ProgressEvent stream to WProgress stream', () async {
        Stream<ProgressEvent> input = new Stream.fromIterable([
          new MockProgressEvent(true, 0, 100),
          new MockProgressEvent(true, 33, 100),
          new MockProgressEvent(true, 100, 100),
        ]);
        Stream<WProgress> output =
            input.transform(client_util.wProgressTransformer);
        var percentages = [];
        await for (var progress in output) {
          expect(progress is WProgress, isTrue);
          percentages.add((progress as WProgress).percent);
        }
        expect(percentages, equals([0.0, 33.0, 100.0,]));
      });

      test(
          'should convert ProgressEvent stream to WProgress stream even if not computable',
          () async {
        Stream<ProgressEvent> input = new Stream.fromIterable(
            [new MockProgressEvent(false), new MockProgressEvent(false),]);
        Stream<WProgress> output =
            input.transform(client_util.wProgressTransformer);
        var percentages = [];
        await for (var progress in output) {
          expect(progress is WProgress, isTrue);
          percentages.add((progress as WProgress).percent);
        }
        expect(percentages, equals([0.0, 0.0,]));
      });

      test('should handle pausing and resuming subscriptions', () async {
        Completer completer = new Completer();
        StreamController<ProgressEvent> inputController =
            new StreamController<ProgressEvent>();
        int c = 0;
        StreamSubscription sub = inputController.stream
            .transform(client_util.wProgressTransformer)
            .listen((progress) {
          c++;
        }, onDone: () {
          expect(c, equals(2));
          completer.complete();
        });
        inputController.add(new MockProgressEvent(true, 0, 100));
        sub.pause();
        inputController.add(new MockProgressEvent(true, 50, 100));
        sub.resume();
        inputController.close();
        return completer.future;
      });
    });
  });

  group('WHttp (Client)', () {
    test('should not be associated with an http client', () {
      expect(new ClientWHttp().client, isNull);
    });
  });

  group('WRequest (Client)', () {
    test(
        'validateDataType() should throw an ArgumentError on invalid data type',
        () {
      var req = new ClientWRequest();

      req.data = document;
      req.validateDataType();

      req.data = new FormData();
      req.validateDataType();

      req.data = 'data';
      req.validateDataType();

      expect(() {
        req.data = new Stream.fromIterable([]);
        req.validateDataType();
      }, throwsArgumentError);
    });

    test('validateDataType() should not throw an ArgumentError on null data',
        () {
      var req = new ClientWRequest();
      req.validateDataType();
    });
  });

  group('wResponse (Client)', () {
    test('parseResponseStatus() should return status info from HttpRequest',
        () {
      HttpRequest request = new MockHttpRequest();
      when(request.status).thenReturn(200);
      when(request.statusText).thenReturn('OK');
      var response = new ClientWResponse(request, UTF8);
      expect(response.status, equals(200));
      expect(response.statusText, equals('OK'));
    });

    test('parseResponseStatusText() should return status text from HttpRequest',
        () {
      HttpRequest request = new MockHttpRequest();
      when(request.statusText).thenReturn('OK');
    });

    test('should return response headers from HttpRequest', () {
      HttpRequest request = new MockHttpRequest();
      var headers = {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      };
      when(request.responseHeaders).thenReturn(headers);
      expect(new ClientWResponse(request, UTF8).headers, equals(headers));
    });

    test('should return response data from the request (async)', () async {
      HttpRequest request = new MockHttpRequest();
      when(request.response).thenReturn('data');
      var response = new ClientWResponse(request, UTF8);
      expect(await response.asFuture(), equals('data'));
    });

    test('should return response text from the request (async)', () async {
      HttpRequest request = new MockHttpRequest();
      when(request.response).thenReturn('data');
      var response = new ClientWResponse(request, UTF8);
      expect(await response.asText(), equals('data'));
    });

    test(
        'should return a stream with the response data as the only element (async)',
        () async {
      HttpRequest request = new MockHttpRequest();
      when(request.response).thenReturn('data');
      var response = new ClientWResponse(request, UTF8);
      expect(await response.asStream().single, equals('data'));
    });
  });
}
