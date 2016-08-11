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

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';

import '../../naming.dart';

void main() {
  Naming naming = new Naming()
    ..testType = testTypeUnit
    ..topic = topicHttp;

  group(naming.toString(), () {
    group('RequestProgress', () {
      test('lengthComputable should be true if total is known', () {
        RequestProgress prog = new RequestProgress(10, 100);
        expect(prog.lengthComputable, isTrue);
      });

      test('lengthComputable should be false if total is unknown', () {
        RequestProgress prog = new RequestProgress(10);
        expect(prog.lengthComputable, isFalse);
      });

      test('percent should be calculcated', () {
        RequestProgress prog = new RequestProgress(10, 100);
        expect(prog.percent, equals(10.0));
      });

      test('percent should be 0.0 if length is not computable', () {
        RequestProgress prog = new RequestProgress(10);
        expect(prog.percent, equals(0.0));
      });
    });
  });
}
