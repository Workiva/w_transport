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

class IntegrationPaths {
  static final Uri hostUri = Uri.parse('http://localhost:8024');
  static final Uri wsHostUri = hostUri.replace(scheme: 'ws');

  // HTTP

  static final Uri customEndpointUri =
      hostUri.replace(path: '/test/http/custom');
  static final Uri downloadEndpointUri =
      hostUri.replace(path: '/test/http/download');
  static final Uri echoEndpointUri = hostUri.replace(path: '/test/http/echo');
  static final Uri errorEndpointUri = hostUri.replace(path: '/test/http/error');
  static final Uri fourOhFourEndpointUri =
      hostUri.replace(path: '/test/http/404');
  static final Uri pingEndpointUri = hostUri.replace(path: '/test/http/ping');
  static final Uri reflectEndpointUri =
      hostUri.replace(path: '/test/http/reflect');
  static final Uri timeoutEndpointUri =
      hostUri.replace(path: '/test/http/timeout');
  static final Uri uploadEndpointUri =
      hostUri.replace(path: '/test/http/upload');

  // WebSocket

  static final Uri closeUri = wsHostUri.replace(path: '/test/ws/close');
  static final Uri echoUri = wsHostUri.replace(path: '/test/ws/echo');
  static final Uri fourOhFourUri = Uri.parse('ws://localhost:9999');
  static final Uri pingUri = wsHostUri.replace(path: '/test/ws/ping');
}
