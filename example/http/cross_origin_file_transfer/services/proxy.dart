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