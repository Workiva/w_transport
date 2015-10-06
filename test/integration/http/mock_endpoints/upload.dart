library w_transport.test.integration.http.mock_endpoints.upload;

import 'dart:convert';

import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_mock.dart';

void mockUploadEndpoint(Uri uri) {
  MockTransports.http.when(uri, (FinalizedRequest request) async {
    await (request.body as StreamedHttpBody).byteStream.drain();
    return new MockResponse.ok();
  });
}
