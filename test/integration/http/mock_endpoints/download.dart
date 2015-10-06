library w_transport.test.integration.http.mock_endpoints.download;

import 'dart:async';
import 'dart:convert';

import 'package:w_transport/w_transport_mock.dart';

void mockDownloadEndpoint(Uri uri) {
  MockTransports.http.when(uri, (_) async {
    var byteStream = new Stream.fromIterable([UTF8.encode('file')]);
    return new MockStreamedResponse.ok(byteStream: byteStream);
  });
}