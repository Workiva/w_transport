# Changelog

## 1.0.1
**Bug Fixes:**

- Allow request data to be set to `null`.
- Canceling an in-flight request now properly results in the returned Future completing with an error.
- Request data type validation now happens when sending the request instead of upon assignment, allowing intermediate data assignments.
- Verify w_transport configuration has been set before constructing a `WHttp` instance.

## 1.0.0
- Initial version of w_transport: a fluent-style, platform-agnostic library with ready to use transport classes for sending and receiving data over HTTP.