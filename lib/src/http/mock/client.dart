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

import 'package:w_transport/src/constants.dart' show v3Deprecation;
import 'package:w_transport/src/http/mock/http_client.dart';
import 'package:w_transport/src/http/http_client.dart';
import 'package:w_transport/src/transport_platform.dart';

/// A mock implementation of an HTTP client. Factory methods simply return the
/// mock implementations of each request. Since the mock request implementations
/// don't ever actually send an HTTP request, this client doesn't need to do
/// anything else.
@Deprecated(v3Deprecation)
class MockClient extends MockHttpClient implements HttpClient {
  MockClient([TransportPlatform transport]) : super(transport);
}
