# Reaxit

The latest ThaliApp built on Flutter.

## Table of Contents
- [Getting started](#getting-started)
    - [Other commands](#other-commands)
- [Reading material](#reading-material)
- [Fastlane](#fastlane)
    - [Configuration](#configuration)
    - [Github secrets](#github-secrets)
- [Release procedure](#release-procedure)


## Getting started

1. Install Flutter using the instructions for [your platform](https://flutter.dev/docs/get-started/install).
2. Make sure to complete the setup of [Android Studio](https://flutter.dev/docs/get-started/install/windows#android-setup) for Android or [Xcode](https://flutter.dev/docs/get-started/install/macos#ios-setup) for iOS.
3. [Set up your favorite IDE](https://flutter.dev/docs/get-started/editor?tab=vscode).
4. Clone this repository and open it in your IDE.
5. Run `flutter run` to build and start the app.
6. Take a look at some of the [reading material](#reading-material).

### Other commands

- To run in release mode (without debugging capabilities, so the app does not feel slow), use `flutter run --release`.
- If you've modified anything in `lib/models/*` (that uses `json_serializable`) or something that is mocked in tests, renew the generated files with `flutter pub run build_runner build --delete-conflicting-outputs`.
- If anything does not work, run `flutter clean` and try again or run `flutter doctor -v` to check whether everything is installed correctly.
- You can run unit and widget tests with `flutter test`. For integration tests (on a real device or simulator) use `flutter test integration_test`.

## Reading material

- [Intro to flutter](https://flutter.dev/docs/development/ui/widgets-intro)
- [Dart style guide](https://dart.dev/guides/language/effective-dart)
- [API reference](https://api.flutter.dev)
- [Widget of the week videos](https://youtube.com/playlist?list=PLjxrf2q8roU23XGwz3Km7sQZFTdB996iG)

Reaxit uses the following packages:
- [go_router](https://pub.dev/packages/go_router) for easy routing and deep linking. 
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) for state management.

## Fastlane

Our repository contains a [Fastlane configuration](https://fastlane.tools) that you can use to build and deploy the app for Android and iOS.
To use Fastlane follow these steps:
 1. To be able to start you need [an installation of Ruby](https://www.ruby-lang.org/en/documentation/installation/)
 2. The first time run `bundle install`
 3. Add the correct configuration files (see below)
 3. Then use fastlane by running `fastlane <platform> <command>`.

| Command           | Description                     | Platforms    |
| :---------------- | :------------------------------ | :----------- |
| deploy_internal   | Create a release and deploy to the internal Play Store track or Testflight | Android, iOS |
| deploy_beta       | Create a release and deploy to Play Store beta or Testflight with external testers | Android, iOS |
| deploy_production | Create a release and deploy to Play Store or App Store | Android, iOS |
| match             | Get the certificates to sign iOS apps | iOS |

Sometimes, Apple certificates and provisioning profiles expire. So far, we've been able to solve that with `fastlane match nuke development` and `fastlane match nuke distribution` to remove existing certificates, and `fastlane match appstore` and `fastlane match development` to get new ones.

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

For a full iOS build that allows deployment you need:
1. The password for [Fastlane Match](https://docs.fastlane.tools/actions/match/) set to the environment variable `MATCH_PASSWORD`, or ready for entering when you execute a fastlane command
2. The App Store Connect API key (app-store.p8) placed in the root of this project

If you want to build a version of the application that does not point to the staging servers you should not forget to set the `THALIA_API_HOST`, `THALIA_OAUTH_APP_ID` and `THALIA_OAUTH_APP_SECRET` environment variables. To include a [TOSTI](https://github.com/KiOui/TOSTI) client, specify `TOSTI_API_HOST`, `TOSTI_OAUTH_APP_ID` and `TOSTI_OAUTH_APP_SECRET`.
To enable the Sentry integration you should set the `SENTRY_DSN` variable, such a DSN can be obtained by going to sentry.io.

### Github secrets

To build and deploy the app with Github Actions, we need to set up a number of secrets, defined below. To make the CI/CD also work for pull requests created by dependabot, we need to specify the same exact secrets as dependabot secrets (for security reasons, workflows triggered by dependabot don't get access to actions secrets).

| Secret | Description | How to get it |
| :----- | :---------- | :------------ |
| `ANDROID_RELEASE_CONFIG_STORE_FILE` | Path to the keystore to use for android signing | `/home/runner/work/Reaxit/Reaxit/thaliapp-passwords/upload.keystore` | 
| `ANDROID_RELEASE_CONFIG_STORE_PASS` | Password of the keystore to use for android signing | Get from `ThaliaApp-Passwords/Upload Signing Keystore` |
| `ANDROID_RELEASE_CONFIG_KEY_ALIAS` | Alias of the key to use for android signing | `appsigning` |
| `ANDROID_RELEASE_CONFIG_KEY_PASS` | Password of the key to use for android signing | Get from `ThaliaApp-Passwords/Upload Signing Key` |
| `APPLE_API_KEY` | Base64 encoded App Store Connect API key | Get with `cat ThaliaApp-Passwords/app-store.p8 | base64` |
| `GOOGLE_PLAY_CONFIG_JSON` | Configuration file for Google Play | Get from `ThaliaApp-Passwords/google-play.json` |
| `MATCH_PASSWORD` | Password for Fastlane Match | Get from `ThaliaApp-Passwords/Fastlane Match` |
| `PASSWORDS_REPO_DEPLOY_KEY` | A deploy key for the ThaliaApp-Passwords repository | Create one (with `ssh-keygen`), add to passwords repo, and use the full content of the private key file |
| `SENTRY_DSN` | DSN for Sentry | Get from [`sentry.io`](https://sentry.io/) |
| `THALIA_OAUTH_APP_ID` | OAuth client ID for the Thalia API | Get from `ThaliaApp-Passwords/concrexit-oauth-secrets` |
| `THALIA_OAUTH_APP_SECRET` | OAuth client secret for the Thalia API | Get from `ThaliaApp-Passwords/concrexit-oauth-secrets` |


## Release procedure

Follow these steps carefully to release a new version of the app.

1. Test stuff, check that the new version works with the _production_ version of the API.
2. If necessary, update the version number in [`pubspec.yaml`](pubspec.yaml) and [`lib/config.dart`](lib/config.dart) and commit. The build number does not need to be changed as it will be set by fastlane.
3. Create a draft release (with a new tag).
4. Activate the testing account on concrexit: In the production admin, go to user 'appletest', check the 'active' box, and add a membership.
5. Create a new version in [App Store Connect](https://appstoreconnect.apple.com/) with the build from the last TestFlight deployment. Perhaps also create and upload new screenshots. Submit the release for review.
6. Promote the new build in the [Play Store Console](https://play.google.com/console/about/). Perhaps also create and upload new screenshots.
7. When the iOS update has been approved, publish the iOS release, deactivate the testing account ('appletest') again, and delete its membership.
8. Publish the release on GitHub.
9. Increment the version number in [`pubspec.yaml`](pubspec.yaml) and [`lib/config.dart`](lib/config.dart) and commit.