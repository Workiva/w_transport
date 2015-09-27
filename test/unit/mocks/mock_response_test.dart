@TestOn('vm || browser')
library w_transport.test.unit.mocks.mock_w_response_test;

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_mock.dart';

void main() {
  test('MockWResponse custom constructor', () async {
    Response response = new MockResponse(100,
        statusText: 'custom', headers: {'x-custom': 'value'}, body: 'data');
    expect(response.status, equals(100));
    expect(response.statusText, equals('custom'));
    expect(response.headers['x-custom'], equals('value'));
    expect(response.body.asString(), equals('data'));
  });

  test('MockWResponse.ok() 200', () {
    Response response = new MockResponse.ok();
    expect(response.status, equals(200));
    expect(response.statusText, equals('OK'));
  });

  test('MockWResponse.badRequest() 400', () {
    Response response = new MockResponse.badRequest();
    expect(response.status, equals(400));
    expect(response.statusText, equals('BAD REQUEST'));
  });

  test('MockWResponse.unauthorized() 401', () {
    Response response = new MockResponse.unauthorized();
    expect(response.status, equals(401));
    expect(response.statusText, equals('UNAUTHORIZED'));
  });

  test('MockWResponse.forbidden() 403', () {
    Response response = new MockResponse.forbidden();
    expect(response.status, equals(403));
    expect(response.statusText, equals('FORBIDDEN'));
  });

  test('MockWResponse.notFound() 404', () {
    Response response = new MockResponse.notFound();
    expect(response.status, equals(404));
    expect(response.statusText, equals('NOT FOUND'));
  });

  test('MockWResponse.methodNotAllowed() 405', () {
    Response response = new MockResponse.methodNotAllowed();
    expect(response.status, equals(405));
    expect(response.statusText, equals('METHOD NOT ALLOWED'));
  });

  test('MockWResponse.internalServerError() 500', () {
    Response response = new MockResponse.internalServerError();
    expect(response.status, equals(500));
    expect(response.statusText, equals('INTERNAL SERVER ERROR'));
  });

  test('MockWResponse.notImplemented() 501', () {
    Response response = new MockResponse.notImplemented();
    expect(response.status, equals(501));
    expect(response.statusText, equals('NOT IMPLEMENTED'));
  });

  test('MockWResponse.badGateway() 502', () {
    Response response = new MockResponse.badGateway();
    expect(response.status, equals(502));
    expect(response.statusText, equals('BAD GATEWAY'));
  });
}
