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

/// Transport for the server. This exposes a single configuration method that
/// must be called before instantiating any of the transport classes.
///
///     import 'package:w_transport/w_transport_vm.dart'
///         show configureWTransportForServer;
///
///     void main() {
///       configureWTransportForVM();
///     }
library w_transport.w_transport_server;

import 'package:w_transport/src/platform_adapter.dart';
import 'package:w_transport/src/vm_adapter.dart';

/// Configure w_transport for use on the server via dart:io.
void configureWTransportForVM() {
  adapter = new VMAdapter();
}
