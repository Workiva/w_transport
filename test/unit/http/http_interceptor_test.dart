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
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/mock.dart';

import '../../naming.dart';

void main() {
  final naming = new Naming()
    ..testType = testTypeUnit
    ..topic = topicHttp;

  group(naming.toString(), () {
    group('HttpInterceptor', () {
      setUp(() async {
        configureWTransportForTest();
        await MockTransports.reset();
      });

      test('default implementations should not modify the payloads', () async {
        final req = new Request()..uri = Uri.parse('/test');
        final body =
            new HttpBody.fromString(new MediaType('text', 'plain'), 'body');
        final finalizedReq =
            new FinalizedRequest('GET', req.uri, {}, body, false);
        final resp = new MockResponse.ok();
        final reqPayload = new RequestPayload(new Request());
        final respPayload = new ResponsePayload(finalizedReq, resp);

        final interceptor = new HttpInterceptor();
        expect(
            identical(
                reqPayload, await interceptor.interceptRequest(reqPayload)),
            isTrue);
        expect(
            identical(
                respPayload, await interceptor.interceptResponse(respPayload)),
            isTrue);
      });
    });
  });
}
