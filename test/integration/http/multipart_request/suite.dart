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
      List<List<int>> chunks = [
        UTF8.encode('chunk1'),
        UTF8.encode('chunk2'),
        UTF8.encode('chunk3')
      ];
      int size = 0;
      chunks.forEach((chunk) {
        size += chunk.length;
      });
      Stream fileStream = new Stream.fromIterable(chunks);
      MultipartFile file = new MultipartFile(fileStream, size);

      MultipartRequest request = new MultipartRequest()
        ..uri = IntegrationPaths.reflectEndpointUri
        ..files['file'] = file
        ..fields['field'] = 'value';

      Response response =
          await request.post(uri: IntegrationPaths.reflectEndpointUri);
      var contentLength =
          int.parse(response.body.asJson()['headers']['content-length']);
      expect(contentLength, greaterThan(0),
          reason:
              'Non-empty multipart request\'s content-length should be greater than 0.');
    });

    test('content-type should be set automatically', () async {
      MultipartRequest request = new MultipartRequest()
        ..uri = IntegrationPaths.reflectEndpointUri
        ..fields['field'] = 'value';
      Response response = await request.post();
      MediaType contentType = new MediaType.parse(
          response.body.asJson()['headers']['content-type']);
      expect(contentType.mimeType, equals('multipart/form-data'));
    });

    test('text fields with non-ASCII chars', () async {
      MultipartRequest request = new MultipartRequest()
        ..uri = IntegrationPaths.uploadEndpointUri
        ..fields['field'] = 'ç®å';
      await request.post();
    });

    test('uploading multiple files with different charsets', () async {
      // UTF8-encoded file.
      List<List<int>> utf8Chunks = [UTF8.encode('chunk1'), UTF8.encode('ç®å')];
      Stream<List<int>> utf8Stream = new Stream.fromIterable(utf8Chunks);
      int utf8Size = utf8Chunks[0].length + utf8Chunks[1].length;
      MediaType utf8ContentType =
          new MediaType('text', 'plain', {'charset': UTF8.name});
      MultipartFile utf8File = new MultipartFile(utf8Stream, utf8Size,
          contentType: utf8ContentType, filename: 'utf8-file');

      // LATIN1-encoded file.
      List<List<int>> latin1Chunks = [
        LATIN1.encode('chunk1'),
        LATIN1.encode('ç®å')
      ];
      Stream<List<int>> latin1Stream = new Stream.fromIterable(latin1Chunks);
      int latin1Size = latin1Chunks[0].length + latin1Chunks[1].length;
      MediaType latin1ContentType =
          new MediaType('text', 'plain', {'charset': LATIN1.name});
      MultipartFile latin1File = new MultipartFile(latin1Stream, latin1Size,
          contentType: latin1ContentType, filename: 'latin1-file');

      // ASCII-encoded file.
      List<List<int>> asciiChunks = [
        ASCII.encode('chunk1'),
        ASCII.encode('chunk2')
      ];
      Stream<List<int>> asciiStream = new Stream.fromIterable(asciiChunks);
      int asciiSize = asciiChunks[0].length + asciiChunks[1].length;
      MediaType asciiContentType =
          new MediaType('text', 'plain', {'charset': ASCII.name});
      MultipartFile asciiFile = new MultipartFile(asciiStream, asciiSize,
          contentType: asciiContentType, filename: 'ascii-file');

      MultipartRequest request = new MultipartRequest()
        ..uri = IntegrationPaths.uploadEndpointUri
        ..files['utf8File'] = utf8File
        ..files['latin1File'] = latin1File
        ..files['asciiFile'] = asciiFile;
      await request.post();
    });
  });
}
