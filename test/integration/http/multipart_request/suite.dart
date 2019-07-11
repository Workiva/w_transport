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
import 'package:w_transport/w_transport.dart' as transport;

import '../../integration_paths.dart';

void runMultipartRequestSuite([transport.TransportPlatform transportPlatform]) {
  group('MultipartRequest', () {
    test('contentLength should be set automatically', () async {
      final chunks = <List<int>>[
        utf8.encode('chunk1'),
        utf8.encode('chunk2'),
        utf8.encode('chunk2'),
        utf8.encode('chunk3')
      ];
      int size = 0;
      for (final chunk in chunks) {
        size += chunk.length;
      }
      final fileStream = Stream.fromIterable(chunks);
      final file = transport.MultipartFile(fileStream, size);

      final request =
          transport.MultipartRequest(transportPlatform: transportPlatform)
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
      final request =
          transport.MultipartRequest(transportPlatform: transportPlatform)
            ..uri = IntegrationPaths.reflectEndpointUri
            ..fields['field'] = 'value';
      final response = await request.post();
      final contentType =
          MediaType.parse(response.body.asJson()['headers']['content-type']);
      expect(contentType.mimeType, equals('multipart/form-data'));
    });

    test('text fields with non-ASCII chars', () async {
      final request =
          transport.MultipartRequest(transportPlatform: transportPlatform)
            ..uri = IntegrationPaths.uploadEndpointUri
            ..fields['field'] = 'ç®å';
      await request.post();
    });

    test('uploading multiple files with different charsets', () async {
      // UTF8-encoded file.
      final utf8Chunks = <List<int>>[utf8.encode('chunk1'), utf8.encode('ç®å')];
      final utf8Stream = Stream.fromIterable(utf8Chunks);
      final utf8Size = utf8Chunks[0].length + utf8Chunks[1].length;
      final utf8ContentType =
          MediaType('text', 'plain', {'charset': utf8.name});
      final utf8File = transport.MultipartFile(utf8Stream, utf8Size,
          contentType: utf8ContentType, filename: 'utf8-file');

      // LATIN1-encoded file.
      final latin1Chunks = <List<int>>[
        latin1.encode('chunk1'),
        latin1.encode('ç®å')
      ];
      final latin1Stream = Stream.fromIterable(latin1Chunks);
      final latin1Size = latin1Chunks[0].length + latin1Chunks[1].length;
      final latin1ContentType =
          MediaType('text', 'plain', {'charset': latin1.name});
      final latin1File = transport.MultipartFile(latin1Stream, latin1Size,
          contentType: latin1ContentType, filename: 'latin1-file');

      // ASCII-encoded file.
      final asciiChunks = <List<int>>[
        ascii.encode('chunk1'),
        ascii.encode('chunk2')
      ];
      final asciiStream = Stream.fromIterable(asciiChunks);
      final asciiSize = asciiChunks[0].length + asciiChunks[1].length;
      final asciiContentType =
          MediaType('text', 'plain', {'charset': ascii.name});
      final asciiFile = transport.MultipartFile(asciiStream, asciiSize,
          contentType: asciiContentType, filename: 'ascii-file');

      final request =
          transport.MultipartRequest(transportPlatform: transportPlatform)
            ..uri = IntegrationPaths.uploadEndpointUri
            ..files['utf8File'] = utf8File
            ..files['latin1File'] = latin1File
            ..files['asciiFile'] = asciiFile;
      await request.post();
    });
  });
}
