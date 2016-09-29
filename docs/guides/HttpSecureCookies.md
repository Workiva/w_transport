## HTTP: Sending Secure Cookies (browser only)

HTTP requests made from a browser have an added restriction - secure cookies are
not sent by default on cross-origin requests. To include these secure cookies
when sending a request, set `withCredentials` to `true`. Although this only
applies to browsers, it's included in the platform-independent API because it
has no effect on the other platforms.

```dart
var request = new transport.Request()
  ..uri = Uri.parse('https://otherhost.com/notes/')
  ..withCredentials = true;
await request.get();
```
