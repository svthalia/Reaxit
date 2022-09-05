import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:oauth2/oauth2.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/concrexit_api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/config.dart' as config;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _redirectUrl = Uri.parse(
  'nu.thalia://callback',
);

final Uri _authorizationEndpoint = Uri(
  scheme: 'https',
  host: config.apiHost,
  path: 'user/oauth/authorize/',
);

final Uri _tokenEndpoint = Uri(
  scheme: 'https',
  host: config.apiHost,
  path: 'user/oauth/token/',
);

const _credentialsStorageKey = 'ThaliApp OAuth2 credentials';

const _devicePkPreferenceKey = 'deviceRegistrationId';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Authentication is loading.
class LoadingAuthState extends AuthState {}

/// Not logged in.
class LoggedOutAuthState extends AuthState {}

/// Logged in.
class LoggedInAuthState extends AuthState {
  final ApiRepository apiRepository;

  const LoggedInAuthState({required this.apiRepository});

  @override
  List<Object?> get props => [apiRepository];
}

/// Something went wrong.
class FailureAuthState extends AuthState {
  final String? message;

  const FailureAuthState({this.message});

  @override
  List<Object?> get props => [message];
}

/// The [Cubit] that handles authentication.
///
/// This also handles other functionality that needs to be done upon
/// logging in or out, such as registering for push notifications.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(LoadingAuthState());

  /// A listener for refreshing push notification tokens.
  StreamSubscription? _fmTokenSubscription;

  /// Restore the authentication state from storage.
  ///
  /// Looks for existing credentials and, if available,
  /// uses them to create and emit a [LoggedInAuthState].
  /// Otherwise, emits a [LoggedOutAuthState].
  ///
  /// Also sets up push notifications.
  Future<void> load() async {
    // Retrieve existing credentials.
    const storage = FlutterSecureStorage();
    final stored = await storage.read(
      key: _credentialsStorageKey,
      iOptions:
          const IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );

    if (stored != null) {
      // Restore credentials from the storage.
      final credentials = Credentials.fromJson(stored);

      // Log out if not all required scopes are available. After an update that
      // introduces a new scope, this will cause the app to log out and get new
      // credentials with the required scopes, instead of just getting 403's
      // until you manually log out.
      final scopes = credentials.scopes?.toSet() ?? <String>{};
      if (scopes.containsAll(config.oauthScopes)) {
        // Create the API repository.
        final apiRepository = ConcrexitApiRepository(
          client: Client(
            credentials,
            identifier: config.apiIdentifier,
            secret: config.apiSecret,
            onCredentialsRefreshed: (credentials) async {
              const storage = FlutterSecureStorage();
              await storage.write(
                key: _credentialsStorageKey,
                value: credentials.toJson(),
                iOptions: const IOSOptions(
                  accessibility: KeychainAccessibility.first_unlock,
                ),
              );
            },
            httpClient: SentryHttpClient(failedRequestStatusCodes: [
              SentryStatusCode(400),
              SentryStatusCode.range(405, 499),
            ]),
          ),
          onLogOut: logOut,
        );

        try {
          _setupPushNotifications(apiRepository);
        } on FirebaseException {
          // Ignore.
        }

        emit(LoggedInAuthState(apiRepository: apiRepository));
      } else {
        logOut();
      }
    } else {
      // Clear username for sentry.
      Sentry.configureScope((scope) => scope.setUser(null));
      emit(LoggedOutAuthState());
    }
  }

  /// Trigger an OAuth authentication flow to log in.
  ///
  /// This will try to let the user sign in. If successful, this emits a
  /// [LoggedInAuthState], which contains an [ApiRepository] that uses an
  /// authenticated client to make requests to the API. Furthermore, it will
  /// handle whatever need to happen upon loggin in, such as setting up push
  /// notifications.
  Future<void> logIn() async {
    emit(LoadingAuthState());

    // Prepare for the authentication flow.
    final grant = AuthorizationCodeGrant(
      config.apiIdentifier,
      _authorizationEndpoint,
      _tokenEndpoint,
      secret: config.apiSecret,
      onCredentialsRefreshed: (credentials) async {
        // When credentials are refreshed, store them.
        const storage = FlutterSecureStorage();
        await storage.write(
          key: _credentialsStorageKey,
          value: credentials.toJson(),
          iOptions: const IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
          ),
        );
      },
    );

    final authorizeUrl = grant.getAuthorizationUrl(
      _redirectUrl,
      scopes: config.oauthScopes,
    );

    try {
      // Present the authentication flow, and wait
      // for the redirect url with the credentials.
      final responseUrl = Uri.parse(
        await FlutterWebAuth.authenticate(
          url: authorizeUrl.toString(),
          callbackUrlScheme: _redirectUrl.scheme,
        ),
      );

      // Try to create an authenticated client with the credentials.
      final client = await grant.handleAuthorizationResponse(
        responseUrl.queryParameters,
      );

      // Store the credentials in secure storage.
      const storage = FlutterSecureStorage();
      await storage.write(
        key: _credentialsStorageKey,
        value: client.credentials.toJson(),
        iOptions:
            const IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      );

      final apiRepository = ConcrexitApiRepository(
        client: client,
        onLogOut: logOut,
      );

      await _setupPushNotifications(apiRepository);

      emit(LoggedInAuthState(apiRepository: apiRepository));
    } on PlatformException catch (exception) {
      // Forward exceptions from the authentication flow.
      emit(FailureAuthState(message: exception.message));
    } on SocketException catch (_) {
      emit(const FailureAuthState(message: 'No internet.'));
    } on AuthorizationException catch (_) {
      emit(const FailureAuthState(message: 'Authorization failed.'));
    } catch (_) {
      emit(const FailureAuthState(message: 'An unknown error occurred.'));
    }
  }

  /// Log out, and perform the necessary cleaning up.
  ///
  /// Closes the authenticated client, and removes the credentials from secure
  /// storage. This also handles whatever else needs to happen upon logging out,
  /// such as disabling push notifications.
  Future<void> logOut() async {
    final state = this.state;
    if (state is LoggedInAuthState) {
      await _cleanUpPushNotifications(state.apiRepository);
      state.apiRepository.close();
    }

    // Remove the credentials from secure storage.
    const storage = FlutterSecureStorage();
    await storage.delete(
      key: _credentialsStorageKey,
      iOptions:
          const IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );

    // Clear username for sentry.
    Sentry.configureScope((scope) => scope.setUser(null));
    emit(LoggedOutAuthState());
  }

  /// Set up push notifications.
  ///
  /// Requests permission to display notifications, and registers
  /// or updates a [Device] for push notifications on the backend.
  ///
  /// Returns whether push notifications have been set up successfully or not.
  Future<bool> _setupPushNotifications(ApiRepository api) async {
    try {
      // Request permissions for push notifications.
      // We set up push notifications regardless of whether the user gives
      // permission, so we don't need to keep track of the permission state,
      // and the user can simply get push notifications working by enabling
      // the permissions in the phone's settings.
      FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      final token = await FirebaseMessaging.instance.getToken();
      final prefs = await SharedPreferences.getInstance();
      final devicePk = prefs.getInt(_devicePkPreferenceKey);

      if (devicePk == null) {
        // There is no device in the backend yet.
        try {
          await _registerNewDevice(prefs: prefs, api: api, token: token);
        } on ApiException {
          return false;
        }
      } else {
        // There already is a device in the backend.
        try {
          // Update the existing device.
          final device = await api.updateDeviceToken(
            pk: devicePk,
            token: token!,
          );

          // Handle refreshing of tokens.
          _fmTokenSubscription =
              FirebaseMessaging.instance.onTokenRefresh.listen(
            (token) => api.updateDeviceToken(pk: device.pk, token: token),
          );
        } on ApiException catch (exception) {
          if (exception == ApiException.notFound) {
            // The device was deleted from the backend.
            // Delete the device from the local storage.
            prefs.remove(_devicePkPreferenceKey);

            try {
              await _registerNewDevice(prefs: prefs, api: api, token: token);
            } on ApiException {
              return false;
            }
          }
        }
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Register a new [Device] in the backend. May throw an [ApiException].
  Future<void> _registerNewDevice({
    required SharedPreferences prefs,
    required ApiRepository api,
    required String? token,
  }) async {
    final device = await api.registerDevice(
      type: Platform.isIOS ? 'ios' : 'android',
      token: token!,
    );

    // Store the pk of the new device.
    prefs.setInt(_devicePkPreferenceKey, device.pk);

    // Handle refreshing of tokens.
    _fmTokenSubscription = FirebaseMessaging.instance.onTokenRefresh.listen(
      (token) => api.updateDeviceToken(pk: device.pk, token: token),
    );
  }

  /// Clean up the setup of push notifications.
  ///
  /// Removes the subscription that listens to token changes, disables
  /// the current token, and inactivates the device in the backend.
  ///
  /// Returns whether the device on the backend was successfully disabled.
  Future<bool> _cleanUpPushNotifications(ApiRepository api) async {
    // Stop notifying the backend of token changes.
    _fmTokenSubscription?.cancel();

    // Disable the existing token. This makes sure that the backend can no
    // longer send push notifications to this phone even if deleting the
    // device from the backend fails.
    FirebaseMessaging.instance.deleteToken();

    // Delete the device from the backend.
    final prefs = await SharedPreferences.getInstance();
    final devicePk = prefs.getInt(_devicePkPreferenceKey);
    if (devicePk != null) {
      // Remove the device pk from storage.
      prefs.remove(_devicePkPreferenceKey);

      try {
        await api.disableDevice(pk: devicePk);
      } on ApiException {
        return false;
      }
    }

    return true;
  }
}
