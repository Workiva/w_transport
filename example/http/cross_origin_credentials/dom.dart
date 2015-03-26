library w_transport.example.http.cross_origin_credentials.dom;

import 'dart:async';
import 'dart:html';

import 'package:w_transport/w_http_client.dart';

import './service.dart' as service;
import './status.dart' as status;


/// Update the authentication status in the DOM.
void updateAuthenticationStatus() {
  Element containerElement = querySelector('.status-container');
  Element statusElement = querySelector('.status');
  if (status.authenticated) {
    containerElement.className = containerElement.className.replaceFirst('unauthenticated', 'authenticated');
    statusElement.text = 'Authenticated';
  } else {
    containerElement.className = containerElement.className.replaceFirst('authenticated', 'unauthenticated');
    statusElement.text = 'Unauthenticated';
  }
}

/// Toggle between "Login"/"Logout" button.
void updateToggleAuthButton() {
  ButtonElement toggleAuthButton = querySelector('#toggle-auth');
  if (status.authenticated) {
    toggleAuthButton.text = 'Logout';
  } else {
    toggleAuthButton.text = 'Login';
  }
}

/// Display a message in the DOM.
void display(String message, bool isSuccessful) {
  String className = isSuccessful ? 'success' : 'warning';

  var elem = querySelector('#response');
  elem.innerHtml = '<p class="$className">$message</p>\n' + elem.innerHtml;
}

/// Setup bindings for the controls.
Future setupControlBindings() async {
  // Handle login/logout
  querySelector('#toggle-auth').onClick.listen((_) async {
    if (!status.authenticated) {
      try {
        if (await service.login()) {
          status.authenticated = true;
          updateAuthenticationStatus();
          updateToggleAuthButton();
          display('Logged in.', true);
        } else {
          display('Failed to login.', false);
        }
      } catch (error) {
        display('Failed to login: $error', false);
      }
    } else {
      try {
        if (await service.logout()) {
          status.authenticated = false;
          updateAuthenticationStatus();
          updateToggleAuthButton();
          display('Logged out.', true);
        } else {
          display('Failed to logout.', false);
        }
      } catch (error) {
        display('Failed to logout: $error', false);
      }
    }
  });

  // Send a request with credentials (will succeed if authenticated)
  querySelector('#make-credentialed-request').onClick.listen((_) async {
    try {
      String response = await service.makeCredentialedRequest();
      display(response, true);
    } on WHttpException catch (e) {
      display(e.message, false);
    } catch (e) {
      display(e.toString(), false);
    }
  });

  // Send a request without credentials (will always fail)
  querySelector('#make-uncredentialed-request').onClick.listen((_) async {
    try {
      String response = await service.makeUncredentialedRequest();
      display(response, true);
    } on WHttpException catch (e) {
      display(e.message, false);
    } catch (e) {
      display(e.toString(), false);
    }
  });
}