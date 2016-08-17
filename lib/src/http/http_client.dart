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

import 'package:w_transport/src/http/client.dart';
import 'package:w_transport/src/platform_adapter.dart';

/// An HTTP client acts as a single point from which many requests can be
/// constructed. All requests constructed from a client will inherit [headers],
/// the [withCredentials] flag, and the [timeoutThreshold].
///
/// On the server, the Dart VM will also be able to take advantage of cached
/// network connections between requests that share a client.
abstract class HttpClient extends Client {
  factory HttpClient() => PlatformAdapter.retrieve().newHttpClient();
}
