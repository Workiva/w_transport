import 'package:w_transport/src/transport_platform.dart';

/// The globally configured transport platform. Any transport class that is not
/// explicitly given a [TransportPlatform] instance upon construction will
/// inherit this global one.
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

/// Reset the globally configured transport platform.
void resetGlobalTransportPlatform() {
  _globalTransportPlatform = null;
}
