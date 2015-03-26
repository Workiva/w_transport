import 'dart:async';
import 'dart:convert';
import 'dart:io';

bool debug = false;

typedef void _LineListener(String line, Process process);

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

  void run();

  void kill([ProcessSignal signal]) {
    started.then((Process process) {
      process.kill(signal != null ? signal : ProcessSignal.SIGINT);
    });
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

  void _listenForExit(Process process) {
    process.exitCode.then((int exitCode) {
      _doneCompleter.complete(exitCode);
    });
  }

  Stream<String> _lineByLine(Stream outputStream) {
    return outputStream.transform(new Utf8Decoder()).transform(new LineSplitter());
  }

  void _recordLog(String line) {
    _logs = '$logs$line\n';
  }

}

class HttpIntegrationServer extends ProcessRunner {

  HttpIntegrationServer() : super() {
    _dumpLogs = debug;
    _stdoutListener = checkForServerReady;
  }

  void run() {
    Process.start('dart', ['test/server/http_server.dart']).then(_startedCompleter.complete);
  }

  void checkForServerReady(String line, Process process) {
    if (line.contains('Server ready') && !_readyCompleter.isCompleted) {
      _readyCompleter.complete(process);
    }
  }

}

class TestRunner extends ProcessRunner {

  TestRunner() : super() {
    _dumpLogs = true;
  }

  void run() {
    Process.start('pub', ['global', 'run', 'test_runner', '-c']).then(_startedCompleter.complete);
  }

}

void main() {
  // Servers
  HttpIntegrationServer httpIntegrationServer = new HttpIntegrationServer();

  // Test runner
  TestRunner testRunner = new TestRunner();

  // Start the HTTP integration server
  print('Starting HTTP server for integration tests..');
  httpIntegrationServer.run();

  // Run the test runner when the integration servers are ready
  Future.wait([httpIntegrationServer.ready]).then((_) {
    print('Starting test runner..');
    testRunner.run();
  });

  // Cleanup when the test run is complete
  testRunner.done.then((int exitCode) {
    httpIntegrationServer.kill();
  });

  // Wait for all processes to finish before exiting
  Future.wait([httpIntegrationServer.done]).then((List<int> exitCodes) {
    testRunner.done.then((int testRunnerExitCode) {
      int httpIntegrationServerExitCode = exitCodes[0];

      // Dump HTTP integration server logs if it crashed or if tests failed
      if (testRunnerExitCode > 0 || httpIntegrationServerExitCode > 0) {
        print('HTTP Server Logs:\n');
        print(httpIntegrationServer.logs);
      }

      exit(exitCode);
    });
  });
}