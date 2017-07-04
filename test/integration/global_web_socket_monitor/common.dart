import 'dart:async';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart'
    show WSocket, WebSocketConnectEvent;

import '../integration_paths.dart';

void runCommonGlobalWebSocketMonitorIntegrationTests(
    {Future<WSocket> connect(Uri uri), int port}) {
  if (connect == null) {
    connect = (uri) => WSocket.connect(uri);
  }
  var closeUri = IntegrationPaths.closeUri;
  var echoUri = IntegrationPaths.echoUri;
  var fourOhFourUri = IntegrationPaths.fourOhFourUri;
  var pingUri = IntegrationPaths.pingUri;
  if (port != null) {
    closeUri = closeUri.replace(port: port);
    echoUri = echoUri.replace(port: port);
    pingUri = pingUri.replace(port: port);
  }

  test('should support multiple monitors, each of which can be closed',
      () async {
    // First connection attempt - no monitors.
    var webSocket1 = await connect(closeUri);
    await webSocket1.close();

    var monitor1 = WSocket.getGlobalEventMonitor();
    var monitor1Events = <WebSocketConnectEvent>[];
    monitor1.didAttemptToConnect.listen(monitor1Events.add);

    // Second connection attempt - monitor 1 should receive it.
    var webSocket2 = await connect(echoUri);
    await webSocket2.close();

    var monitor2 = WSocket.getGlobalEventMonitor();
    var monitor2Events = <WebSocketConnectEvent>[];
    monitor2.didAttemptToConnect.listen(monitor2Events.add);

    // Third connection attempt - monitors 1 & 2 should both receive it.
    var webSocket3 = await connect(pingUri);
    await webSocket3.close();

    await monitor2.close();

    // Fourth connection attempt - only monitor 1 should receive it.
    await connect(fourOhFourUri).catchError((_) {});

    await monitor1.close();

    expect(monitor1Events.length, equals(3));
    expect(monitor2Events.length, equals(1));

    expect(monitor1Events[0].url, equals(echoUri.toString()));
    expect(monitor1Events[0].wasSuccessful, isTrue);

    expect(monitor1Events[1].url, equals(pingUri.toString()));
    expect(monitor1Events[1].wasSuccessful, isTrue);
    expect(monitor2Events[0].url, equals(pingUri.toString()));
    expect(monitor2Events[0].wasSuccessful, isTrue);

    expect(monitor1Events[2].url, equals(fourOhFourUri.toString()));
    expect(monitor1Events[2].wasSuccessful, isFalse);
  });
}
