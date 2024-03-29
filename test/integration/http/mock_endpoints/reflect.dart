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

import 'dart:convert';
import 'package:w_transport/mock.dart';

void mockReflectEndpoint(Uri uri) {
  MockTransports.http.when(uri, (request) async {
    final reflection = <String, Object?>{
      'method': request.method,
      'path': request.uri.path,
      'headers': request.headers,
    };
    return MockResponse.ok(body: json.encode(reflection));
  });
}
