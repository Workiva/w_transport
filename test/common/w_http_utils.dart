library w_transport.test.integration.w_http_utils;

import 'dart:async';
import 'dart:convert';


typedef Future HttpTestFn(storeResponse(response));

Function httpTest(HttpTestFn test) {
  return () async {
    var response;
    try {
      await test((resp) => response = resp);
    } catch (e, stackTrace) {
      await _logHttpTestFailure(response, e, stackTrace);
      throw e;
    }
  };
}

Future _logHttpTestFailure(response, error, stackTrace) async {
  String message = '\n\n' +
    'HTTP Test Failure:\n' +
    '==================\n\n' +
    '$error\n$stackTrace\n\n';

  if (response != null) {
    String body;
    try {
      body = await response.transform(new Utf8Decoder()).join('');
    } catch (e) {
      // Response body stream has already been listened to.
      body = '[Response body unavailable; it was listened to during the test and cannot be listened to again]';
    }
    if (body == '' || body == null) {
      body = '[No response body]';
    }
    JsonEncoder encoder = const JsonEncoder.withIndent('\t');
    String headers = encoder.convert(response.headers);
    message +=
      '-----------------\n' +
      'Response Details:\n' +
      '-----------------\n\n' +
      '${response.status} ${response.statusText}\n' +
      '$headers\n\n' +
      '$body\n\n' +
      '===============================================\n\n';
  }
  print(message);
}