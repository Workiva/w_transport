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

import '../../../handler.dart';
import '../../../logger.dart';

class CloseHandler extends WebSocketHandler {
  Logger _logger;

  CloseHandler(Logger this._logger) : super() {
    enableCors();
  }

  void onConnection(webSocket) {
    webSocket.listen((message) {
      if (message.startsWith('close')) {
        var parts = message.split(':');
        var closeCode;
        var closeReason;
        if (parts.length >= 2) {
          closeCode = int.parse(parts[1]);
        }
        if (parts.length >= 3) {
          closeReason = parts[2];
        }
        webSocket.close(closeCode, closeReason);
        _logger.withTime(' \t WS \tConnection closed by request.');
      } else {
        _logger.withTime(' \t WS \tInvalid close request.', true);
      }
    });
  }
}
