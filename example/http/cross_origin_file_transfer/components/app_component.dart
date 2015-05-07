/**
 * Copyright 2015 Workiva Inc.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

library w_transport.example.http.cross_origin_file_transfer.components.app_component;

import 'package:react/react.dart' as react;

import './download_page.dart';
import './upload_page.dart';
import '../services/proxy.dart' as proxy;


/// Main application component.
/// Sets up the file drop zone, file upload, and file download components.
var appComponent = react.registerComponent(() => new AppComponent());
class AppComponent extends react.Component {

  Map getInitialState() {
    return {
      'page': 'upload',
    };
  }

  void _goToUploadPage(e) {
    e.preventDefault();
    this.setState({'page': 'upload'});
  }

  void _goToDownloadPage(e) {
    e.preventDefault();
    this.setState({'page': 'download'});
  }

  void _toggleProxy(e) {
    proxy.toggleProxy(enabled: e.target.checked);
  }

  render() {
    String page = this.state['page'];

    return react.div({}, [
      react.p({},
        react.label({'htmlFor': 'proxy'}, [
          react.input({'type': 'checkbox', 'id': 'proxy', 'onChange': _toggleProxy}),
          ' Use Proxy Server',
        ])
      ),
      react.div({'className': 'app-nav'}, [
        react.a({'href': '#', 'className': page == 'upload' ? 'active' : '', 'onClick': _goToUploadPage}, 'Upload'),
        react.a({'href': '#', 'className': page == 'download' ? 'active' : '',  'onClick': _goToDownloadPage}, 'Download'),
      ]),
      uploadPage({'active': page == 'upload'}),
      downloadPage({'active': page == 'download'}),
    ]);
  }
}