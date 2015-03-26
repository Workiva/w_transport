library w_transport.example.http.cross_origin_file_transfer.components.app_component;

import 'package:react/react.dart' as react;

import './download_page.dart';
import './upload_page.dart';
import '../services/proxy.dart';


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
    toggleProxy(enabled: e.target.checked);
  }

  render() {
    String page = this.state['page'];
    var pageComponent;
    if (page == 'upload') {
      pageComponent = uploadPage({});
    } else {
      pageComponent = downloadPage({});
    }

    /**
     * <p>
        <label for="proxy">
        <input type="checkbox" id="proxy">
        Use Proxy Server
        </label>
        </p>
     */

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
      pageComponent,
    ]);
  }
}