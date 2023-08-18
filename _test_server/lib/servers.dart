import 'package:dart_dev/dart_dev.dart';

import 'src/server.dart';

CompoundTool withServers(DevTool tool) {
  final sockjsServer = _sockjsServer();
  return CompoundTool()
    ..addTool(DevTool.fromFunction(_streamServer), alwaysRun: true)
    ..addTool(sockjsServer.starter, alwaysRun: true)
    ..addTool(tool, argMapper: takeAllArgs)
    ..addTool(DevTool.fromFunction(_stopServer), alwaysRun: true)
    ..addTool(sockjsServer.stopper, alwaysRun: true);
}

BackgroundProcessTool _sockjsServer() => BackgroundProcessTool(
      'node',
      ['tool/sockjs.js'],
      delayAfterStart: Duration(seconds: 2),
    );

/// Server needed for integration tests and examples.
late Server _server;

/// Start the server needed for integration tests and examples and stream the
/// server output as it arrives. The output will be mixed in with output from
/// whichever task is running.
Future<int> _streamServer(_) async {
  _server = Server();
  _server.output.listen(print);
  await _server.start();
  return 0;
}

/// Stop the server needed for integration tests and examples.
Future<int> _stopServer(_) async {
  await _server.stop();
  return 0;
}
