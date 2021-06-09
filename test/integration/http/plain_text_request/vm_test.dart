// @dart=2.7
// ^ Do not remove until migrated to null safety. More info at https://wiki.atl.workiva.net/pages/viewpage.action?pageId=189370832
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
import 'dart:io';

import 'package:test/test.dart';
import 'package:w_transport/vm.dart';
import 'package:w_transport/w_transport.dart' as transport;

import '../../../naming.dart';
import '../../integration_paths.dart';
import 'suite.dart';

void main() {
  final naming = Naming()
    ..platform = platformVM
    ..testType = testTypeIntegration
    ..topic = topicHttp;

  group(naming.toString(), () {
    runPlainTextRequestSuite(vmTransportPlatform);

    test('underlying HttpRequest configuration', () async {
      final request = transport.Request(transportPlatform: vmTransportPlatform)
        ..uri = IntegrationPaths.reflectEndpointUri;
      request.configure((request) async {
        HttpClientRequest ioRequest = request;
        ioRequest.headers.set('x-configured', 'true');
      });
      final response = await request.get();
      expect(response.body.asJson()['headers']['x-configured'], equals('true'));
    });
  });
}
