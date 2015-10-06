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

library w_transport.tool.server.handlers.ping_handler;

import 'dart:async';
import 'dart:io';

import '../../../handler.dart';

/// Never closes the request.
class TimeoutHandler extends Handler {
  TimeoutHandler() : super() {
    enableCors();
  }

  Future timeout() => new Completer().future;

  Future delete(HttpRequest request) => timeout();
  Future get(HttpRequest request) => timeout();
  Future head(HttpRequest request) => timeout();
  Future options(HttpRequest request) => timeout();
  Future patch(HttpRequest request) => timeout();
  Future post(HttpRequest request) => timeout();
  Future put(HttpRequest request) => timeout();
  Future trace(HttpRequest request) => timeout();
}
