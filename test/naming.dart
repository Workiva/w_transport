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

/// Platforms.
const String platformBrowser = 'browser';
const String platformBrowserSockjsPort = 'browser (SockJS Port)';
const String platformBrowserSockjsWrapper = 'browser (SockJS Wrapper)';
const String platformBrowserSockjsPortDeprecated =
    'browser (SockJS Port) [DEPRECATED]';
const String platformBrowserSockjsWrapperDeprecated =
    'browser (SockJS Wrapper) [DEPRECATED]';
const String platformMock = 'mock';
const String platformVM = 'vm';

/// Test types.
const String testTypeIntegration = 'integration';
const String testTypeUnit = 'unit';

/// Topics
const String topicBackoff = 'Backoff';
const String topicHttp = 'HTTP';
const String topicMocks = 'Mocks';
const String topicTransportPlatform = 'Transport Platform';
const String topicWebSocket = 'WS';
const String topicGlobalWebSocketMonitor = 'GlobalWebSocketMonitor';

class Naming {
  String? platform;
  String? testType;
  String? topic;

  @override
  String toString() {
    String s = '$topic [$testType]';
    if (platform != null) {
      s += ' [$platform]';
    }
    return s;
  }
}
