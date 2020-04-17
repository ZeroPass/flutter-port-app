# PassID Example App
PassIDe is demonstrating app for `passid` library and `dmrtd` library.

## Getting Started
```
flutter pub get
flutter run
```

## Usage
1. In the app go to settings and set server's URL address
2. Close settings and go to `Register` screen
3. Fill in data from passport
    e.g.: Passport number, date of birth and date of expiry
4. Press `Scan` button and put your passport near your device.
5. If scan completes successfully and there is no communication error with the server,  
    you should end up on the `Success` screen 
6. Go back and open `Login` screen
7. Fill in data into form as in step 3 then follow step 4
8. After successful login you can try to login again.
    This time the server should request your personal data from the passport (EF.DG1 file).
    If you choose to send this file to the server it will return greeting with your name.
