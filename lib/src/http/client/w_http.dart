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

library w_transport.src.http.client.w_http;

import 'package:w_transport/src/http/client/w_request.dart';
import 'package:w_transport/src/http/common/w_http.dart';
import 'package:w_transport/src/http/w_http.dart';
import 'package:w_transport/src/http/w_request.dart';

class ClientWHttp extends CommonWHttp implements WHttp {
  /// Generates a new [WRequest] instance. There's no concept
  /// of an HTTP client in the browser, so a regular request
  /// is used here.
  WRequest newRequest() {
    verifyNotClosed();
    return new ClientWRequest();
  }
}
