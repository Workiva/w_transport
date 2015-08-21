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

library w_transport.src.http.common.w_http;

class CommonWHttp {
  /// HTTP client used to create and send HTTP requests.
  /// In the browser, this will be unnecessary.
  /// On the server, this will be an instance of [HttpClient].
  dynamic client;

  /// Whether or not this HTTP client has been closed.
  bool isClosed = false;

  /// Closes the client, cancelling or closing any outstanding connections.
  void close() {
    if (isClosed) return;
    isClosed = true;
    if (client != null) {
      client.close();
    }
  }

  /// Throws a [StateError] if this client has been closed.
  void verifyNotClosed() {
    if (isClosed) throw new StateError(
        'WHttp client has been closed, can\'t create a new request.');
  }
}
