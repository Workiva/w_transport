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

library w_transport.src.web_socket.w_socket_close_event;

/// Represents the close event from a WebSocket.
///
/// This was previously only used internally, but was erroneously exported as a
/// part of the public API. It is no longer used at all, and has thus been
/// deprecated and will be removed in 3.0.0.
@Deprecated('in 3.0.0')
class WSocketCloseEvent {
  final int code;
  final String reason;
  WSocketCloseEvent(this.code, this.reason);
}
