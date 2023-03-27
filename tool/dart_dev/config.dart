import 'dart:io';

import 'package:_test_server/servers.dart';
import 'package:dart_dev/dart_dev.dart';

final Map<String, DevTool> config = {
  ...coreConfig,
  'serve': withServers(ProcessTool(
    'dart',
    ['run', 'dart_dev', 'serve'],
    mode: ProcessStartMode.inheritStdio,
    workingDirectory: 'example',
  )),
  'test': withServers(TestTool()),
};
