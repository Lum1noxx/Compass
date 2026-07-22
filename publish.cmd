cd clientapp
call flutter clean
call flutter pub get
call flutter build apk --release
call flutter build windows --release
call flutter build web --release --base-href "/Compass/"
copy build\app\outputs\flutter-apk\app-release.apk ..\download\android\compass.apk
robocopy build\web ..\docs /E
robocopy build\windows\x64\runner\Release ..\download\windows /E
powershell -Command "Compress-Archive -Path '..\download\windows\*' -DestinationPath '..\download\windows\compass.zip' -Force"