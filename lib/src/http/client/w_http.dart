library w_transport.src.http.client.w_http;

import 'package:w_transport/src/http/client/w_request.dart';
import 'package:w_transport/src/http/common/w_http.dart';
import 'package:w_transport/src/http/w_http.dart';
import 'package:w_transport/src/http/w_request.dart';

class ClientWHttp extends CommonWHttp implements WHttp {
  /// Generates a new [WRequest] instance. There's no concept
  /// of an HTTP client in the browser, so a regular request
  /// is used here.
  WRequest newRequest() {
    verifyNotClosed();
    return new ClientWRequest();
  }
}
