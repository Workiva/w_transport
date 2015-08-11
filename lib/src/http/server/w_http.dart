library w_transport.src.http.server.w_http;

import 'dart:io';

import 'package:w_transport/src/http/common/w_http.dart';
import 'package:w_transport/src/http/server/w_request.dart';
import 'package:w_transport/src/http/w_http.dart';
import 'package:w_transport/src/http/w_request.dart';

class ServerWHttp extends CommonWHttp implements WHttp {
  ServerWHttp() {
    client = new HttpClient();
  }

  /// Generates a new [WRequest] instance. Utilizes the HttpClient
  /// in order to leverage cached connections.
  WRequest newRequest() {
    verifyNotClosed();
    return new ServerWRequest.withClient(client);
  }
}
