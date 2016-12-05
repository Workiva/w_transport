## Automatic Request Retrying

All of the request classes and the `transport.HttpClient` class have an
`autoRetry` API for enabling and configuring automatic request retrying.

> Requests that succeed (200-level status code) and requests that are explicitly
> canceled (via `.abort()`) are not eligible to be retried.

Enabling automatic request retrying is simple:

```dart
// Single request
var request = new transport.Request()
  ..autoRetry.enabled = true;

// All requests from an HTTP client
var client = new transport.HttpClient()
  ..autoRetry.enabled = true;
```

### Configuring _Which_ Requests are Retried

Determining whether or not a request can be retried is based on a combination
of several factors: the HTTP method, the response status code, whether or not
it failed due to a timeout, and how many times the request has been attempted.

- **HTTP Methods (`autoRetry.forHttpMethods`)**

  You can define the set of HTTP methods for which a request may be retried. Any
  request with a method not in this list will not be retried.
  
  _The default for this list is: `['GET', 'HEAD', 'OPTIONS']`._
  
  ```dart
  var request = new transport.Request();
  request.autoRetry
    ..enabled = true
    ..forHttpMethods = ['GET', 'POST', 'PUT'];
  ```

- **Status Codes (`autoRetry.forStatusCodes`)**

  You can define the set of status codes for which a request may be retried. Any
  request that returns with a status code not in this list will not be retried.
  
  _The default for this list is: `[500, 502, 503, 504]`._
  
  ```dart
  var request = new transport.Request();
  request.autoRetry
    ..enabled = true
    ..forStatusCodes = [500, 501, 502];
  ```

- **Timeouts (`autoRetry.forTimeouts`)**

  For requests that fail due to exceeding the timeout threshold, you can either
  allow or disallow them from being retried.
  
  _By default, timeouts are eligible to be retried._
  
  ```dart
  var request = new transport.Request()
  request.autoRetry
    ..enabled = true
    ..forTimeouts = false;
  ```

- **Number of Retries (`autoRetry.maxRetries`)**

  With automatic request retrying, it's possible that the request may never
  succeed. To handle this, you can set a maximum number of retries.
  
  _By default, the maximum number of retries is 2._
  
  ```dart
  var request = new transport.Request()
  request.autoRetry
    ..enabled = true
    ..maxRetries = 10;
  ```
  
  > This is the maximum number of _retries_, not attempts. A request with a
  > `maxRetries = 2` could produce up to 3 attempts - the original request and
  > up to 2 retries.


If the above criteria are not enough to adequately determine when a request
should be retried, you can provide a custom test function. It will be called
with:
                                                             
1. A `transport.FinalizedRequest` instance,
2. A `transport.BaseResponse` instance, and
3. A `willRetry` boolean representing whether or not the
   `autoRetry.forHttpMethods`, `autoRetry.forStatusCodes`, and
   `autoRetry.forTimeouts` checks passed.

The test function then makes the final decision (retry or no retry) by
asynchronously returning a boolean.

```dart
// Example of auto retry with a custom check for a CSRF failure that
// can only be identified by a message in the response body.
var request = new transport.Request();
request.autoRetry
  ..enabled = true
  ..test = (FinalizedRequest request,
            BaseResponse response,
            bool willRetry) async {
      // Check for a special case (CSRF failure) by reading the body.
      // If it's determined that it is a CSRF failure, return `true`
      // to indicate the request should be retried.
      if (response is Response &&
          response.status == 403 &&
          response.body.asString().contains('CSRF failure')) return true;
    
      // Otherwise, return whatever the value of `willRetry` is.
      // In other words, we defer to the HTTP method & status code checks.
      return willRetry;
    };
```


---


### Configuring _How_ Requests are Retried

By default, request retries happen immediately. However, you may want to utilize
some sort of retry back-off to avoid flooding the server. If an endpoint goes
down temporarily due to heavy load or a transient issue, hammering the endpoint
with immediate retries from all clients will likely do more harm than good.

The automatic retry API supports both a fixed and an exponential back-off and it
supports [introducing jitter to help evenly distribute requests from clients](https://www.awsarchitectureblog.com/2015/03/backoff.html).

- **Fixed back-off**

  This will introduce a fixed delay between request attempts.

  ```dart
  var request = new transport.Request();
  request.autoRetry
    ..enabled = true
    ..backOff = const RetryBackOff.fixed(const Duration(seconds: 2));
  ```
  
- **Exponential back-off**

  This will introduce an exponential delay of `d*2^n` between request attempts
  where `d` is the configured interval and `n` is the number of attempts so far.
  
  For example, an exponential back-off with a 1 second interval would produce
  the following request schedule:
  
  - 1st attempt: immediate
  - 2nd attempt: 2 second delay (1 sec * 2 ^ 1 attempt)
  - 3rd attempt: 4 second delay (1 sec * 2 ^ 2 attempts)
  - 4th attempt: 8 second delay (1 sec * 2 ^ 3 attempts)
  - and so on..

  ```dart
  var request = new transport.Request();
  request.autoRetry
    ..enabled = true
    ..backOff = const RetryBackOff.exponential(const Duration(seconds: 1));
  ```
  
  A maximum delay between retries can be set to prevent the exponential back-off
  from growing too large. The default value for this is 5 minutes, but it can be
  configured when setting the back-off:
  
  ```dart
  var request = new transport.Request();
  request.autoRetry
    ..enabled = true
    ..backOff = const RetryBackOff.exponential(
        const Duration(seconds: 1), maxInterval: const Duration(minutes: 1));
  ```

- **Jitter**

  Jitter is enabled by default for fixed and exponential back-off, but you can
  opt-out when setting the back-off.
  
  ```dart
  var interval = const Duration(seconds: 1);
  var request = new transport.Request()
    ..autoRetry.enabled = true;
  
  
  request.autoRetry.backOff = const RetryBackOff.fixed(
      interval, withJitter: false);
  request.autoRetry.backOff = const RetryBackOff.exponential(
      interval, withJitter: false);
  ```
