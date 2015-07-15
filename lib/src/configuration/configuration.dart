library w_transport.src.configuration;

/// Whether or not the client or server configuration has been set.
bool isConfigurationSet = false;

/// Verifies that a configuration has been set before attempting to
/// use WHttp. A [StateError] will be thrown if that's not the case.
void verifyWHttpConfigurationIsSet() {
  if (!isConfigurationSet) throw new StateError(
      'w_transport configuration must be set prior to use. ' +
          'Import \'package:w_transport/w_transport_client.dart\' ' +
          'or \'package:w_transport/w_transport_server.dart\' and call ' +
          'configureWTransportForBrowser() or configureWTransportForServer()');
}
