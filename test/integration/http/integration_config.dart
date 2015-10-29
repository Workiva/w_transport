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

library w_transport.test.integration.http.integration_config;

import '../../naming.dart';

class HttpIntegrationConfig {
  final Uri hostUri = Uri.parse('http://localhost:8024');

  final String platform;

  HttpIntegrationConfig.browser() : platform = platformBrowser;
  HttpIntegrationConfig.mock() : platform = platformMock;
  HttpIntegrationConfig.vm() : platform = platformVM;

  Uri get downloadEndpointUri => hostUri.replace(path: '/test/http/download');

  Uri get echoEndpointUri => hostUri.replace(path: '/test/http/echo');

  Uri get fourOhFourEndpointUri => hostUri.replace(path: '/test/http/404');

  Uri get pingEndpointUri => hostUri.replace(path: '/test/http/ping');

  Uri get reflectEndpointUri => hostUri.replace(path: '/test/http/reflect');

  Uri get timeoutEndpointUri => hostUri.replace(path: '/test/http/timeout');

  Uri get uploadEndpointUri => hostUri.replace(path: '/test/http/upload');

  String get title => 'HTTP ($platform):';
}
