library w_transport.test.naming;

/// Platforms.
const String platformBrowser = 'browser';
const String platformMock = 'mock';
const String platformVM = 'vm';

/// Integration test group names.
const String integrationHttpBrowser = '[integration] HTTP ($platformBrowser)';
const String integrationHttpMock = '[integration] HTTP ($platformMock)';
const String integrationHttpVM = '[integration] HTTP ($platformVM)';
const String integrationWebSocketBrowser = '[integration] WS ($platformBrowser)';
const String integrationWebSocketMock = '[integration] WS ($platformMock)';
const String integrationWebSocketVM = '[integration] WS ($platformVM)';

/// Unit test group names.
const String unitHttpBrowser = '[unit] HTTP ($platformBrowser)';
const String unitHttpMock = '[unit] HTTP ($platformMock)';
const String unitHttpVM = '[unit] HTTP ($platformVM)';
const String unitWebSocketBrowser = '[unit] WS ($platformBrowser)';
const String unitWebSocketMock = '[unit] WS ($platformMock)';
const String unitWebSocketVM = '[unit] WS ($platformVM)';
