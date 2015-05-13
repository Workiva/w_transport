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

library w_transport.tool.server.logger;

import 'package:ansicolor/ansicolor.dart' show AnsiPen;

typedef String _Pen(String input);

_Pen _green = new AnsiPen()..green(bold: true);
_Pen _red = new AnsiPen()..red(bold: true);
_Pen _blue = new AnsiPen()..blue(bold: true);
_Pen _cyan = new AnsiPen()..cyan(bold: true);
_Pen _yellow = new AnsiPen()..yellow(bold: true);
_Pen _magenta = new AnsiPen()..magenta(bold: true);
_Pen _gray = new AnsiPen()..gray(level: 0.5);

class Logger {
  String _name;
  _Pen _pen;

  Logger(this._name, {blue: false, cyan: false, gray: false, green: false,
      magenta: false, red: false, yellow: false}) {
    if (blue) _pen = _blue;
    if (cyan) _pen = _cyan;
    if (gray) _pen = _gray;
    if (green) _pen = _green;
    if (magenta) _pen = _magenta;
    if (red) _pen = _red;
    if (yellow) _pen = _yellow;
  }

  void call(String msg, [bool isError = false]) {
    if (isError) {
      print(_pen('$_name\t[ERROR] $msg'));
    } else {
      print(_pen('$_name\t$msg'));
    }
  }
}
