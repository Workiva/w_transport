import 'package:w_transport/src/transport_platform.dart';

TransportPlatform get globalTransportPlatform => _globalTransportPlatform;
set globalTransportPlatform(TransportPlatform transportPlatform) {
  if (transportPlatform == null) {
    throw new ArgumentError('w_transport: Global transport platform '
        'implementation must not be null.');
  }
  // Todo: log the transport platform implementation
  _globalTransportPlatform = transportPlatform;
}

TransportPlatform _globalTransportPlatform;
