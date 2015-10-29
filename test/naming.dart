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

library w_transport.test.naming;

/// Platforms.
const String platformBrowser = 'browser';
const String platformMock = 'mock';
const String platformVM = 'vm';

/// Integration test group names.
const String integrationHttpBrowser = '[integration] HTTP ($platformBrowser)';
const String integrationHttpMock = '[integration] HTTP ($platformMock)';
const String integrationHttpVM = '[integration] HTTP ($platformVM)';
const String integrationWebSocketBrowser =
    '[integration] WS ($platformBrowser)';
const String integrationWebSocketMock = '[integration] WS ($platformMock)';
const String integrationWebSocketVM = '[integration] WS ($platformVM)';

/// Unit test group names.
const String unitHttpBrowser = '[unit] HTTP ($platformBrowser)';
const String unitHttpMock = '[unit] HTTP ($platformMock)';
const String unitHttpVM = '[unit] HTTP ($platformVM)';
const String unitWebSocketBrowser = '[unit] WS ($platformBrowser)';
const String unitWebSocketMock = '[unit] WS ($platformMock)';
const String unitWebSocketVM = '[unit] WS ($platformVM)';
