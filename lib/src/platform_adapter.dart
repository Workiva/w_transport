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

library w_transport.src.platform_adapter;

import 'dart:async';

import 'package:w_transport/w_transport.dart';

/// The currently selected platform adapter. Will be set by the configuration
/// methods exposed in the platform-specific entry points:
///
/// - w_transport/w_transport_browser.dart
/// - w_transport/w_transport_mock.dart
/// - w_transport/w_transport_server.dart
PlatformAdapter adapter;

/// Defines how to construct the appropriate class instances for a certain
/// platform. The platform-agnostic API in w_transport is created by exposing
/// several public abstract classes:
///
/// - [Client]
/// - [FormRequest]
/// - [JsonRequest]
/// - [MultipartRequest]
/// - [Request]
/// - [StreamedRequest]
/// - [WSocket]
///
/// These classes remain platform-agnostic by using a [PlatformAdapter] instance
/// to construct their appropriate platform-specific implementations.
abstract class PlatformAdapter {

  /// Retrieve the currently configured platform adapter. This effectively
  /// defers the platform selection until absolutely necessary - when a
  /// transport class needs to be instantiated. In other words, this allows
  /// libraries to build platform-agnostic APIs on top of w_transport so long as
  /// the consumer selects the platform before any transport classes are
  /// actually instantiated.
  static PlatformAdapter retrieve() {
    if (adapter == null) {
      throw new StateError(
          'HTTP classes cannot be used until a platform is selected.');
    }
    return adapter;
  }

  /// Constructs a new [Client] instance.
  Client newClient();

  /// Constructs a new [FormRequest] instance.
  FormRequest newFormRequest();

  /// Constructs a new [JsonRequest] instance.
  JsonRequest newJsonRequest();

  /// Constructs a new [MultipartRequest] instance.
  MultipartRequest newMultipartRequest();

  /// Constructs a new [Request] instance.
  Request newRequest();

  /// Constructs a new [StreamedRequest] instance.
  StreamedRequest newStreamedRequest();

  /// Constructs a new [WSocket] instance.
  Future<WSocket> newWSocket(Uri uri,
      {Iterable<String> protocols, Map<String, dynamic> headers});
}
