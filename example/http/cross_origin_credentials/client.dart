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

import 'package:over_react/over_react.dart';
import 'package:w_transport/browser.dart' show configureWTransportForBrowser;

import '../../common/global_example_menu.dart';
import '../../common/loading_component.dart';
import './dom.dart' as dom;
import './service.dart' as service;
import './status.dart' as status;

/// Setup the example application.
Future<void> main() async {
  setClientConfiguration();
  configureWTransportForBrowser();
  renderGlobalExampleMenu(includeServerStatus: true);
  await dom.setupControlBindings();
  removeLoadingOverlay();

  // Check auth status right away to see if valid session already exists
  status.authenticated = await service.checkStatus();
  if (status.authenticated) {
    dom.updateAuthenticationStatus();
    dom.updateToggleAuthButton();
    dom.display('Logged in.', isSuccessful: true);
  }
}
