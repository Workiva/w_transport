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

import '../../../handler.dart';
import '404_handler.dart';
import 'custom.dart';
import 'download.dart';
import 'echo.dart';
import 'error.dart';
import 'ping_handler.dart';
import 'reflect_handler.dart';
import 'timeout_handler.dart';
import 'upload.dart';

String pathPrefix = '/test/http';
Map<String, Handler> testHttpIntegrationRoutes = {
  '$pathPrefix/404': new FourzerofourHandler(),
  '$pathPrefix/custom': new CustomHandler(),
  '$pathPrefix/download': new DownloadHandler(),
  '$pathPrefix/echo': new EchoHandler(),
  '$pathPrefix/error': new ErrorHandler(),
  '$pathPrefix/ping': new PingHandler(),
  '$pathPrefix/reflect': new ReflectHandler(),
  '$pathPrefix/timeout': new TimeoutHandler(),
  '$pathPrefix/upload': new UploadHandler(),
};
