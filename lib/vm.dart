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
///     import 'package:w_transport/vm.dart'
///         show configureWTransportForVM;
///
///     void main() {
///       configureWTransportForVM();
///     }
library w_transport.vm;

import 'package:w_transport/src/global_transport_platform.dart';
import 'package:w_transport/src/vm_transport_platform.dart';

export 'package:w_transport/src/vm_transport_platform.dart'
    show VMTransportPlatform, vmTransportPlatform;

/// Configure w_transport for use on the server via dart:io.
void configureWTransportForVM() {
  globalTransportPlatform = vmTransportPlatform;
}
