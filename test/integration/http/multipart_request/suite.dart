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

import 'dart:async';
import 'dart:convert';

import 'package:http_parser/http_parser.dart';
import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';

import '../../integration_paths.dart';

void runMultipartRequestSuite() {
  group('MultipartRequest', () {
    test('contentLength should be set automatically', () async {
      final chunks = <List<int>>[
        UTF8.encode('chunk1'),
        UTF8.encode('chunk2'),
        UTF8.encode('chunk3')
      ];
      int size = 0;
      chunks.forEach((chunk) {
        size += chunk.length;
      });
      final fileStream = new Stream.fromIterable(chunks);
      final file = new MultipartFile(fileStream, size);

      final request = new MultipartRequest()
        ..uri = IntegrationPaths.reflectEndpointUri
        ..files['file'] = file
        ..fields['field'] = 'value';

      final response =
          await request.post(uri: IntegrationPaths.reflectEndpointUri);
      final contentLength =
          int.parse(response.body.asJson()['headers']['content-length']);
      expect(contentLength, greaterThan(0),
          reason:
              'Non-empty multipart request\'s content-length should be greater than 0.');
    });

    test('content-type should be set automatically', () async {
      final request = new MultipartRequest()
        ..uri = IntegrationPaths.reflectEndpointUri
        ..fields['field'] = 'value';
      final response = await request.post();
      final contentType = new MediaType.parse(
          response.body.asJson()['headers']['content-type']);
      expect(contentType.mimeType, equals('multipart/form-data'));
    });

    test('text fields with non-ASCII chars', () async {
      final request = new MultipartRequest()
        ..uri = IntegrationPaths.uploadEndpointUri
        ..fields['field'] = 'ç®å';
      await request.post();
    });

    test('uploading multiple files with different charsets', () async {
      // UTF8-encoded file.
      final utf8Chunks = <List<int>>[UTF8.encode('chunk1'), UTF8.encode('ç®å')];
      final utf8Stream = new Stream.fromIterable(utf8Chunks);
      final utf8Size = utf8Chunks[0].length + utf8Chunks[1].length;
      final utf8ContentType =
          new MediaType('text', 'plain', {'charset': UTF8.name});
      final utf8File = new MultipartFile(utf8Stream, utf8Size,
          contentType: utf8ContentType, filename: 'utf8-file');

      // LATIN1-encoded file.
      final latin1Chunks = <List<int>>[
        LATIN1.encode('chunk1'),
        LATIN1.encode('ç®å')
      ];
      final latin1Stream = new Stream.fromIterable(latin1Chunks);
      final latin1Size = latin1Chunks[0].length + latin1Chunks[1].length;
      final latin1ContentType =
          new MediaType('text', 'plain', {'charset': LATIN1.name});
      final latin1File = new MultipartFile(latin1Stream, latin1Size,
          contentType: latin1ContentType, filename: 'latin1-file');

      // ASCII-encoded file.
      final asciiChunks = <List<int>>[
        ASCII.encode('chunk1'),
        ASCII.encode('chunk2')
      ];
      final asciiStream = new Stream.fromIterable(asciiChunks);
      final asciiSize = asciiChunks[0].length + asciiChunks[1].length;
      final asciiContentType =
          new MediaType('text', 'plain', {'charset': ASCII.name});
      final asciiFile = new MultipartFile(asciiStream, asciiSize,
          contentType: asciiContentType, filename: 'ascii-file');

      final request = new MultipartRequest()
        ..uri = IntegrationPaths.uploadEndpointUri
        ..files['utf8File'] = utf8File
        ..files['latin1File'] = latin1File
        ..files['asciiFile'] = asciiFile;
      await request.post();
    });
  });
}
