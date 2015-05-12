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

@TestOn('vm')
library w_transport.test.w_http_server_test;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:w_transport/src/http/w_http_server.dart' as w_http_server;
import 'package:w_transport/w_http.dart';

class MockHttpClientRequest extends Mock implements HttpClientRequest {}
class MockHttpClientResponse extends Mock implements HttpClientResponse {}
class MockHttpClientResponseFromStream extends Stream
    implements HttpClientResponse {
  Stream _stream;
  MockHttpClientResponseFromStream(this._stream);
  StreamSubscription listen(void onData(event),
      {Function onError, void onDone(), bool cancelOnError}) {
    return _stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

void main() {
  group('w_http_server', () {
    group('wProgressListener()', () {
      test('should return an identical data stream', () async {
        List<List<int>> data = [
          [101, 28, 84, 35],
          [284, 8, 2910, 9],
          [111, 22, 3, 444],
        ];
        Stream input = new Stream.fromIterable(data);
        Stream output = input.transform(
            w_http_server.wProgressListener(0, new StreamController()));
        var i = 0;
        await for (var element in output) {
          expect(element, equals(data[i++]));
        }
      });

      test('should populate a progress stream controller', () async {
        List<List<int>> data = [
          [101, 28, 84, 35],
          [284, 8, 2910, 9],
          [111, 22, 3, 444],
        ];
        int total = 12;
        Stream input = new Stream.fromIterable(data);
        StreamController<WProgress> progressController =
            new StreamController<WProgress>();
        Stream output = input.transform(
            w_http_server.wProgressListener(total, progressController));
        await output.drain();
        double expectedProgress = 0.0;
        await for (WProgress progress in progressController.stream) {
          expectedProgress += (4 * 100.0 / total);
          expect(progress.percent, equals(expectedProgress));
        }
      });

      test('should handle pausing and resuming subscriptions', () async {
        Completer completer = new Completer();
        StreamController<String> inputController =
            new StreamController<String>();
        int c = 0;
        StreamSubscription sub = inputController.stream
            .transform(
                w_http_server.wProgressListener(0, new StreamController()))
            .listen((progress) {
          c++;
        }, onDone: () {
          expect(c, equals(2));
          completer.complete();
        });
        inputController.add('one');
        sub.pause();
        inputController.add('two');
        sub.resume();
        inputController.close();
        return completer.future;
      });
    });

    test('abort() should call `close()` on the HttpClientRequest instance', () {
      HttpClientRequest request = new MockHttpClientRequest();
      w_http_server.abort(request);
      verify(request.close()).called(1);
    });

    test('getNewHttpClient() should return a new HttpClient instance', () {
      expect(w_http_server.getNewHttpClient() is HttpClient, isTrue);
    });

    test(
        'parseResponseHeaders() should return response headers from HttpClientResponse',
        () {
      HttpClientResponse response = new MockHttpClientResponse();
      when(response.headers).thenReturn({
        'Content-Type': ['application/json'],
        'X-Tokens': ['token1', 'token2'],
      });
      expect(w_http_server.parseResponseHeaders(response), equals(
          {'Content-Type': 'application/json', 'X-Tokens': 'token1,token2',}));
    });

    test('parseResponseStatus() should return status from HttpClientResponse',
        () {
      HttpClientResponse response = new MockHttpClientResponse();
      when(response.statusCode).thenReturn(200);
      expect(w_http_server.parseResponseStatus(response), equals(200));
    });

    test(
        'parseResponseStatusText() should return status text from HttpClientResponse',
        () {
      HttpClientResponse response = new MockHttpClientResponse();
      when(response.reasonPhrase).thenReturn('OK');
      expect(w_http_server.parseResponseStatusText(response), equals('OK'));
    });

    test(
        'validateDataType() should throw an ArgumentError on invalid data type',
        () {
      w_http_server.validateDataType('data');
      w_http_server.validateDataType(new Stream.fromIterable([]));
      expect(() {
        w_http_server.validateDataType(10);
      }, throwsArgumentError);
    });

    test(
        'parseResponseData() should return response data from HttpClientResponse (async)',
        () async {
      var data = [[10, 48, 28, 30], [999, 394, 1, 2], [239, 0, 20, 88],];
      HttpClientResponse response =
          new MockHttpClientResponseFromStream(new Stream.fromIterable(data));
      expect(await w_http_server.parseResponseData(
              response, 0, new StreamController()),
          equals([10, 48, 28, 30, 999, 394, 1, 2, 239, 0, 20, 88]));
    });

    test(
        'parseResponseText() should return response text from HttpRequest (async)',
        () async {
      Stream dataStream = new Stream.fromIterable(
          [UTF8.encode('chunk1'), UTF8.encode('chunk2')]);
      HttpClientResponse response =
          new MockHttpClientResponseFromStream(dataStream);
      expect(await w_http_server.parseResponseText(
          response, UTF8, 0, new StreamController()), equals('chunk1chunk2'));
    });

    test(
        'parseResponseStream() should return a stream with the response data as the only element (async)',
        () async {
      Stream dataStream = new Stream.fromIterable([UTF8.encode('data')]);
      HttpClientResponse response =
          new MockHttpClientResponseFromStream(dataStream);
      expect(UTF8.decode(await w_http_server.parseResponseStream(
          response, 0, new StreamController()).single), equals('data'));
    });
  });
}
