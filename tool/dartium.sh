#!/bin/sh

# Opens dartium to localhost, port 8080 by default.
# You can pass in a different port like so:
# ./tool/dartium 9000
dartium --checked http://localhost:${1-8080}