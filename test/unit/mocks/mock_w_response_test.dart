@TestOn('vm || browser')
library w_transport.test.unit.mocks.mock_w_response_test;

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_mock.dart';

void main() {
  test('MockWResponse custom constructor', () async {
    WResponse response = new MockWResponse(100,
        statusText: 'custom', headers: {'x-custom': 'value'}, body: 'data');
    expect(response.status, equals(100));
    expect(response.statusText, equals('custom'));
    expect(response.headers['x-custom'], equals('value'));
    expect(await response.asText(), equals('data'));
  });

  test('MockWResponse.ok() 200', () {
    WResponse response = new MockWResponse.ok();
    expect(response.status, equals(200));
    expect(response.statusText, equals('OK'));
  });

  test('MockWResponse.badRequest() 400', () {
    WResponse response = new MockWResponse.badRequest();
    expect(response.status, equals(400));
    expect(response.statusText, equals('BAD REQUEST'));
  });

  test('MockWResponse.unauthorized() 401', () {
    WResponse response = new MockWResponse.unauthorized();
    expect(response.status, equals(401));
    expect(response.statusText, equals('UNAUTHORIZED'));
  });

  test('MockWResponse.forbidden() 403', () {
    WResponse response = new MockWResponse.forbidden();
    expect(response.status, equals(403));
    expect(response.statusText, equals('FORBIDDEN'));
  });

  test('MockWResponse.notFound() 404', () {
    WResponse response = new MockWResponse.notFound();
    expect(response.status, equals(404));
    expect(response.statusText, equals('NOT FOUND'));
  });

  test('MockWResponse.methodNotAllowed() 405', () {
    WResponse response = new MockWResponse.methodNotAllowed();
    expect(response.status, equals(405));
    expect(response.statusText, equals('METHOD NOT ALLOWED'));
  });

  test('MockWResponse.internalServerError() 500', () {
    WResponse response = new MockWResponse.internalServerError();
    expect(response.status, equals(500));
    expect(response.statusText, equals('INTERNAL SERVER ERROR'));
  });

  test('MockWResponse.notImplemented() 501', () {
    WResponse response = new MockWResponse.notImplemented();
    expect(response.status, equals(501));
    expect(response.statusText, equals('NOT IMPLEMENTED'));
  });

  test('MockWResponse.badGateway() 502', () {
    WResponse response = new MockWResponse.badGateway();
    expect(response.status, equals(502));
    expect(response.statusText, equals('BAD GATEWAY'));
  });
}
