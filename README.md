Reaxit
==============

The latest ThaliApp built on Flutter.

Getting started
---------------

1. Install Flutter using the instructions for [your platform](https://flutter.dev/docs/get-started/install).
2. Make sure to complete the setup of [Android Studio](https://flutter.dev/docs/get-started/install/windows#android-setup) for Android or [Xcode](https://flutter.dev/docs/get-started/install/macos#ios-setup) for iOS.
3. [Set up your favorite IDE](https://flutter.dev/docs/get-started/editor?tab=androidstudio).
4. Clone this repository and open it in your IDE.
5. Run `flutter pub get` in the reaxit folder.
6. Run `flutter run` to build and start the app.

### Other commands

- To run in release mode (without debugging capabilities, so the app does not feel slow), use `flutter run --release`.
- If you've modified anything in `lib/models/*` (that uses `json_serializable`), renew the generated files with `flutter pub run build_runner build --delete-conflicting-outputs`.
- If anything does not work, run `flutter clean` and try again or run `flutter doctor -v` to check whether everything is installed correctly.

Reading material
----------------
- [Intro to flutter](https://flutter.dev/docs/development/ui/widgets-intro)
- [Dart style guide](https://dart.dev/guides/language/effective-dart)
- [API reference](https://api.flutter.dev)
- [Widget of the week videos](https://youtube.com/playlist?list=PLjxrf2q8roU23XGwz3Km7sQZFTdB996iG)

Reaxit uses the following packages:
- [go_router](https://pub.dev/packages/go_router) for easy routing and deep linking. 
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) for state management.

Fastlane
----------------

Our repository contains a [Fastlane configuration](https://fastlane.tools) that you can use to build and deploy the app for Android and iOS.
To use Fastlane follow these steps:
 1. To be able to start you need [an installation of Ruby](https://www.ruby-lang.org/en/documentation/installation/)
 2. The first time run `bundle install`
 3. Add the correct configuration files (see below)
 3. Then use fastlane by running `fastlane <platform> <command>`.

| Command           | Description                     | Platforms    |
| :---------------- | :------------------------------ | :----------- |
| deploy_adhoc      | Create a release or AdHoc build | Android, iOS |
| deploy_internal   | Create a release and deploy to the internal Play Store track or Testflight | Android, iOS |
| deploy_beta       | Create a release and deploy to Play Store beta or Testflight with external testers | Android, iOS |
| deploy_production | Create a release and deploy to Play Store or App Store | Android, iOS |
| match             | Get the certificates to sign iOS apps | iOS |

### Configuration

To be able to deploy the application you need a few configuration files and passwords. These are all located in the vault in the ThaliApp-Passwords repository that you get access to when you're a part of our organisation.

For a full Android build that allows deployment you need:
 1. A `key.properties` file in the Android folder containing
  ```
  storeFile=<path to ThaliApp-Passwords/upload.keystore>
  storePassword=<the value from ThaliaApp-Passwords/Upload Signing Keystore>
  keyPassword=<the value from ThaliaApp-Passwords/Upload Signing Key>
  keyAlias=appsigning
  ```
 2. The Google Play API key (google-play.json) placed in the root of this project
 3. The Google Play services file (google-services.json) placed in the `android/app/` folder

For a full iOS build that allows deployment you need:
 1. The password for [Fastlane Match](https://docs.fastlane.tools/actions/match/) set to the environment variable `MATCH_PASSWORD`, or ready for entering when you execute a fastlane command
 2. The App Store Connect API key (app-store.p8) placed in the root of this project
 3. The Google Play services file (GoogleService-Info.plist) placed in the `ios` folder

 If you want to build a version of the application that does not point to the staging servers you should not forget to set the `THALIA_API_HOST`, `THALIA_OAUTH_APP_ID` and `THALIA_OAUTH_APP_SECRET` environment variables. To enable the Sentry integration you should set the `SENTRY_DSN` variable, such a DSN can be obtained by going to sentry.io.