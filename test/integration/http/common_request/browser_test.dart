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
library w_transport.test.integration.http.common_request.browser_test;

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_browser.dart';

import 'package:w_transport/src/http/common/request.dart';

import '../../integration_paths.dart';
import '../../../naming.dart';
import 'suite.dart';

void main() {
  Naming naming = new Naming()
    ..platform = platformBrowser
    ..testType = testTypeIntegration
    ..topic = topicHttp;

  group(naming.toString(), () {
    setUp(() {
      configureWTransportForBrowser();
    });

    runCommonRequestSuite();

    group('autoRetry browser', () {
      test('null response default behavior', () async {
        BaseRequest request = new Request()
          ..headers.addAll({'x-custom': 'causes-CORS-request'})
          ..uri = IntegrationPaths.errorEndpointUri;
        request.autoRetry
          ..enabled = true
          ..maxRetries = 2;

        expect(request.get(), throwsA(new isInstanceOf<RequestException>()));
        await request.done;
        expect(request.autoRetry.numAttempts, equals(1));
        expect(request.autoRetry.failures.length, equals(1));
      });

      test('null response should be retried', () async {
        BaseRequest request = new Request()
          ..headers.addAll({'x-custom': 'causes-CORS-request'})
          ..uri = IntegrationPaths.errorEndpointUri;
        request.autoRetry
          ..enabled = true
          ..maxRetries = 2
          ..test = (request, response, willRetry) async {
            if (response == null) {
              return true;
            }
            return willRetry;
          };

        expect(request.get(), throwsA(new isInstanceOf<RequestException>()));
        await request.done;
        expect(request.autoRetry.numAttempts, equals(3));
        expect(request.autoRetry.failures.length, equals(3));
      });

      test(
          'request cancellation while underlying XHR instance is being built should not throw',
          () async {
        CommonRequest request = (new Request() as CommonRequest)
          ..headers = {
            'one': 'one',
            'two': 'two',
            'three': 'three',
            'four': 'four',
          }
          ..uri = IntegrationPaths.timeoutEndpointUri;

        // Manually enter the step where the browser request mixin opens and
        // builds the XHR instance.
        var finalizedRequest = await request.finalizeRequest();
        await request.openRequest();
        var future = request.sendRequestAndFetchResponse(finalizedRequest);

        // Manually abort the underlying XHR before request headers would be
        // applied. This will exercise the guard around `setRequestHeader`,
        // which is the point of this test.
        request.abort();

        // Without the "isCanceled" guard, this call would have failed because
        // the XHR instance would not be "OPENED" when `setRequestHeader` is
        // called. It should now return normally.
        expect(future, completes);
      });
    });
  });
}
