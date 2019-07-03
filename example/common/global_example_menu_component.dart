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

import 'package:over_react/over_react.dart';
import 'package:w_transport/w_transport.dart';

// ignore: uri_has_not_been_generated
part 'global_example_menu_component.over_react.g.dart';

Future<bool> _ping(Uri uri) async {
  try {
    await Http.get(uri);
    return true;
  } on RequestException {
    return false;
  }
}

Future<bool> _pingServer() async =>
    _ping(Uri.parse('http://localhost:8024/ping'));

@Factory()
// ignore: undefined_identifier
UiFactory<GlobalExampleMenuProps> GlobalExampleMenu =
    // ignore: undefined_identifier
    _$GlobalExampleMenu;

@Props()
class _$GlobalExampleMenuProps extends UiProps {
  bool nav;
  bool includeServerStatus;
}

@State()
class _$GlobalExampleMenuState extends UiState {
  bool serverOnline;
}

@Component()
class GlobalExampleMenuComponent extends UiStatefulComponent<
    GlobalExampleMenuProps, GlobalExampleMenuState> {
  Timer serverPolling;

  @override
  Map getDefaultProps() => newProps()
    ..nav = true
    ..includeServerStatus = false;

  @override
  Map getInitialState() => newState()..serverOnline = false;

  @override
  void componentWillMount() {
    super.componentWillMount();

    if (props.includeServerStatus) {
      _pingServer().then(_updateOnlineStatus);
      serverPolling =
          new Timer.periodic(const Duration(seconds: 4), (Timer timer) async {
        final isOnline = await _pingServer();

        _updateOnlineStatus(isOnline);
      });
    }
  }

  @override
  void componentWillUnmount() {
    super.componentWillUnmount();

    serverPolling?.cancel();
  }

  void _updateOnlineStatus(bool isOnline) {
    if (isOnline != state.serverOnline) {
      setState(newState()..serverOnline = isOnline);
    }
  }

  ReactElement _renderServerStatusBanner() {
    if (!props.includeServerStatus) return null;

    var classes = new ClassNameBuilder()
      ..add('server-status')
      ..add('online', state.serverOnline);

    var statusDesc = state.serverOnline ? 'online' : 'offline';

    return (Dom.div()..className = classes.toClassName())(
      (Dom.div()..className = 'server-status-light')(
        '\u2022',
      ),
      (Dom.div()..className = 'server-status-desc')(
        'Server $statusDesc',
      ),
    );
  }

  ReactElement _renderNav() {
    if (!props.nav) return null;

    return (Dom.a()..href = '/')(
      '\u2190 All Examples',
    );
  }

  ReactElement _renderServerTip() {
    if (!props.includeServerStatus || state.serverOnline) return null;

    return (Dom.div()..className = 'server-status-tip muted')(
        Dom.span()('Run '),
        Dom.code()('pub run dart_dev examples'),
        Dom.span()(' to serve examples with the server.'));
  }

  @override
  dynamic render() {
    var classes = forwardingClassNameBuilder()..add('global-example-menu');

    return (Dom.div()
      ..addProps(copyUnconsumedDomProps())
      ..className = classes.toClassName())(
      (Dom.div()..className = 'container')(
        _renderNav(),
        _renderServerStatusBanner(),
        _renderServerTip(),
      ),
    );
  }
}

// AF-3369 This will be removed once the transition to Dart 2 is complete.
// ignore: mixin_of_non_class, undefined_class
class GlobalExampleMenuProps extends _$GlobalExampleMenuProps
    with _$GlobalExampleMenuPropsAccessorsMixin {
  // ignore: undefined_identifier, undefined_class, const_initialized_with_non_constant_value
  static const PropsMeta meta = _$metaForGlobalExampleMenuProps;
}

// AF-3369 This will be removed once the transition to Dart 2 is complete.
// ignore: mixin_of_non_class, undefined_class
class GlobalExampleMenuState extends _$GlobalExampleMenuState
    with _$GlobalExampleMenuStateAccessorsMixin {
  // ignore: undefined_identifier, undefined_class, const_initialized_with_non_constant_value
  static const StateMeta meta = _$metaForGlobalExampleMenuState;
}
