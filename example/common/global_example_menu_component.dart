/**
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

library w_transport.example.common.global_example_menu_component;

import 'dart:async';
import 'dart:html';

import 'package:react/react.dart' as react;
import 'package:w_transport/w_http_client.dart';


const int _pollingInterval = 4; // 4 seconds


void renderGlobalExampleMenu({nav: true, serverStatus: false, proxyStatus: false}) {
  // Insert a container div within which we will mount the global example menu.
  var container = document.createElement('div');
  container.id = 'global-example-menu';
  document.body.insertBefore(container, document.body.firstChild);

  // Use react to render the menu.
  var menu = globalExampleMenuComponent({'nav': nav, 'serverStatus': serverStatus, 'proxyStatus': proxyStatus});
  react.render(menu, container);
}


Future<bool> _ping(Uri uri) async {
  try {
    WResponse response = await new WRequest().get(uri);
    return response.status == 200;
  } catch (e) {
    return false;
  }
}


Future<bool> _pingServer() async => _ping(Uri.parse('http://localhost:8024/ping'));
Future<bool> _pingProxy() async => _ping(Uri.parse('http://localhost:8025/ping'));


Stream _poll(Future ping(), [StreamController controller]) {
  if (controller = null) {
    controller = new StreamController();
  }

  ping().then((bool status) {
    controller.add(status);
    new Timer(new Duration(seconds: _pollingInterval), () {
      _poll(ping, controller);
    });
  });

  return controller.stream;
}


var globalExampleMenuComponent = react.registerComponent(() => new GlobalExampleMenuComponent());
class GlobalExampleMenuComponent extends react.Component {
  Timer serverPolling;
  Timer proxyPolling;

  Map getDefaultProps() {
    return {
      'nav': true,
      'serverStatus': false,
      'proxyStatus': false,
    };
  }

  Map getInitialState() {
    return {
      'serverOnline': false,
      'proxyOnline': false,
    };
  }

  void componentWillMount() {
    if (this.props['serverStatus']) {
      _pingServer().then((bool status) { this.setState({'serverOnline': status}); });
      serverPolling = new Timer.periodic(new Duration(seconds: 4), (Timer timer) async {
        bool status = await _pingServer();
        this.setState({'serverOnline': status});
      });
    }

    if (this.props['proxyStatus']) {
      _pingProxy().then((bool status) { this.setState({'proxyOnline': status}); });
      proxyPolling = new Timer.periodic(new Duration(seconds: 4), (Timer timer) async {
        bool status = await _pingProxy();
        this.setState({'proxyOnline': status});
      });
    }
  }

  void componentWillUnmount() {
    if (serverPolling != null) {
      serverPolling.cancel();
    }
    if (proxyPolling != null) {
      proxyPolling.cancel();
    }
  }

  _buildServerStatusComponent(String name, bool online) {
    String statusClass = 'server-status';
    String statusDesc = '$name offline';
    if (online) {
      statusClass += ' online';
      statusDesc = '$name online';
    }

    return react.div({'className': statusClass}, [
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
      serverStatus = _buildServerStatusComponent('Server', this.state['serverOnline']);
    }

    var proxyStatus;
    if (this.props['proxyStatus']) {
      proxyStatus = _buildServerStatusComponent('Proxy', this.state['proxyOnline']);
    }

    var serverTip;
    bool serverTipNeeded = (this.props['serverStatus'] && !this.state['serverOnline']) ||
                           (this.props['proxyStatus'] && !this.state['proxyOnline']);
    if (serverTipNeeded) {
      String tip = 'Run <code>./tool/server.sh</code> to start both the server and the proxy server.';
      serverTip = react.div({'className': 'server-status-tip muted'}, [
        react.span({}, 'Run '),
        react.code({}, './tool/server.sh'),
        react.span({}, ' to start both the server and the proxy server.'),
      ]);
    }

    return react.div({'className': 'global-example-menu'},
      react.div({'className': 'container'}, [
        nav,
        serverStatus,
        proxyStatus,
        serverTip,
      ])
    );
  }
}