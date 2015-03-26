import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ansicolor/ansicolor.dart' show AnsiPen;


typedef void _LineListener(String line, Process process);
typedef String _Pen(String input);

bool debug = false;

_Pen _greenPen = new AnsiPen()..green(bold: true);
_Pen _redPen = new AnsiPen()..red(bold: true);


abstract class ProcessRunner {

  _LineListener _stdoutListener;
  _LineListener _stderrListener;

  bool _storeLogs = true;
  bool _dumpLogs = debug;

  String _logs = '';
  String get logs => _logs;

  Completer<Process> _startedCompleter;
  Completer<Process> _readyCompleter;
  Completer<int> _doneCompleter;

  Future<Process> get started => _startedCompleter.future;
  Future<Process> get ready => _readyCompleter.future;
  Future<int> get done => _doneCompleter.future;

  ProcessRunner() {
    _storeLogs = true;
    _dumpLogs = true;

    _logs = '';

    _startedCompleter = new Completer<Process>();
    _readyCompleter = new Completer<Process>();
    _doneCompleter = new Completer<int>();

    started.then(_addProcessListeners);
    started.then(_listenForExit);
  }

  Future run();

  Future<bool> kill([ProcessSignal signal]) async {
    Process process = await started;
    return process.kill(signal != null ? signal : ProcessSignal.SIGINT);
  }

  void _addProcessListeners(Process process) {
    _lineByLine(process.stdout).listen((String line) {
      if (_stdoutListener != null) {
        _stdoutListener(line, process);
      }
      if (_storeLogs) {
        _recordLog(line);
      }
      if (_dumpLogs) {
        print(line);
      }
    });

    _lineByLine(process.stderr).listen((String line) {
      if (_stderrListener != null) {
        _stderrListener(line, process);
      }
      if (_storeLogs) {
        _recordLog(line);
      }
      if (_dumpLogs) {
        print(line);
      }
    });
  }

  Future _listenForExit(Process process) async {
    int ec = await process.exitCode;
    _doneCompleter.complete(ec);
  }

  Stream<String> _lineByLine(Stream outputStream) {
    return outputStream.transform(new Utf8Decoder()).transform(new LineSplitter());
  }

  void _recordLog(String line) {
    _logs = '$logs$line\n';
  }

}

class IntegrationServer extends ProcessRunner {

  IntegrationServer() : super() {
    _dumpLogs = debug;
    _stdoutListener = checkForServerReady;
  }

  Future run() async {
    _startedCompleter.complete(await Process.start('dart', ['--checked', 'tool/server/run.dart', '--no-proxy']));
    done.then((ec) {
      if (!_readyCompleter.isCompleted) {
        _readyCompleter.completeError(ec);
      }
    });
  }

  void checkForServerReady(String line, Process process) {
    if (line.contains('ready - listening') && !_readyCompleter.isCompleted) {
      _readyCompleter.complete(process);
    }
  }

}

class TestRunner extends ProcessRunner {

  TestRunner() : super() {
    _dumpLogs = true;
  }

  Future run() async {
    _startedCompleter.complete(await Process.start('pub', ['global', 'run', 'test_runner', '-c']));
  }

}

main() async {
  // Servers
  IntegrationServer integrationServer = new IntegrationServer();

  // Test runner
  TestRunner testRunner = new TestRunner();

  // Start the HTTP integration server
  print('Starting HTTP server for integration tests...');
  await integrationServer.run();

  // Run the test runner when the integration servers are ready
  try {
    await integrationServer.ready;
    print(_greenPen('HTTP server running.'));
    print('\nStarting test runner..');
    testRunner.run();
  } catch (ec) {
    print(integrationServer.logs);
    exit(ec);
  }

  // Cleanup when the test run is complete
  await testRunner.done;
  await integrationServer.kill();

  // Wait for all processes to finish before exiting
  List<int> exitCodes = await Future.wait([integrationServer.done, testRunner.done]);
  int httpIntegrationServerExitCode = exitCodes[0];
  int testRunnerExitCode = exitCodes[1];

  // Dump HTTP integration server logs if it crashed or if tests failed
  if (testRunnerExitCode > 0 || httpIntegrationServerExitCode > 0) {
    print('HTTP Server Logs:\n');
    print(integrationServer.logs);
  }

  exitCode = testRunnerExitCode;
}