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
import 'dart:html';

import 'package:react/react.dart' as react;
import 'package:w_transport/w_transport.dart';

void renderGlobalExampleMenu(
    {bool nav: true, bool includeServerStatus: false}) {
  // Insert a container div within which we will mount the global example menu.
  final container = document.createElement('div');
  container.id = 'global-example-menu';
  document.body.insertBefore(container, document.body.firstChild);

  // Use react to render the menu.
  final menu = globalExampleMenuComponent(
      {'nav': nav, 'includeServerStatus': includeServerStatus});
  react.render(menu, container);
}

Future<bool> _ping(Uri uri) async {
  try {
    await Http.get(uri);
    return true;
  } on RequestException {
    return false;
  }
}

Future<bool> _pingServer() async =>
    _ping(Uri.parse('http://localhost:8024/ping'));

dynamic globalExampleMenuComponent =
    react.registerComponent(() => new GlobalExampleMenuComponent());

class GlobalExampleMenuComponent extends react.Component {
  Timer serverPolling;

  bool get includeServerStatus => props['includeServerStatus'];
  bool get serverOnline => state['serverOnline'];

  @override
  Map getDefaultProps() {
    return {'nav': true, 'includeServerStatus': false};
  }

  @override
  Map getInitialState() {
    return {'serverOnline': false};
  }

  @override
  void componentWillMount() {
    if (includeServerStatus) {
      _pingServer().then((status) {
        setState({'serverOnline': status});
      });
      serverPolling =
          new Timer.periodic(new Duration(seconds: 4), (Timer timer) async {
        final status = await _pingServer();
        setState({'serverOnline': status});
      });
    }
  }

  @override
  void componentWillUnmount() {
    serverPolling?.cancel();
  }

  Object _buildServerStatusComponent(String name, bool online) {
    String statusClass = 'server-status';
    String statusDesc = '$name offline';
    if (online) {
      statusClass += ' online';
      statusDesc = '$name online';
    }

    return react.div({
      'className': statusClass
    }, [
      react.div({'className': 'server-status-light'}, '\u2022'),
      react.div({'className': 'server-status-desc'}, statusDesc),
    ]);
  }

  @override
  dynamic render() {
    dynamic nav;
    if (props['nav']) {
      nav = react.a({'href': '/'}, '\u2190 All Examples');
    }

    dynamic serverStatus;
    if (includeServerStatus) {
      serverStatus = _buildServerStatusComponent('Server', serverOnline);
    }

    dynamic serverTip;
    final serverTipNeeded = includeServerStatus && !state['serverOnline'];
    if (serverTipNeeded) {
      serverTip = react.div({
        'className': 'server-status-tip muted'
      }, [
        react.span({}, 'Run `'),
        react.code({}, 'pub run dart_dev examples'),
        react.span({}, '` to serve examples with the server.'),
      ]);
    }

    return react.div({'className': 'global-example-menu'},
        react.div({'className': 'container'}, [nav, serverStatus, serverTip]));
  }
}
