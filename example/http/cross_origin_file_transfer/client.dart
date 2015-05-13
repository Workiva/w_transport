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

library w_transport.example.http.cross_origin_file_transfer.client;

import 'dart:html';

import 'package:react/react.dart' as react;
import 'package:react/react_client.dart' as react_client;
import 'package:w_transport/w_transport_client.dart'
    show configureWTransportForBrowser;

import '../../common/global_example_menu_component.dart';
import '../../common/loading_component.dart';
import './components/app_component.dart';

void main() {
  // Setup and bootstrap the react app
  react_client.setClientConfiguration();
  configureWTransportForBrowser();
  renderGlobalExampleMenu(serverStatus: true, proxyStatus: true);
  Element container = querySelector('#app');
  react.render(appComponent({}), container);
  removeLoadingOverlay();
}
