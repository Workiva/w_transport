Examples
--------

> There are several examples that demonstrate a wide range of use cases fulfilled by this library.

**HTTP**

- [Simple File Browser Client](http/simple_client)
- [Cross Origin Credentials](http/cross_origin_credentials)
- [Cross Origin Upload](http/cross_origin_file_transfer)

**WebSocket**

- [Echo](web_socket/echo)


### Building & Serving
You can run a shell script from the project root to build and serve the examples:
```
./tool/examples.sh
```

> This is the same as simply running `pub get && pub serve example --port 9000`.


### Server Component
Most of the examples will require a server to handle HTTP requests. You can run this server by running a shell script from the project root:
```
./tool/server.sh
```

> This is the same as running `dart --checked tool/server/run.dart --proxy`.


### Viewing (Compiled JS)
Open [http://localhost:9000](http://localhost:9000) in your browser of choice.

### Viewing (Dartium)
```
dartium --checked http://localhost:9000
```