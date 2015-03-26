/// Convenient fluent URL mutation built on top the core [Uri] class.
/// The [UrlMutation] class can be extended or
/// mixed in to provide a suite of URL getters and setters.
///
/// To use this in your code:
///
///     import 'package:w_transport/w_url.dart';
///
///     class Example extends UrlMutation {
///       // ...
///     }
///
///     void main() {
///       var ex = new Example()
///         ..url = Uri.parse('example.com')
///         ..scheme = 'https'
///         ..path = '/path/to/resource'
///         ..queryParameters = {'q': 'search term'};
///
///       ex.url.toString(); // https://example.com/path/to/resource?q=search%20term
///     }

library w_transport.w_url;

export 'src/w_url.dart' show UrlMutation;