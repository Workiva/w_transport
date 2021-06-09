// @dart=2.7
// ^ Do not remove until migrated to null safety. More info at https://wiki.atl.workiva.net/pages/viewpage.action?pageId=189370832
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

import 'dart:html';

import 'package:over_react/components.dart' show ErrorBoundary;
import 'package:over_react/react_dom.dart' as react_dom;
import 'package:w_transport/browser.dart' show configureWTransportForBrowser;

import '../../common/global_example_menu.dart';
import '../../common/loading_component.dart';
import './components/app_component.dart';

void main() {
  // Setup and bootstrap the react app
  configureWTransportForBrowser();
  renderGlobalExampleMenu(includeServerStatus: true);
  Element container = querySelector('#app');
  react_dom.render(ErrorBoundary()(App()()), container);
  removeLoadingOverlay();
}
