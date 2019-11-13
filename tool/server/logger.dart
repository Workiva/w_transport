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

import 'dart:async';
import 'dart:io';

class Logger implements Function {
  StreamController<String> _controller = new StreamController<String>();

  Logger();

  Stream get stream => _controller.stream;

  void call(String message, {bool isError = false}) {
    if (isError) {
      _controller.add('[ERROR] $message');
    } else {
      _controller.add('$message');
    }
  }

  Future<Null> close() async {
    await _controller.close();
  }

  void logError(Object error, [StackTrace stackTrace]) {
    final e = stackTrace != null ? '$error\n$stackTrace' : '$error';
    this(e, isError: true);
  }

  void logRequest(HttpRequest request) {
    final time = new DateTime.now();
    this(
        '$time\t${request.method}\t${request.response.statusCode}\t${request.uri.path}');
  }

  void withTime(String msg, {bool isError = false}) {
    this('${new DateTime.now()}  $msg', isError: isError);
  }
}
