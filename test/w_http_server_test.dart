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
import 'package:w_transport/w_transport.dart';

import 'package:w_transport/src/http/server/util.dart' as serverUtil;
import 'package:w_transport/src/http/server/w_http.dart';
import 'package:w_transport/src/http/server/w_request.dart';
import 'package:w_transport/src/http/server/w_response.dart';

class MockHttpClientRequest extends Mock implements HttpClientRequest {
  // this tells Dart analyzer you meant not to implement all methods,
  // and not to hint/warn that methods are missing
  noSuchMethod(i) => super.noSuchMethod(i);
}

class MockHttpClientResponse extends Mock implements HttpClientResponse {
  // this tells Dart analyzer you meant not to implement all methods,
  // and not to hint/warn that methods are missing
  noSuchMethod(i) => super.noSuchMethod(i);
}

class MockHttpHeaders extends Mock implements HttpHeaders {
  // this tells Dart analyzer you meant not to implement all methods,
  // and not to hint/warn that methods are missing
  noSuchMethod(i) => super.noSuchMethod(i);
}

class MockHttpClientResponseFromStream extends Mock
    implements HttpClientResponse {
  Stream _stream;
  MockHttpClientResponseFromStream(this._stream);
  StreamSubscription listen(void onData(event),
      {Function onError, void onDone(), bool cancelOnError}) {
    return _stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
  Stream transform(StreamTransformer transformer) {
    return _stream.transform(transformer);
  }
  // this tells Dart analyzer you meant not to implement all methods,
  // and not to hint/warn that methods are missing
  noSuchMethod(i) => super.noSuchMethod(i);
}

void main() {
  group('Http Utils (Server)', () {
    group('wProgressListener()', () {
      test('should return an identical data stream', () async {
        List<List<int>> data = [
          [101, 28, 84, 35],
          [284, 8, 2910, 9],
          [111, 22, 3, 444],
        ];
        Stream input = new Stream.fromIterable(data);
        Stream output = input
            .transform(serverUtil.wProgressListener(0, new StreamController()));
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
        Stream output = input
            .transform(serverUtil.wProgressListener(total, progressController));
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
            .transform(serverUtil.wProgressListener(0, new StreamController()))
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
  });

  group('WHttp (Server)', () {
    test('should be associated with an HttpClient instance', () {
      expect(new ServerWHttp().client is HttpClient, isTrue);
    });
  });

  group('WRequest (Server)', () {
    test(
        'validateDataType() should throw an ArgumentError on invalid data type',
        () {
      var req = new ServerWRequest();

      req.data = 'data';
      req.validateDataType();

      req.data = new Stream.fromIterable([]);
      req.validateDataType();

      expect(() {
        req.data = 10;
        req.validateDataType();
      }, throwsArgumentError);
    });

    test('validateDataType() should not throw an ArgumentError on null data',
        () {
      var req = new ServerWRequest();
      req.data = null;
      req.validateDataType();
    });
  });

  group('WResponse (Server)', () {
    test('should return status info from HttpClientResponse', () {
      HttpClientResponse response =
          new MockHttpClientResponseFromStream(new Stream.fromIterable([]));
      when(response.statusCode).thenReturn(200);
      when(response.reasonPhrase).thenReturn('OK');
      when(response.headers).thenReturn(new MockHttpHeaders());
      ServerWResponse wResponse =
          new ServerWResponse(response, UTF8, -1, new StreamController());
      expect(wResponse.status, equals(200));
      expect(wResponse.statusText, equals('OK'));
    });

    test('should return response data from the stream (async)', () async {
      var data = [[10, 48, 28, 30], [999, 394, 1, 2], [239, 0, 20, 88]];
      Stream stream = new Stream.fromIterable(data);
      HttpClientResponse response =
          new MockHttpClientResponseFromStream(stream);
      when(response.headers).thenReturn(new MockHttpHeaders());
      var wResponse =
          new ServerWResponse(response, UTF8, -1, new StreamController());
      expect(await wResponse.asFuture(), equals(data.reduce(
          (previous, value) => new List.from(previous)..addAll(value))));
    });

    test('should return response text from the stream (async)', () async {
      Stream dataStream = new Stream.fromIterable(['chunk1', 'chunk2']);
      HttpClientResponse response =
          new MockHttpClientResponseFromStream(dataStream);
      when(response.headers).thenReturn(new MockHttpHeaders());
      var wResponse =
          new ServerWResponse(response, UTF8, -1, new StreamController());
      expect(await wResponse.asText(), equals('chunk1chunk2'));
    });

    test(
        'should return a stream with the response data as the only element (async)',
        () async {
      Stream dataStream = new Stream.fromIterable([UTF8.encode('data')]);
      HttpClientResponse response =
          new MockHttpClientResponseFromStream(dataStream);
      when(response.headers).thenReturn(new MockHttpHeaders());
      var wResponse =
          new ServerWResponse(response, UTF8, -1, new StreamController());
      expect(UTF8.decode(await wResponse.asStream().single), equals('data'));
    });
  });
}
