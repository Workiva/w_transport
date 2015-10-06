@TestOn('browser')
library w_transport.test.integration.platforms.browser_platform_test;

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_browser.dart';

import 'package:w_transport/src/http/browser/client.dart';
import 'package:w_transport/src/http/browser/requests.dart';

void main() {
  group('Browser platform adapter', () {

    setUp(() {
      configureWTransportForBrowser();
    });

    test('newClient()', () {
      expect(new Client(), new isInstanceOf<BrowserClient>());
    });

    test('newFormRequest()', () {
      expect(new FormRequest(), new isInstanceOf<BrowserFormRequest>());
    });

    test('newJsonRequest()', () {
      expect(new JsonRequest(), new isInstanceOf<BrowserJsonRequest>());
    });

    test('newMultipartRequest()', () {
      expect(new MultipartRequest(), new isInstanceOf<BrowserMultipartRequest>());
    });

    test('newRequest()', () {
      expect(new Request(), new isInstanceOf<BrowserPlainTextRequest>());
    });

    test('newStreamedRequest()', () {
      expect(new StreamedRequest(), new isInstanceOf<BrowserStreamedRequest>());
    });

  });
}