library w_transport.test.unit.http.request_progress_test;

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';

void main() {
  group('RequestProgress', () {
    test('lengthComputable should be true if total is known', () {
      RequestProgress prog = new RequestProgress(10, 100);
      expect(prog.lengthComputable, isTrue);
    });

    test('lengthComputable should be false if total is unknown', () {
      RequestProgress prog = new RequestProgress(10);
      expect(prog.lengthComputable, isFalse);
    });

    test('percent should be calculcated', () {
      RequestProgress prog = new RequestProgress(10, 100);
      expect(prog.percent, equals(10.0));
    });

    test('percent should be 0.0 if length is not computable', () {
      RequestProgress prog = new RequestProgress(10);
      expect(prog.percent, equals(0.0));
    });
  });
}
