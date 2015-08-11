library w_transport.src.platform_adapter;

import 'package:w_transport/src/http/w_http.dart';
import 'package:w_transport/src/http/w_request.dart';

PlatformAdapter adapter;

abstract class PlatformAdapter {
  static PlatformAdapter retrieve() {
    if (adapter == null) {
      throw new StateError(
          'HTTP classes cannot be used until a platform is selected.');
    }
    return adapter;
  }

  WHttp newWHttp();
  WRequest newWRequest();
}
