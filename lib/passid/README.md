## PassID Library
Dart implementation of PassID PoC client.

## Usage
 1) Include `passid` library in your project's `pubspec.yaml` file:  
```
dependencies:
  passid:
    path: '<path_to_passid_folder>'
```
 2) Run 
 ```
 flutter pub get
 ```
 
**Example:**  
*Note: See also [example](example) app*

```dart
import 'package:passid/passid.dart';

AuthnData getAuthnData(final ProtoChallenge challenge) async {
  return // data from passport
}

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