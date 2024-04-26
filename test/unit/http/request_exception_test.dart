@TestOn('vm || browser')
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:w_transport/mock.dart';
import 'package:w_transport/src/http/auto_retry.dart';
import 'package:w_transport/src/http/base_request.dart';
import 'package:w_transport/w_transport.dart' as transport;

import '../../naming.dart';

void main() {
  final naming = Naming()
    ..testType = testTypeUnit
    ..topic = topicHttp;

  group(naming.toString(), () {
    group('RequestException', () {
      test('should include the method and URI if given', () {
        final request = MockRequest();

        final exception = transport.RequestException(
            'POST', Uri.parse('/path'), request, null);
        expect(exception.toString(), contains('POST'));
        expect(exception.toString(), contains('/path'));
      });

      test('should include the response status and text if given', () {
        final response = MockResponse.ok();
        final request = MockRequest();
        final exception = transport.RequestException(
            'GET', Uri.parse('/'), request, response);
        expect(exception.toString(), contains('200 OK'));
      });

      test('should include the original error if given', () {
        final request = MockRequest();

        final exception = transport.RequestException(
            'GET', Uri.parse('/'), request, null, Exception('original'));
        expect(exception.toString(), contains('original'));
      });
    });
  });
}

// Update MockRequest class to implement BaseRequest
class MockRequest extends Mock implements BaseRequest {
  @override
  RequestAutoRetry get autoRetry => RequestAutoRetry(this);
}
