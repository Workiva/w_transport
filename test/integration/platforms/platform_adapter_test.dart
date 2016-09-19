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

@TestOn('vm || browser')
import 'package:test/test.dart';

import '../../naming.dart';

void main() {
  final naming = new Naming()
    ..testType = testTypeIntegration
    ..topic = topicPlatformAdapter;

  group(naming.toString(), () {
    test('PlatformAdapter.retrieve() should throw if not platform set',
        () async {
//      adapter = null;
//      expect(PlatformAdapter.retrieve, throwsStateError);
    });
  });
}
