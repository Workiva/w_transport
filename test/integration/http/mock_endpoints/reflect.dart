library w_transport.test.integration.http.mock_endpoints.reflect;

import 'dart:convert';

import 'package:w_transport/w_transport_mock.dart';

void mockReflectEndpoint(Uri uri) {
  MockTransports.http.when(uri, (FinalizedRequest request) async {
    Map reflection = {
      'method': request.method,
      'path': request.uri.path,
      'headers': request.headers,
    };
    return new MockResponse.ok(body: JSON.encode(reflection));
  });
}