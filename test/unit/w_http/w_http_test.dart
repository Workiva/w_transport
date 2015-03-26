import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:w_transport/w_http.dart' as w_http;


class MockHttpTransport implements w_http.HttpTransport {

  /**
   * Allow tests to easily access the most recent instance of this mock transport.
   */
  static MockHttpTransport mostRecentInstance;

  MockHttpTransport() {
    mostRecentInstance = this;
  }

  /**
   * Controls the asynchrony of the response.
   */
  Completer _completer = new Completer();
  void flush() => _completer.complete();

  /**
   * Expose the request config details for testing purpose.
   */
  Object data;
  Map<String, String> headers;
  String method;
  Uri url;

  /**
   * Mock opening an HTTP connection.
   */
  void open(String method, Uri url, [Map<String, String> headers]) {
    this.method = method;
    this.url = url;
    this.headers = headers;
  }

  /**
   * Mock sending the request.
   */
  void send([Object data]) {
    this.data = data;
  }

  /**
   * Wire the async response future to the completer.
   */
  Future get done => _completer.future;

  /**
   * Response properties.
   * Allow setters for testing purposes.
   */
  Object response;
  Map<String, String> responseHeaders;
  int status;

}


void main() {
  w_http.HttpTransportFactory transportFactory = () => new MockHttpTransport();
  w_http.WHttp req;

  group('WHttp', () {

    setUp(() {
      req = new w_http.WHttp.usingTransport(transportFactory);
    });

    test('should throw if no transport factory set', () {
      expect(() => new w_http.WHttp(), throwsStateError);
    });

    test('should require a URL', () {
      expect(req.get, throwsStateError);
    });

    test('should allow request headers to be set', () {
      req.headers = {
        'Content-Type': 'application/json',
        'X-REQUESTED-WITH': 'XMLHttpRequest'
      };
      req.header('X-XSRF-TOKEN', 'abc123');

      req.get(Uri.parse('/test')).then(expectAsync((_) {
        expect(MockHttpTransport.mostRecentInstance.headers, equals({
            'Content-Type': 'application/json',
            'X-REQUESTED-WITH': 'XMLHttpRequest',
            'X-XSRF-TOKEN': 'abc123'
        }));
      }));

      MockHttpTransport.mostRecentInstance.flush();
    });

    test('should allow data to be sent with the request', () {
      req.data = 'data';

      req.get(Uri.parse('/test')).then(expectAsync((_) {
        expect(MockHttpTransport.mostRecentInstance.data, equals('data'));
      }));

      MockHttpTransport.mostRecentInstance.flush();
    });

    test('response should be null when response is incomplete', () {
      req.get(Uri.parse('/test'));
      expect(req.response, isNull);
    });

    test('responseHeaders should be null when response is incomplete', () {
      req.get(Uri.parse('/test'));
      expect(req.responseHeaders, isNull);
    });

    test('status should be null when response is incomplete', () {
      req.get(Uri.parse('/test'));
      expect(req.status, isNull);
    });

    test('should expose the response', () {
      req.get(Uri.parse('/test')).then(expectAsync((_) {
        expect(req.response, equals('response data'));
      }));
      MockHttpTransport.mostRecentInstance
        ..response = 'response data'
        ..flush();
    });

    test('should expose the responseHeaders', () {
      req.get(Uri.parse('/test')).then(expectAsync((_) {
        expect(req.responseHeaders, equals({'Content-Type': 'application/json'}));
      }));
      MockHttpTransport.mostRecentInstance
        ..responseHeaders = {'Content-Type': 'application/json'}
        ..flush();
    });

    test('should expose the status', () {
      req.get(Uri.parse('/test')).then(expectAsync((_) {
        expect(req.status, equals(200));
      }));
      MockHttpTransport.mostRecentInstance
        ..status = 200
        ..flush();
    });

    group('should be able to send a', () {

      test('DELETE request', () {
        req.delete(Uri.parse('/resource'));
        expect(MockHttpTransport.mostRecentInstance.method, equals('DELETE'));
      });

      test('GET request', () {
        req.get(Uri.parse('/resource'));
        expect(MockHttpTransport.mostRecentInstance.method, equals('GET'));
      });

      test('HEAD request', () {
        req.head(Uri.parse('/resource'));
        expect(MockHttpTransport.mostRecentInstance.method, equals('HEAD'));
      });

      test('OPTIONS request', () {
        req.options(Uri.parse('/resource'));
        expect(MockHttpTransport.mostRecentInstance.method, equals('OPTIONS'));
      });

      test('PATCH request', () {
        req.patch(Uri.parse('/resource'), 'data');
        expect(MockHttpTransport.mostRecentInstance.method, equals('PATCH'));
        expect(MockHttpTransport.mostRecentInstance.data, equals('data'));
      });

      test('POST request', () {
        req.post(Uri.parse('/resource'), 'data');
        expect(MockHttpTransport.mostRecentInstance.method, equals('POST'));
        expect(MockHttpTransport.mostRecentInstance.data, equals('data'));
      });

      test('PUT request', () {
        req.put(Uri.parse('/resource'), 'data');
        expect(MockHttpTransport.mostRecentInstance.method, equals('PUT'));
        expect(MockHttpTransport.mostRecentInstance.data, equals('data'));
      });

      test('TRACE request', () {
        req.trace(Uri.parse('/resource'));
        expect(MockHttpTransport.mostRecentInstance.method, equals('TRACE'));
      });

    });

  });
}