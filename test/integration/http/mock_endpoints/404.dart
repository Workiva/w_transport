library w_transport.test.integration.http.mock_endpoints.fourOhFour;

import 'dart:convert';

import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_mock.dart';

void mock404Endpoint(Uri uri) {
  MockTransports.http.when(
      uri, (FinalizedRequest request) async => new MockResponse.notFound());
}
