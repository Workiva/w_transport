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

import 'package:w_transport/w_transport.dart';
import 'package:w_transport/mock.dart';

void mockEchoEndpoint(Uri uri) {
  MockTransports.http.when(uri, (request) async {
    final headers = <String, String>{
      'content-type': request.headers['content-type'] ?? ''
    };
    if (request.body is HttpBody) {
      HttpBody body = request.body as HttpBody;
      return MockResponse.ok(body: body.asString(), headers: headers);
    } else {
      StreamedHttpBody body = request.body as StreamedHttpBody;
      return MockStreamedResponse.ok(
          byteStream: body.byteStream, headers: headers);
    }
  });
}
