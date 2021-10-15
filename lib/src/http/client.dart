import '../transport_platform.dart';
import 'http_client.dart';

/// This class is here solely to help with certain transitions from v3 to v4.
///
/// This class is not publicly exported (it was intentionally removed in favor
/// of [HttpClient]), and it now extends from [HttpClient] instead of the
/// inverse. The use case here is for certain consumers who cannot change from
/// [Client] to [HttpClient] in places where that would be a breaking change
/// (e.g. the type of a public constructor param). These consumers may
/// temporarily import [Client] using an internal import like so:
///
///     import 'package:w_transport/src/http/client.dart';
///
/// This import will work in v3 and v4 (at first). In v4, since we've inverted
/// the inheritence, changing from [Client] to [HttpClient] will no longer be a
/// breaking change.
abstract class Client extends HttpClient {
  factory Client({TransportPlatform transportPlatform}) =>
      HttpClient(transportPlatform: transportPlatform);
}
