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

@TestOn('vm')
library w_transport.test.unit.http.http_util_server_test;

import 'dart:async';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart' show WProgress;

import 'package:w_transport/src/http/server/util.dart' show progressListener;

void main() {
  group('progressListener', () {
    test('should return an identical data stream', () async {
      List<List<int>> data = [
        [101, 28, 84, 35],
        [284, 8, 2910, 9],
        [111, 22, 3, 444],
      ];
      Stream input = new Stream.fromIterable(data);
      Stream output =
          input.transform(progressListener(0, new StreamController()));
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
      Stream output =
          input.transform(progressListener(total, progressController));
      await output.drain();
      double expectedProgress = 0.0;
      await for (WProgress progress in progressController.stream) {
        expectedProgress += (4 * 100.0 / total);
        expect(progress.percent, equals(expectedProgress));
      }
    });

    test('should handle pausing and resuming subscriptions', () async {
      Completer completer = new Completer();
      StreamController<String> inputController = new StreamController<String>();
      int c = 0;
      StreamSubscription sub = inputController.stream
          .transform(progressListener(0, new StreamController()))
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
}
