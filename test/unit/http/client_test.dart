@TestOn('vm || browser')
library w_transport.test.unit.http.w_request_test;

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_mock.dart';

void main() {
  configureWTransportForTest();

  group('Client', () {
    test('newRequest() should create a new request', () async {
      Client http = new Client();
      expect(http.newRequest(), new isInstanceOf<Request>());
    });

    test('newRequest() should throw if closed', () async {
      Client http = new Client();
      http.close();
      expect(http.newRequest, throwsStateError);
    });

    // todo replicate for other request types
  });
}
