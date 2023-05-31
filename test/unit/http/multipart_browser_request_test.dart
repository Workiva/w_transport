// Copyright 2018 Workiva Inc.
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
import 'dart:convert';
import 'package:test/test.dart';
import 'package:w_transport/browser.dart' show browserTransportPlatform;
import 'package:w_transport/src/http/browser/form_data_body.dart';
import 'package:w_transport/src/http/browser/multipart_request.dart';
import 'package:w_transport/w_transport.dart' as transport;

import '../../naming.dart';

void main() {
  final naming = Naming()
    ..testType = testTypeUnit
    ..topic = topicHttp;

  group(naming.toString(), () {
    group('BrowserMultipartRequest', () {
      group('finalizeBody', () {
        test('does not include duplicate ascii fields', () async {
          const key = 'ascii';
          final value = ascii.decode(ascii.encode('This is ASCII!'));

          final BrowserMultipartRequest request = transport.MultipartRequest(
              transportPlatform: browserTransportPlatform) as BrowserMultipartRequest
            ..fields = {
              key: value,
            };

          final FormDataBody body = await request.finalizeBody();
          expect(body.formData.getAll(key), equals([value]));
        });

        test('does not include duplicate unicode fields', () async {
          const key = 'unicode';
          const value = '藤原とうふ店（自家用）';

          final BrowserMultipartRequest request = transport.MultipartRequest(
              transportPlatform: browserTransportPlatform) as BrowserMultipartRequest
            ..fields = {
              key: value,
            };

          final FormDataBody body = await request.finalizeBody();
          expect(body.formData.getAll(key).length, equals(1));
        });
      });
    });
  });
}
