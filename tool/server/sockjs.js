// Copyright 2015 Workiva Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

try {
    var http = require('http');
    var sockjs = require('sockjs');
} catch (e) {
    console.error('Missing NPM dependencies: "http" and "sockjs".\nRun `npm install`.');
    process.exit(1);
}


var echo = sockjs.createServer();
echo.on('connection', function(conn) {
    conn.on('data', function(message) {
        console.log('[echo] "' + message + '"');
        conn.write(message);
    });
    conn.on('close', function() {
        console.log('[echo] closed.');
    });
});

var closeOnRequest = sockjs.createServer();
closeOnRequest.on('connection', function(conn) {
    conn.on('data', function(message) {
        if (message.substr(0, 'close'.length) === 'close') {
            var parts = message.split(':');
            var code;
            var reason;
            if (parts.length >= 2) {
                code = parseInt(parts[1], 10);
            }
            if (parts.length >= 3) {
                reason = parts[2];
            }
            console.log('[cor] close request received');
            conn.close(code, reason);
        }
    });
    conn.on('close', function() {
        console.log('[cor] closed.');
    });
});

var ping = sockjs.createServer();
ping.on('connection', function(conn) {
    conn.on('data', function(message) {
        message = message.replace('ping', '');
        var numPongs = 1;
        if (message.length > 0) {
            try {
                numPongs = parseInt(message, 10);
            } catch (e) {}
        }
        for (var i = 0; i < numPongs; i++) {
            conn.write('pong');
            console.log('[ping] pong');
        }
    });
    conn.on('close', function() {
        console.log('[ping] closed.');
    });
});

var server = http.createServer();
closeOnRequest.installHandlers(server, {prefix: '/test/ws/close'});
echo.installHandlers(server, {prefix: '/test/ws/echo'});
echo.installHandlers(server, {prefix: '/example/ws/echo'});
ping.installHandlers(server, {prefix: '/test/ws/ping'});
server.listen(8026, 'localhost');
