
## Usage

A simple usage example:

```dart
import 'package:passid/passid.dart';

main() {
  try {
    var client = new PassIdClient(serverUrl, httpClient: httpClient);
    client.onConnectionError  = handleConnectionError;
    client.onDG1FileRequested = handleDG1Request;

    await client.register((challenge) async {
      return getAuthnData(challenge);
    });

    await client.login((challenge) async {
      return getAuthnData(challenge);
    });

    final srvGreeting = await client.requestGreeting();
  } catch(e) {
    // handle error
  }
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://example.com/issues/replaceme
