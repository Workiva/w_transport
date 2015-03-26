library w_transport.src.w_url;


/// A class to be extended or mixed in to provide URL mutation methods.
/// Useful for classes that deal with URL-based actions,
/// like HTTP requests or WebSocket connections.
class UrlMutation {

  /// The full URL. All other URL mutations use this [Uri] instance.
  ///
  ///     // Overwrite entire URL
  ///     var item = new UrlMutation()..uri = Uri.parse('example.com');
  ///     // Get URL value
  ///     print(item.url.toString());
  Uri url = Uri.parse('');

  /// The URL scheme or protocol. Examples: `http`, `https`, `ws`.
  ///
  ///     new UrlMutation()..scheme = 'https';
  String get scheme => url.scheme;
  void set scheme(String scheme) {
    url = url.replace(scheme: scheme);
  }

  /// The URL host, including sub-domains and the tld.
  ///
  ///     new UrlMutation()..host = 'sub.example.org';
  String get host => url.host;
  void set host(String host) {
    url = url.replace(host: host);
  }

  /// The URL port number.
  ///
  ///     new UrlMutation()..port = 9001;
  void set port(int port) {
    url = url.replace(port: port);
  }

  /// The URL path.
  ///
  ///     new UrlMutation()..path = '/path/to/resource';
  String get path => url.path;

  void set path(String path) {
    url = url.replace(path: path);
  }

  /// The URL path segments.
  ///
  ///     new UrlMutation()..pathSegments = ['path', 'to', 'resource'];
  Iterable<String> get pathSegments => url.pathSegments;
  void set pathSegments(Iterable<String> pathSegments) {
    url = url.replace(pathSegments: pathSegments);
  }

  /// The URL query string.
  ///
  ///     new UrlMutation()..query = 'type=open&limit=10';
  String get query => url.query;
  void set query(String query) {
    url = url.replace(query: query);
  }

  /// The URL query parameters.
  ///
  ///     new UrlMutation()..queryParameters = {'type': 'open', 'limit': '10'};
  Map<String, String> get queryParameters => url.queryParameters;
  void set queryParameters(Map<String, String> queryParameters) {
    url = url.replace(queryParameters: queryParameters);
  }

  /// Update the URL query parameters, merging the given map with the
  /// current query parameters map instead of overwriting it.
  void updateQuery(Map<String, String> queryParameters) {
    Map newQueryParameters = new Map.from(this.queryParameters);
    newQueryParameters.addAll(queryParameters);
    url = url.replace(queryParameters: newQueryParameters);
  }

  /// The URL fragment or hash.
  ///
  ///     new UrlMutation()..fragment('top');
  String get fragment => url.fragment;
  void set fragment(String fragment) {
    url = url.replace(fragment: fragment);
  }

}