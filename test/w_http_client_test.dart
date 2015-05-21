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
import 'dart:html';

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:w_transport/src/http/w_http_client.dart' as w_http_client;
import 'package:w_transport/w_transport.dart';

class MockProgressEvent extends Mock implements ProgressEvent {
  final bool lengthComputable;
  final int loaded;
  final int total;
  MockProgressEvent(this.lengthComputable, [this.loaded, this.total]);
}

class MockHttpRequest extends Mock implements HttpRequest {}

class MockHttpRequestUpload extends Mock implements HttpRequestUpload {}

void main() {
  group('w_http_client', () {
    group('wProgressTransformer', () {
      test('should convert ProgressEvent stream to WProgress stream', () async {
        Stream<ProgressEvent> input = new Stream.fromIterable([
          new MockProgressEvent(true, 0, 100),
          new MockProgressEvent(true, 33, 100),
          new MockProgressEvent(true, 100, 100),
        ]);
        Stream<WProgress> output =
            input.transform(w_http_client.wProgressTransformer);
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
            input.transform(w_http_client.wProgressTransformer);
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
            .transform(w_http_client.wProgressTransformer)
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

    test('abort() should call `abort()` on the HttpRequest instance', () {
      HttpRequest request = new MockHttpRequest();
      w_http_client.abort(request);
      verify(request.abort()).called(1);
    });

    test('getNewHttpClient() should return null', () {
      expect(w_http_client.getNewHttpClient(), isNull);
    });

    test(
        'parseResponseHeaders() should return response headers from HttpRequest',
        () {
      HttpRequest request = new MockHttpRequest();
      var headers = {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      };
      when(request.responseHeaders).thenReturn(headers);
      expect(w_http_client.parseResponseHeaders(request), equals(headers));
    });

    test('parseResponseStatus() should return status from HttpRequest', () {
      HttpRequest request = new MockHttpRequest();
      when(request.status).thenReturn(200);
      expect(w_http_client.parseResponseStatus(request), equals(200));
    });

    test('parseResponseStatusText() should return status text from HttpRequest',
        () {
      HttpRequest request = new MockHttpRequest();
      when(request.statusText).thenReturn('OK');
      expect(w_http_client.parseResponseStatusText(request), equals('OK'));
    });

    test(
        'parseResponseData() should return response data from the stream (async)',
        () async {
      Stream stream = new Stream.fromIterable(['data']);
      expect(await w_http_client.parseResponseData(stream), equals('data'));
    });

    test(
        'parseResponseText() should return response text from the stream (async)',
        () async {
      Stream stream = new Stream.fromIterable(['data']);
      expect(await w_http_client.parseResponseText(stream), equals('data'));
    });

    test(
        'parseResponseStream() should return a stream with the response data as the only element (async)',
        () async {
      HttpRequest request = new MockHttpRequest();
      when(request.response).thenReturn('data');
      expect(
          await w_http_client.parseResponseStream(request, null, null).single,
          equals('data'));
    });

    test('send() should set the withCredentials flag correctly', () async {
      w_http_client.configureWHttpForBrowser();
      WRequest request = new WRequest();
      request.withCredentials = true;
      HttpRequest xhr = new MockHttpRequest();
      HttpRequestUpload xhrUpload = new MockHttpRequestUpload();
      when(xhr.status).thenReturn(200);
      when(xhr.onProgress).thenReturn(new Stream.fromIterable([]));
      when(xhr.upload).thenReturn(xhrUpload);
      when(xhrUpload.onProgress).thenReturn(new Stream.fromIterable([]));
      when(xhr.onLoad)
          .thenReturn(new Stream.fromIterable([new MockProgressEvent(false)]));
      when(xhr.onError).thenReturn(new Stream.fromIterable([]));

      await w_http_client.send(
          'GET', request, xhr, new StreamController(), new StreamController());
      verify(xhr.withCredentials = true);
    });

    test(
        'validateDataType() should throw an ArgumentError on invalid data type',
        () {
      w_http_client.validateDataType(document);
      w_http_client.validateDataType(new FormData());
      w_http_client.validateDataType('data');
      expect(() {
        w_http_client.validateDataType(new Stream.fromIterable([]));
      }, throwsArgumentError);
    });
  });
}
