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
import 'dart:io';

import '../../../handler.dart';

/// Never closes the request.
class TimeoutHandler extends Handler {
  TimeoutHandler() : super() {
    enableCors();
  }

  // NOTE: The `options` handler is intentionally not implemented to timeout
  // like the other handlers because in the browser an OPTIONS request might be
  // made by the browser before the actual request. We want the OPTIONS request
  // to return successfully so that the browser can make the actual request,
  // and then we can timeout the actual request.

  Future<Null> timeout() => Completer<Null>().future;

  @override
  Future<Null> delete(HttpRequest request) => timeout();

  @override
  Future<Null> get(HttpRequest request) => timeout();

  @override
  Future<Null> head(HttpRequest request) => timeout();

  @override
  Future<Null> patch(HttpRequest request) => timeout();

  @override
  Future<Null> post(HttpRequest request) => timeout();

  @override
  Future<Null> put(HttpRequest request) => timeout();

  @override
  Future<Null> trace(HttpRequest request) => timeout();
}
