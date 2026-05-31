# Compass (version 0.1.0)

## Introduction

*Compass* is a navigation app for National University of Singapore's campus. It is designed to find **detailed** routes which include paths within and between floors of buildings.

## User guide

### System requirements

*Compass* is supported on the following platforms:

#### 1. Android

* Android 8.1 or later

#### 2. Windows

* Windows 10 or later (64-bit)

### Installation

As *Compass* is still in early beta, it is **not available on app stores**.

Currently, there are 2 ways to install *Compass* on your device:

#### Download from Github

1. Go to the download page:
   * [Windows](https://github.com/Lum1noxx/Compass/blob/main/download/windows/compass.zip)
   * [Android](https://github.com/Lum1noxx/Compass/blob/main/download/android/compass.apk)
2. Click on "**Download raw file**" to download the app.
3. Launch the app
   * Windows:
     1. Extract the .zip file
     2. Double-click the "**clientapp.exe**" file
   * Android:
     1. Copy the "**compass.apk**" file onto an Android device. Then, locate and select the file in the **Files** app.

#### Build from source

1. Set-up: Do the following on your Windows device:

   1. [Install Flutter ](https://docs.flutter.dev/install)(make sure to add Flutter to PATH)
   2. Get dependencies and source code

   ```bash
   git init
   git clone https://github.com/Lum1noxx/Compass
   cd clientapp
   flutter pub get
   ```
2. Build the app for your intended platform:

   * Windows:

     ```bash
     flutter build windows
     mv build\windows\x64\runner\Release .\download\windows
     ```

     - the app is located at **download\windows**
     - to launch the app on a Windows device, run:

     ```bash
     <path to app>\clientapp.exe
     ```
   * Android:

     ```bash
     flutter build apk
     mv build\app\outputs\flutter-apk\app-release.apk .\download\android\compass.apk
     ```

     - the app is located at **download\android\compass.apk**
     - to launch the app, copy the "**compass.apk**" file onto an Android device. Then, locate and select the file in the **Files** app.

### Features & how-to

#### 1. Navigation

1. Select "**directions**" in the bottom navigation bar. This brings you to the navigation page.
2. Select "**start**" above the botton navigation bar to begin choosing a starting location.
3. Enter the name of the start location into the "**Enter location:**" search bar. As you type, suggested locations are listed below the search bar.
4. Choose a start location by selecting any of the suggested locations.
5. Select "**end**" above the botton navigation bar to begin choosing an end location.
6. Enter the name of the end location into the "**Enter location:**" search bar. As you type, suggested locations are listed below the search bar.
7. Choose an end location by selecting any of the suggested locations.
8. The start and end locations you have chosen are visible as **red circles** on the map. Verify that they are correct.
9. Click "**find directions**" above the bottom navigation bar to find a route between the chosen start and end locations. Wait for the route to be displayed on the map. This may take a few seconds.
10. View the route on the map. The route consists of:
    * **red dot**: start location
    * **green dot**: end location
    * **orange dots**: checkpoints along the way
    * **red dotted line**: first route segment
    * **green dotted line**: last route segment
    * **yellow lines**: remaining route segments
    * together, the **orange dots** and **lines** trace out the entire route in detail
11. When you are done, you may repeat from **step 2** to find a new route. The previous route will be erased when you click "**find directions**" again.

## How it works

An overview of what goes on under the hood of *Compass*

### Data organisation

### Search-bar suggestions

### Locating places

### Navigation

## Our story

This project was inspired by the struggles one of our team members had with navigating the school, as someone who is exceptionally directionally challenged. Relying on NUSNextBus and other navigation apps like Google Maps, they were often shown non-ideal routes that sometimes didn't make much sense. Certain paths through the school were only learnt about via word-of-mouth.

We hope to create a proper navigation app for the school that recommends travel routes, including paths through different connected buildings, or hidden paths that traditional navigation apps may not show. We have decided to also add some useful and fun features that complement the use of a map.
