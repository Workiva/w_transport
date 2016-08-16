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

@TestOn('browser')
import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/browser.dart';

import 'package:w_transport/src/http/browser/http_client.dart';
import 'package:w_transport/src/http/browser/requests.dart';

import '../../naming.dart';

void main() {
  Naming naming = new Naming()
    ..platform = platformBrowser
    ..testType = testTypeIntegration
    ..topic = topicPlatformAdapter;

  group(naming.toString(), () {
    setUp(() {
      configureWTransportForBrowser();
    });

    test('newClient()', () {
      expect(new Client(), new isInstanceOf<BrowserHttpClient>());
    });

    test('newHttpClient()', () {
      expect(new HttpClient(), new isInstanceOf<BrowserHttpClient>());
    });

    test('newFormRequest()', () {
      expect(new FormRequest(), new isInstanceOf<BrowserFormRequest>());
    });

    test('newJsonRequest()', () {
      expect(new JsonRequest(), new isInstanceOf<BrowserJsonRequest>());
    });

    test('newMultipartRequest()', () {
      expect(
          new MultipartRequest(), new isInstanceOf<BrowserMultipartRequest>());
    });

    test('newRequest()', () {
      expect(new Request(), new isInstanceOf<BrowserPlainTextRequest>());
    });

    test('newStreamedRequest()', () {
      expect(new StreamedRequest(), new isInstanceOf<BrowserStreamedRequest>());
    });
  });
}
