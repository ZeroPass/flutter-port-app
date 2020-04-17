# EOSIO PassID Mobile App

## Installation

* Android Studio - Follow instructions [here](https://developer.android.com/studio).  *or install any other IDE (Visual Studio, Xcode)

* Flutter - Follow instructions [here](https://flutter.dev/docs/get-started/install).

## Usage

* Download(git clone) the project

* In all directories that contains pubspec.yaml (main project with subprojects) call:
```
flutter packages get
```

* Fill the data in this [function](/lib/main.dart#L31)
  - configure EOS nodes like [here](/lib/main.dart#L47-L48) (IP address, port, encryption connection check and network type(chainID))
  - set [StorageServer](/lib/main.dart#L56-L57) (IP address, port and encryption connection check)
* Run the project from your IDE

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
