library w_transport.test.unit.w_url_test;

import 'package:unittest/unittest.dart';
import 'package:w_transport/w_url.dart';


class ExtendingClass extends UrlMutation {}
class MixingInClass extends Object with UrlMutation {}


void main() {
  group('UrlMutation', () {
    UrlMutation t;
    String url = 'http://example.com/path/to/resource?limit=10&format=list#test';

    setUp(() {
      t = new UrlMutation();
      t.url = Uri.parse(url);
    });

    test('should be extendable', () {
      var t = new ExtendingClass();
      t.url = Uri.parse('example.com/path');
      expect(t.url.toString(), equals('example.com/path'));
    });

    test('should be able to used as a mixin', () {
      var t = new MixingInClass();
      t.url = Uri.parse('example.com/path');
      expect(t.url.toString(), equals('example.com/path'));
    });

    test('should allow replacing the entire url', () {
      t.url = Uri.parse('example.com/path');
      expect(t.url.toString(), equals('example.com/path'));
    });

    test('should allow setting the scheme', () {
      t.scheme = 'https';
      expect(t.url.scheme, equals('https'));
    });

    test('should allow setting the host', () {
      t.host = 'example.org';
      expect(t.url.host, equals('example.org'));
    });

    test('should allow setting the port', () {
      t.port = 8080;
      expect(t.url.port, equals(8080));
    });

    test('should allow setting the path', () {
      t.path = 'new/path';
      expect(t.url.path, equals('/new/path'));
    });

    test('should allow setting the path via a list of path segments', () {
      t.pathSegments = ['new', 'path'];
      expect(t.url.path, equals('/new/path'));
    });

    test('should allow setting the query', () {
      t.query = 'limit=5&format=text';
      expect(t.url.query, equals('limit=5&format=text'));
    });

    test('should allow setting the query via a map of query parameters', () {
      t.queryParameters = {'limit': '5', 'format': 'text'};
      expect(t.url.query, equals('limit=5&format=text'));
    });

    test('should allow updating the query parameters', () {
      t.updateQuery({'limit': '5', 'format': 'text'});
      expect(t.url.query, equals('limit=5&format=text'));
    });

    test('should allow setting the fragment', () {
      t.fragment = 'hashtag';
      expect(t.url.fragment, equals('hashtag'));
    });

  });
}