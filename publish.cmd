cd clientapp
call flutter pub get
call flutter build apk
call flutter build windows
move build\windows\x64\runner\Release\* ..\download\windows
move build\app\outputs\flutter-apk\app-release.apk ..\download\android\compass.apk
powershell -Command "Compress-Archive -Path '..\download\windows\*' -DestinationPath '..\download\windows\compass.zip' -Force"