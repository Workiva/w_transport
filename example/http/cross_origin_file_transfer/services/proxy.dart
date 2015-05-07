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

library w_transport.example.http.cross_origin_file_transfer.services.proxy;


// Whether or not to route requests through a proxy server.
bool proxyEnabled = false;

void toggleProxy({enabled: false}) {
  proxyEnabled = enabled;
}

String getServerUrl() {
  if (proxyEnabled) {
    return 'http://localhost:8025';
  } else {
    return 'http://localhost:8024/example/http/cross_origin_file_transfer';
  }
}

Uri getDownloadEndpointUrl(String name) {
  return Uri.parse('${getServerUrl()}/download?file=$name');
}

Uri getFilesEndpointUrl() {
  return Uri.parse('${getServerUrl()}/files/');
}

Uri getUploadEndpointUrl() {
  return Uri.parse('${getServerUrl()}/upload');
}