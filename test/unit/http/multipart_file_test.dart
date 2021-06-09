// @dart=2.7
// ^ Do not remove until migrated to null safety. More info at https://wiki.atl.workiva.net/pages/viewpage.action?pageId=189370832
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
import 'dart:async';

import 'package:http_parser/http_parser.dart';
import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart' as transport;

import '../../naming.dart';

void main() {
  final naming = Naming()
    ..testType = testTypeUnit
    ..topic = topicHttp;

  group(naming.toString(), () {
    group('MultipartFile', () {
      test('content-type set explicitly', () {
        final contentType = MediaType('application', 'json');
        final file = transport.MultipartFile(Stream.fromIterable([]), 0,
            contentType: contentType, filename: 'page.html');
        expect(file.contentType.mimeType, 'application/json');
      });

      test('content-type should be based on a mimetype lookup', () {
        final stream = Stream<List<int>>.fromIterable([]);

        final jsonFile =
            transport.MultipartFile(stream, 0, filename: 'data.json');
        expect(jsonFile.contentType.mimeType, equals('application/json'));

        final zipFile =
            transport.MultipartFile(stream, 0, filename: 'compressed.zip');
        expect(zipFile.contentType.mimeType, equals('application/zip'));

        final imgFile = transport.MultipartFile(stream, 0, filename: 'img.png');
        expect(imgFile.contentType.mimeType, equals('image/png'));

        final htmlFile =
            transport.MultipartFile(stream, 0, filename: 'page.html');
        expect(htmlFile.contentType.mimeType, equals('text/html'));
      });

      test('content-type default to application/octet-stream', () {
        final file = transport.MultipartFile(Stream.fromIterable([]), 0);
        expect(file.contentType.mimeType, equals('application/octet-stream'));
      });
    });
  });
}
