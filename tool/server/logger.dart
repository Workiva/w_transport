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
