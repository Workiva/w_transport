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

@TestOn('browser || vm')
library w_transport.test.unit.http.multipart_file_test;

import 'dart:async';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';

import '../../naming.dart';

void main() {
  Naming naming = new Naming()
    ..testType = testTypeUnit
    ..topic = topicHttp;

  group(naming.toString(), () {
    group('MultipartFile', () {
      test('content-type set explicitly', () {
        MediaType contentType = new MediaType('application', 'json');
        MultipartFile file = new MultipartFile(new Stream.fromIterable([]), 0,
            contentType: contentType, filename: 'page.html');
        expect(file.contentType.mimeType, 'application/json');
      });

      test('content-type should be based on a mimetype lookup', () {
        var stream = new Stream.fromIterable([]);

        MultipartFile jsonFile =
            new MultipartFile(stream, 0, filename: 'data.json');
        expect(jsonFile.contentType.mimeType, equals('application/json'));

        MultipartFile zipFile =
            new MultipartFile(stream, 0, filename: 'compressed.zip');
        expect(zipFile.contentType.mimeType, equals('application/zip'));

        MultipartFile imgFile =
            new MultipartFile(stream, 0, filename: 'img.png');
        expect(imgFile.contentType.mimeType, equals('image/png'));

        MultipartFile htmlFile =
            new MultipartFile(stream, 0, filename: 'page.html');
        expect(htmlFile.contentType.mimeType, equals('text/html'));
      });

      test('content-type default to application/octet-stream', () {
        MultipartFile file = new MultipartFile(new Stream.fromIterable([]), 0);
        expect(file.contentType.mimeType, equals('application/octet-stream'));
      });
    });
  });
}
