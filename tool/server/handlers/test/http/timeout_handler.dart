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

  Future<void> timeout() => Completer<void>().future;

  @override
  Future<void> delete(HttpRequest request) => timeout();

  @override
  Future<void> get(HttpRequest request) => timeout();

  @override
  Future<void> head(HttpRequest request) => timeout();

  @override
  Future<void> options(HttpRequest request) => timeout();

  @override
  Future<void> patch(HttpRequest request) => timeout();

  @override
  Future<void> post(HttpRequest request) => timeout();

  @override
  Future<void> put(HttpRequest request) => timeout();

  @override
  Future<void> trace(HttpRequest request) => timeout();
}
