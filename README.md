# w_transport 
[![Pub](https://img.shields.io/pub/v/w_transport.svg)](https://pub.dartlang.org/packages/w_transport)
[![Build Status](https://travis-ci.org/Workiva/w_transport.svg?branch=travis-ci)](https://travis-ci.org/Workiva/w_transport)
[![codecov.io](http://codecov.io/github/Workiva/w_transport/coverage.svg?branch=master)](http://codecov.io/github/Workiva/w_transport?branch=master)
[![documentation](https://img.shields.io/badge/Documentation-w__transport-blue.svg)](https://www.dartdocs.org/documentation/w_transport/latest/)

// TODO: rewrite
> Platform-agnostic transport library for sending and receiving data over HTTP
> and WebSocket. HTTP support includes plain-text, JSON, form-data, and
> multipart data, as well as custom encoding. WebSocket support includes native
> WebSockets in the browser and the VM with the option to use SockJS in the
> browser.

### Docs & Help

- [Guides](/docs/)
- [API docs](https://www.dartdocs.org/documentation/w_transport/latest/index.html)
- [Changelog](/CHANGELOG.md)


#### Older Versions

- 1.0.x - [docs](https://github.com/Workiva/w_transport/blob/1.0.0/README.md) / [code](https://github.com/Workiva/w_transport/tree/1.0.0)
- 2.x - [docs](https://github.com/Workiva/w_transport/blob/2.0.0/README.md) / [code](https://github.com/Workiva/w_transport/tree/2.0.0) / [upgrade guide (v2 -> v3)](https://github.com/Workiva/w_transport/blob/master/docs/upgrade-guides/v3.0.0.md)


### Installing
As of version 3.0.0, w_transport will be following a [versioning and
stability](#versioning-and-stability) commitment that guarantees a
compatibility lifespan of two major versions.

If you're installing w_transport for the first time, simply depend on
the latest major version and you'll get all patches and minor versions
as they are released:

```yaml
dependencies:
  w_transport: ^3.0.0
```

If you're upgrading from version 2.x, use this range (and check out
the 3.0.0 [upgrade guide](/docs/upgrade-guides/v3.0.0.md)):

```yaml
dependencies:
  w_transport: ">=2.0.0 <4.0.0"
```


### Importing

The main entry point contains all of the transport classes necessary for
sending HTTP requests and establishing WebSocket connections. It is also
platform-independent (depends on neither `dart:html` nor `dart:io`),
which means you can use it to build components, libraries, or APIs that
will be reusable in the browser **and** on the Dart VM.

```dart
import 'package:w_transport/w_transport.dart';
```

The end consumer will make the decision between browser and VM, most
likely in a `main()` block.


### Dart SDK

As of version 3.0.0 of the `w_transport` package, the minimum required
Dart SDK version is 1.14.0 (released Jan 28, 2016).


### Versioning and Stability

// TODO: short summary, link to React Versioning Scheme


### Credits

This library was influenced in many ways by
[the `http` package](https://github.com/dart-lang/http), especially with
regard to multipart requests, and served as a useful source for
references to pertinent IETF RFCs.


### Development

This project leverages [the `dart_dev` package](https://github.com/Workiva/dart_dev)
for most of its tooling needs, including static analysis, code
formatting, running tests, collecting coverage, and serving examples.
Check out the dart_dev readme for more information.

> **Note:** to run integration tests, you'll need two JS dependencies
> for a SockJS server. Run `npm install` to download them.
