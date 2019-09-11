// Copyright 2015 Workiva Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/// -----------
/// DART_DEV V3
/// -----------

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_dev/configs/workiva.dart';
import 'package:dart_dev/dart_dev.dart';
import 'package:dart_dev/utils.dart';
import 'package:logging/logging.dart';

import 'server/server.dart' show Server;

final config = {
  ...workivaConfig,

  // The `test` target runs unit tests first and then integration tests and also
  // handles starting/stopping the HTTP/WS servers required by the integration
  // tests.
  'test': withHooks(
    TestTool()..testArgs = ['-P', 'unit', '-P', 'integration'],
    before: [startTestServersTool],
    after: [stopTestServersTool],
  ),

  // The `serve` target serves the w_transport examples on :8080 and also
  // handles starting/stopping the HTTP/WS servers required by these examples.
  'serve': withHooks(
    WebdevServeTool()..webdevArgs = ['example'],
    before: [startTestServersTool],
    after: [stopTestServersTool],
  ),
};

final startTestServersTool = DartFunctionTool(startTestServers);
final stopTestServersTool = DartFunctionTool(stopTestServers);

Server _dartTestServer;
final _dartTestServerLog = Logger('TestServer');
Process _sockjsTestServer;
final _sockjsTestServerLog = Logger('SockjsServer');

Future<int> startTestServers(_) async {
  await logTimedAsync(_dartTestServerLog, 'Starting HTTP/WS test server',
      () async {
    _dartTestServer = Server();
    _dartTestServer.output.listen(_dartTestServerLog.fine);
    await _dartTestServer.start();
  });

  await logTimedAsync(_sockjsTestServerLog, 'Starting SockJS test server',
      () async {
    _sockjsTestServer = await Process.start('node', ['tool/server/sockjs.js'],
        mode: ProcessStartMode.detachedWithStdio);
    _sockjsTestServer.stdout
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .listen(_sockjsTestServerLog.fine);
    _sockjsTestServer.stderr
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .listen(_sockjsTestServerLog.fine);
  });

  // Wait a short amount of time to prevent the servers from missing anything.
  await Future<void>.delayed(Duration(milliseconds: 500));

  return 0;
}

Future<int> stopTestServers(_) async {
  _sockjsTestServer?.kill();
  _sockjsTestServer = null;
  await _dartTestServer?.stop();
  _dartTestServer = null;

  return 0;
}
