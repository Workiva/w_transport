library w_transport.test.integration.http.mock_endpoints.timeout;

import 'dart:async';

import 'package:w_transport/w_transport_mock.dart';

void mockTimeoutEndpoint(Uri uri) {
  MockTransports.http.when(uri, (_) async {
    return new Completer().future;
  });
}

