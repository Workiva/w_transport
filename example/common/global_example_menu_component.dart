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

library w_transport.example.common.global_example_menu_component;

import 'dart:async';
import 'dart:html';

import 'package:react/react.dart' as react;
import 'package:w_transport/w_transport.dart';

const int _pollingInterval = 4; // 4 seconds

void renderGlobalExampleMenu({nav: true, serverStatus: false}) {
  // Insert a container div within which we will mount the global example menu.
  var container = document.createElement('div');
  container.id = 'global-example-menu';
  document.body.insertBefore(container, document.body.firstChild);

  // Use react to render the menu.
  var menu =
      globalExampleMenuComponent({'nav': nav, 'serverStatus': serverStatus});
  react.render(menu, container);
}

Future<bool> _ping(Uri uri) async {
  try {
    WResponse response = await WHttp.get(uri);
    return response.status == 200;
  } on WHttpException {
    return false;
  }
}

Future<bool> _pingServer() async =>
    _ping(Uri.parse('http://localhost:8024/ping'));

var globalExampleMenuComponent =
    react.registerComponent(() => new GlobalExampleMenuComponent());

class GlobalExampleMenuComponent extends react.Component {
  Timer serverPolling;

  Map getDefaultProps() {
    return {'nav': true, 'serverStatus': false};
  }

  Map getInitialState() {
    return {'serverOnline': false};
  }

  void componentWillMount() {
    if (this.props['serverStatus']) {
      _pingServer().then((bool status) {
        this.setState({'serverOnline': status});
      });
      serverPolling =
          new Timer.periodic(new Duration(seconds: 4), (Timer timer) async {
        bool status = await _pingServer();
        this.setState({'serverOnline': status});
      });
    }
  }

  void componentWillUnmount() {
    if (serverPolling != null) {
      serverPolling.cancel();
    }
  }

  _buildServerStatusComponent(String name, bool online) {
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

  render() {
    var nav;
    if (this.props['nav']) {
      nav = react.a({'href': '/'}, '\u2190 All Examples');
    }

    var serverStatus;
    if (this.props['serverStatus']) {
      serverStatus =
          _buildServerStatusComponent('Server', this.state['serverOnline']);
    }

    var serverTip;
    bool serverTipNeeded =
        this.props['serverStatus'] && !this.state['serverOnline'];
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
