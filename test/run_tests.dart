import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ansicolor/ansicolor.dart' show AnsiPen;
import 'package:args/args.dart';


typedef String _Pen(String);

_Pen _greenPen = new AnsiPen()..green(bold: true);
_Pen _redPen = new AnsiPen()..red(bold: true);

const String testSuccessMessage = 'All tests passed!';
const String testFailureMessage = 'Some tests failed.';


class TestRunException implements Exception {}

Future waitFor(Process process, {String successPattern, String failurePattern, bool verbose: false}) {
  Completer completer = new Completer();

  void listenTo(Stream ioStream) {
    ioStream.transform(new Utf8Decoder()).transform(new LineSplitter()).listen((String line) {
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

void shutdown(List<Process> processesToKill) {
  processesToKill.forEach((p) {
    if (p != null) {
      p.kill(ProcessSignal.SIGINT);
    }
  });
  print('Testing failed.');
  exit(1);
}

main(List<String> args) async {
  ArgParser parser = new ArgParser();
  // Generate coverage (currently only runs VM tests).
  parser.addFlag('coverage', negatable: false);
  // Output everything.
  parser.addFlag('verbose', abbr: 'v', negatable: false);
  // Browser flags
  parser.addFlag('chrome', abbr: 'c', defaultsTo: false);
  parser.addFlag('content-shell', defaultsTo: false);
  parser.addFlag('dartium', abbr: 'd', defaultsTo: false);
  parser.addFlag('firefox', abbr: 'f', defaultsTo: false);
  parser.addFlag('safari', abbr: 's', defaultsTo: false);
  var env = parser.parse(args);

  Process server;
  Process coverage;
  Process browserTests;
  Process vmTests;

  try {
    // Start the server (necessary for integration tests).
    server = await Process.start('dart', ['--checked', 'tool/server/run.dart', '--no-proxy']);
    await waitFor(server, successPattern: 'ready - listening', verbose: env['verbose']);

    // If generating coverage, we run the tests differently
    // TODO: Hopefully clean this up when test package adds support for coverage
    if (env['coverage']) {
      // Start the coverage run.
      coverage = await Process.start('pub', ['global', 'run',  'dart_codecov_generator:generate_coverage', 'test/coverage_tests.dart']);
      print(await waitFor(coverage, successPattern: 'Coverage generated', failurePattern: 'failed', verbose: env['verbose']));
    } else {
      // Start the test runs.
      List browserTestsArgs = ['run', 'test:test', 'test/browser'];
      var browsers = ['chrome', 'content-shell', 'dartium', 'firefox', 'safari'];
      bool browserSpecified = false;
      browsers.forEach((browser) {
        if (env[browser]) {
          browserSpecified = true;
          browserTestsArgs.addAll(['-p', browser]);
        }
      });
      if (!browserSpecified) {
        browserTestsArgs.addAll(['-p', 'dartium']);
      }
      browserTests = await Process.start('pub', browserTestsArgs);
      vmTests = await Process.start('pub', ['run', 'test:test', 'test/vm']);

      // Wait for test runs to complete.
      print(await waitFor(browserTests, successPattern: testSuccessMessage, failurePattern: testFailureMessage, verbose: env['verbose']));
      print(await waitFor(vmTests, successPattern: testSuccessMessage, failurePattern: testFailureMessage, verbose: env['verbose']));
    }

    // Kill the server now that we're done.
    server.kill(ProcessSignal.SIGINT);

    // Also kill the browser test process since it doesn't exit
    // automatically when using content-shell or dartium.
    if (browserTests != null) {
      browserTests.kill(ProcessSignal.SIGINT);
    }

    // Verify success of all processes
    int serverEC = await server.exitCode;
    int coverageEC = coverage != null ? await coverage.exitCode : 0;
    int browserTestsEC = browserTests != null ? await browserTests.exitCode : 0;
    int vmTestsEC = vmTests != null ? await vmTests.exitCode : 0;

    if (serverEC > 0 || coverageEC > 0 || browserTestsEC > 0 || vmTestsEC > 0) throw new Exception('Testing failed.');

    // Success!
    print('Success!');
    exit(0);
  } on TestRunException catch (e) {
    print('Unexpected error running tests. Try running again with -v for more info.');
    shutdown([server, coverage, browserTests, vmTests]);
  } catch (e, stackTrace) {
    print('$e\n$stackTrace');
    shutdown([server, coverage, browserTests, vmTests]);
  }
}