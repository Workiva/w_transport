import 'package:_test_server/servers.dart';
import 'package:dart_dev/dart_dev.dart';

final Map<String, DevTool> config = {
  ...coreConfig,
  'serve': WebdevServeTool()..buildArgs = ['web:8080'],
};
