library w_transport.src.client_adapter;

import 'package:w_transport/src/http/client/w_http.dart';
import 'package:w_transport/src/http/client/w_request.dart';
import 'package:w_transport/src/http/w_http.dart';
import 'package:w_transport/src/http/w_request.dart';
import 'package:w_transport/src/platform_adapter.dart';

class ClientAdapter implements PlatformAdapter {
  WHttp newWHttp() => new ClientWHttp();
  WRequest newWRequest() => new ClientWRequest();
}
