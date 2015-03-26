library w_url;

class UrlBased {

  /**
   * Getter and setter for URL.
   */
  Uri url = Uri.parse('');

  /**
   * Getter and setter for URL scheme.
   */
  String get scheme => url.scheme;
  void set scheme(String scheme) {
    url = url.replace(scheme: scheme);
  }

  /**
   * Getter and setter for URL host.
   */
  String get host => url.host;
  void set host(String host) {
    url = url.replace(host: host);
  }

  /**
   * Getter and setter for URL port.
   */
  int get port => url.port;
  void set port(int prot) {
    url = url.replace(port: port);
  }

  /**
   * Getter and setter for URL path.
   */
  String get path => url.path;
  void set path(String path) {
    url = url.replace(path: path);
  }

  /**
   * Getter and setter for URL path segments.
   */
  Iterable<String> get pathSegments => url.pathSegments;
  void set pathSegments(Iterable<String> pathSegments) {
    url = url.replace(pathSegments: pathSegments);
  }

  /**
   * Getter and setter for URL query.
   */
  String get query => url.query;
  void set query(String query) {
    url = url.replace(query: query);
  }

  /**
   * Getter and setter for URL query parameters.
   */
  Map<String, String> get queryParameters => url.queryParameters;
  void set queryParameters(Map<String, String> queryParameters) {
    url = url.replace(queryParameters: queryParameters);
  }

  /**
   * Getter and setter for URL fragment.
   */
  String get fragment => url.fragment;
  void set fragment(String fragment) {
    url = url.replace(fragment: fragment);
  }

}