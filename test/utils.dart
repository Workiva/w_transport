library w_transport.test.utils;

import 'dart:async';

import 'package:test/test.dart';

Future<Object> expectThrowsAsync(Future f()) async {
  var exception;
  try {
    await f();
  } catch (e) {
    exception = e;
  }
  if (exception == null) throw new Exception(
      'Expected function to throw asynchronously, but did not.');
  return exception;
}
