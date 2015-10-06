@TestOn('vm')
library w_transport.test.integration.platforms.vm_platform_test;

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_vm.dart';

import 'package:w_transport/src/http/vm/client.dart';
import 'package:w_transport/src/http/vm/requests.dart';

void main() {
  group('Browser platform adapter', () {

    setUp(() {
      configureWTransportForVM();
    });

    test('newClient()', () {
      expect(new Client(), new isInstanceOf<VMClient>());
    });

    test('newFormRequest()', () {
      expect(new FormRequest(), new isInstanceOf<VMFormRequest>());
    });

    test('newJsonRequest()', () {
      expect(new JsonRequest(), new isInstanceOf<VMJsonRequest>());
    });

    test('newMultipartRequest()', () {
      expect(new MultipartRequest(), new isInstanceOf<VMMultipartRequest>());
    });

    test('newRequest()', () {
      expect(new Request(), new isInstanceOf<VMPlainTextRequest>());
    });

    test('newStreamedRequest()', () {
      expect(new StreamedRequest(), new isInstanceOf<VMStreamedRequest>());
    });

  });
}