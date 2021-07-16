# Port Mobile App

## Installation

* Android Studio - Follow instructions [here](https://developer.android.com/studio).  *or install any other IDE (Visual Studio, Xcode)

* Flutter - Follow instructions [here](https://flutter.dev/docs/get-started/install).

## Getting Started
* Download(git clone) the project

* In root directory (where `pubspec.yaml` is) call:
```
flutter packages get
```
* To run:
```
flutter run --no-sound-null-safety

On iOS, If you encounter error: "Codepoint 62495 not found in font, aborting.", 
add '--no-tree-shake-icons' flag to the above command.

# Release version
flutter run --release --no-sound-null-safety

On iOS, If you encounter error: "Codepoint 62495 not found in font, aborting.", 
add '--no-tree-shake-icons' flag to the above command.

```
* To build app bundle:
```
# Android
flutter build apk
flutter build apk --release --no-shrink --no-sound-null-safety

*temporary only debug build is available
flutter build apk --debug --no-shrink --no-sound-null-safety


#iOS (on macOS host)
flutter build ios --release --no-sound-null-safety

If you encounter error: "Codepoint 62495 not found in font, aborting.", 
add '--no-tree-shake-icons' flag to the above command.

```

## Usage

* Fill the data in this [function](/lib/main.dart#L31)
  - configure blockchain nodes like [here](/lib/main.dart#L47-L48) (IP address, port, encryption connection check and network type(chainID))
  - set [StorageServer](/lib/main.dart#L56-L57) (IP address, port and encryption connection check)
* Run the project from your IDE
## Libraries
This repository hosts also 2 libraries:
* [dmrtd](lib/dmrtd) - dart implementation of ICAO 9303 MRTD standard
* [passid](lib/passid) - dart implementation of client PassID PoC protocol

