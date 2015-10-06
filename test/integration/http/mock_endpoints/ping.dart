library w_transport.test.integration.http.mock_endpoints.ping;

import 'dart:async';

import 'package:w_transport/w_transport_mock.dart';

void mockPingEndpoint(Uri uri) {
  MockTransports.http.when(uri, (_) async {
    return new MockResponse.ok();
  });
}
