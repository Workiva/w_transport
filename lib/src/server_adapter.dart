library w_transport.src.server_adapter;

import 'package:w_transport/src/http/server/w_http.dart';
import 'package:w_transport/src/http/server/w_request.dart';
import 'package:w_transport/src/http/w_http.dart';
import 'package:w_transport/src/http/w_request.dart';
import 'package:w_transport/src/platform_adapter.dart';

class ServerAdapter implements PlatformAdapter {
  WHttp newWHttp() => new ServerWHttp();
  WRequest newWRequest() => new ServerWRequest();
}
