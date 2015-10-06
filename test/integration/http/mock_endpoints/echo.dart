library w_transport.test.integration.http.mock_endpoints.echo;

import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_mock.dart';

void mockEchoEndpoint(Uri uri) {
  MockTransports.http.when(uri, (FinalizedRequest request) async {
    var headers = {'content-type': request.headers['content-type']};
    if (request.body is HttpBody) {
      return new MockResponse.ok(
          body: (request.body as HttpBody).asString(), headers: headers);
    } else {
      return new MockStreamedResponse.ok(
          byteStream: (request.body as StreamedHttpBody).byteStream,
          headers: headers);
    }
  });
}
