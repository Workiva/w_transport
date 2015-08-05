/*
 * Copyright 2015 Workiva Inc.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

library w_transport.test.run_tests;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ansicolor/ansicolor.dart' show AnsiPen;
import 'package:args/args.dart';

import '../tool/server/server.dart';

typedef String _Pen(String);

_Pen _blue = new AnsiPen()..blue();
_Pen _green = new AnsiPen()..green(bold: true);
_Pen _red = new AnsiPen()..red(bold: true);

const String testSuccessMessage = 'All tests passed!';
const String testFailureMessage = 'Some tests failed.';

class TestRunException implements Exception {}

Future waitFor(Process process,
    {String successPattern, String failurePattern, bool verbose: false}) {
  Completer completer = new Completer();

  void listenTo(Stream ioStream) {
    ioStream
        .transform(new Utf8Decoder())
        .transform(new LineSplitter())
        .listen((String line) {
      if (verbose) {
        print(line);
      }
      if (successPattern != null && line.contains(successPattern)) {
        if (!completer.isCompleted) {
          completer.complete(line);
        }
      }
      if (failurePattern != null && line.contains(failurePattern)) {
        if (!completer.isCompleted) {
          completer.completeError(line);
        }
      }
    }, onDone: () {
      if (!completer.isCompleted) {
        completer.completeError(new TestRunException());
      }
    });
  }

  listenTo(process.stdout);
  listenTo(process.stderr);

  return completer.future;
}

shutdown(List processesToKill) async {
  for (int i = 0; i < processesToKill.length; i++) {
    if (processesToKill[i] is Process) {
      processesToKill[i].kill(ProcessSignal.SIGINT);
    } else if (processesToKill[i] is Server) {
      await processesToKill[i].stop();
    }
  }
  print('Testing failed.');
  exit(1);
}

main(List<String> args) async {
  ArgParser parser = new ArgParser()
    ..addOption('platform', abbr: 'p', allowMultiple: true)
    ..addFlag('coverage', negatable: false)
    ..addFlag('only-lcov', negatable: false)
    ..addFlag('server', defaultsTo: true)
    ..addFlag('verbose', abbr: 'v', negatable: false);
  ArgResults env = parser.parse(args);

  Process coverage;
  Server server;
  Process tests;

  try {
    if (env['server']) {
      // Start the HTTP server (necessary for HTTP integration tests).
      server = new Server();
      await server.start();

      if (env['verbose']) {
        server.output.listen((m) => print(_blue('Server\t $m')));
      }
    }

    // If generating coverage, we run the tests differently
    // TODO: Hopefully clean this up when test package adds support for coverage
    if (env['coverage']) {
      // Start the coverage run.
      List coverageArgs = ['run', 'dart_codecov_generator', '--report-on=lib/'];
      if (env['verbose']) {
        coverageArgs.add('-v');
      }
      if (env['only-lcov']) {
        coverageArgs.add('--no-html');
      }
      coverage = await Process.start('pub', coverageArgs);

      // Wait for coverage to complete.
      print(await waitFor(coverage,
          successPattern: 'Coverage generated', verbose: env['verbose']));
    } else {
      // Start the test runs.
      List testArgs = ['run', 'test'];
      if (env['platform'].length > 0) {
        testArgs.addAll((env['platform'] as List).map((p) => '--platform=$p'));
      } else {
        testArgs.addAll(['-p', 'vm', '-p', 'content-shell']);
      }
      print('pub ${testArgs.join(' ')}');
      tests = await Process.start('pub', testArgs);

      // Wait for test runs to complete.
      print(await waitFor(tests,
          successPattern: testSuccessMessage,
          failurePattern: testFailureMessage,
          verbose: env['verbose']));
    }

    // Kill the servers now that we're done.
    if (server != null) {
      await server.stop();
    }

    // Verify success of all processes
    int coverageEC = coverage != null ? await coverage.exitCode : 0;
    int testsEC = tests != null ? await tests.exitCode : 0;

    if (coverageEC > 0 || testsEC > 0) throw new Exception('Testing failed.');

    // Success!
    print('Success!');
    exit(0);
  } on TestRunException catch (e) {
    print(
        'Unexpected error running tests. Try running again with -v for more info.');
    await shutdown([server, coverage, tests]);
  } catch (e, stackTrace) {
    print('$e\n$stackTrace');
    await shutdown([server, coverage, tests]);
  }
}
