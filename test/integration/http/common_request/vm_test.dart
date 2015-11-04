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
library w_transport.test.integration.http.common_request.vm_test;

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_vm.dart';

import '../../../naming.dart';
import 'suite.dart';

void main() {
  Naming naming = new Naming()
    ..platform = platformVM
    ..testType = testTypeIntegration
    ..topic = topicHttp;

  group(naming.toString(), () {
    setUp(() {
      configureWTransportForVM();
    });

    runCommonRequestSuite();

    group('MultipartRequest', () {
      test('adding invalid type as file throws', () {
        MultipartRequest request = new MultipartRequest();
        request.files['test'] = 'not a file';
        expect(() => request.contentLength, throwsUnsupportedError);
        expect(request.post(uri: Uri.parse('/test')), throwsUnsupportedError);
      });
    });
  });
}
