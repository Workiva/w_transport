/*
 * Copyright 2015 Workiva Inc.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

library w_transport.test.w_http_utils;

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
      body =
          '[Response body unavailable; it was listened to during the test and cannot be listened to again]';
    }
    if (body == '' || body == null) {
      body = '[No response body]';
    }
    JsonEncoder encoder = const JsonEncoder.withIndent('\t');
    String headers = encoder.convert(response.headers);
    message += '-----------------\n' +
        'Response Details:\n' +
        '-----------------\n\n' +
        '${response.status} ${response.statusText}\n' +
        '$headers\n\n' +
        '$body\n\n' +
        '===============================================\n\n';
  }
  print(message);
}
