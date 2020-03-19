import 'package:over_react/over_react.dart';
import 'dart:html';

import 'package:over_react/react_dom.dart' as react_dom;

import './global_example_menu_component.dart';

void renderGlobalExampleMenu(
    {bool nav = true, bool includeServerStatus = false}) {
  // Insert a container div within which we will mount the global example menu.
  final container = document.createElement('div');
  container.id = 'global-example-menu';
  document.body.insertBefore(container, document.body.firstChild);

  // Use react to render the menu.
  final menu = (GlobalExampleMenu()
    ..nav = nav
    ..includeServerStatus = includeServerStatus)();
  react_dom.render(ErrorBoundary()(menu), container);
}
