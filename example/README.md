Examples
--------

> There are 5 HTTP examples (3 browser, 2 server) and X WebSocket examples (Y browser, Z server) that demonstrate a wide range of use cases fulfilled by this library.

### HTTP
- [Simple File Browser Client (Browser)](http/simple_client)
- [Cross Origin Credentials (Browser)](http/cross_origin_credentials)
- [Cross Origin Upload (Browser)](http/cross_origin_upload)
- [File Streaming (Server)](http/file_streaming)
- [Persistent Connections (Server)](http/persistent_connections)


### Building & Serving
You can run a shell script from the project root to build and serve the examples:
```
./tool/serve_examples.sh
```

> This is the same as simply running `pub get && pub serve example`.


### Server Component
Most of the examples will require a server to handle HTTP requests and WebSocket connections. You can run this server by running a shell script from the project root:
```
./tool/run_server.sh
```

> This is the same as simply running `dart --checked tool/server/run.dart`.


### Viewing (Compiled JS)
Open [http://localhost:8080](http://localhost:8080) in your browser of choice.

### Viewing (Dartium)
```
dartium --checked http://localhost:8080
```