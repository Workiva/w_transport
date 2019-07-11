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

@Tags(['no-dart2'])
@TestOn('browser')
import 'package:test/test.dart';

import 'sockjs_common.dart';

const _protocolsToTest = [
  'websocket', // All modern browsers (websocket=yes)
  'xhr-streaming', // All modern browsers (websocket=no, streaming=yes)

  // The sockjs_client port doesn't support xhr-polling.
  // 'xhr-polling', // All modern browsers (streaming=no)

  // These cannot currently be run in our CI.
  // 'iframe-htmlfile', // IE 8,9 (cookies=yes, streaming=yes)
  // 'iframe-xhr-polling', // IE 8,9 (cookies=yes, streaming=no)
  // 'jsonp-polling', // Konqueror
];

void main() {
  runCommonSockJSSuite(_protocolsToTest, usingSockjsPort: true);
}
