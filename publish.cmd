cd clientapp
call flutter pub get
call flutter build apk
call flutter build windows
call flutter build web
copy build\app\outputs\flutter-apk\app-release.apk ..\download\android\compass.apk
robocopy build\web ..\website /E
robocopy build\windows\x64\runner\Release ..\download\windows /E
powershell -Command "Compress-Archive -Path '..\download\windows\*' -DestinationPath '..\download\windows\compass.zip' -Force"