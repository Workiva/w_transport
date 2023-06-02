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

@TestOn('browser')
import 'package:test/test.dart';
import 'package:w_transport/browser.dart';
import 'package:w_transport/w_transport.dart' as transport;

import '../../../naming.dart';
import '../../integration_paths.dart';
import 'suite.dart';

void main() {
  final naming = Naming()
    ..platform = platformBrowser
    ..testType = testTypeIntegration
    ..topic = topicHttp;

  group(naming.toString(), () {
    runCommonRequestSuite(browserTransportPlatform);

    group('autoRetry browser', () {
      test('null response default behavior', () async {
        final request =
            transport.Request(transportPlatform: browserTransportPlatform)
              ..headers.addAll({'x-custom': 'causes-CORS-request'})
              ..uri = IntegrationPaths.errorEndpointUri;
        request.autoRetry!
          ..enabled = true
          ..maxRetries = 2;

        expect(request.get(), throwsA(isA<transport.RequestException>()));
        await request.done;
        expect(request.autoRetry!.numAttempts, equals(1));
        expect(request.autoRetry!.failures.length, equals(1));
      });

      test('null response should be retried', () async {
        final request =
            transport.Request(transportPlatform: browserTransportPlatform)
              ..headers.addAll({'x-custom': 'causes-CORS-request'})
              ..uri = IntegrationPaths.errorEndpointUri;
        request.autoRetry!
          ..enabled = true
          ..maxRetries = 2
          ..test = (request, response, willRetry) async {
            if (response == null) {
              return true;
            }
            return willRetry;
          };

        expect(request.get(), throwsA(isA<transport.RequestException>()));
        await request.done;
        expect(request.autoRetry!.numAttempts, equals(3));
        expect(request.autoRetry!.failures.length, equals(3));
      });
    });
  });
}
