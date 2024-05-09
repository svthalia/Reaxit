import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:oauth2/oauth2.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/concrexit_api_repository.dart';
import 'package:reaxit/config.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

final _redirectUrl = Uri.parse(
  'nu.thalia://callback',
);

const _credentialsStorageKey = 'ThaliApp OAuth2 credentials';

const _devicePkPreferenceKey = 'deviceRegistrationId';

enum Environment {
  staging,
  production,
  local;

  static const defaultEnvironment =
      Config.production != null ? Environment.production : Environment.staging;
}

class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Authentication is loading.
class LoadingAuthState extends AuthState {}

/// Not logged in.
class LoggedOutAuthState extends AuthState {
  final Environment selectedEnvironment;

  /// A closed [ApiRepository] left over after logging out, that allows
  /// keeping cubits alive while animating towards the login screen.
  final ApiRepository? apiRepository;

  const LoggedOutAuthState({
    this.selectedEnvironment = Environment.defaultEnvironment,
    this.apiRepository,
  });

  @override
  List<Object?> get props => [selectedEnvironment, apiRepository];
}

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

  /// Restore the authentication state from storage.
  ///
  /// Looks for existing credentials and, if available,
  /// uses them to create and emit a [LoggedInAuthState].
  /// Otherwise, emits a [LoggedOutAuthState].
  ///
  /// Also sets up push notifications.
  Future<void> load() async {
    const storage = FlutterSecureStorage();
    try {
      // Retrieve existing credentials.
      final stored = await storage.read(
        key: _credentialsStorageKey,
        iOptions: const IOSOptions(
          accessibility: KeychainAccessibility.first_unlock,
        ),
      );

      if (stored != null) {
        // Restore credentials from the storage.
        final credentials = Credentials.fromJson(stored);

        final Config apiConfig;
        if (Config.production != null &&
            credentials.tokenEndpoint == Config.production!.tokenEndpoint) {
          apiConfig = Config.production!;
        } else if (Config.local != null &&
            credentials.tokenEndpoint == Config.local!.tokenEndpoint) {
          apiConfig = Config.local!;
        } else {
          apiConfig = Config.staging;
        }

        // Log out if not all required scopes are available. After an update that
        // introduces a new scope, this will cause the app to log out and get new
        // credentials with the required scopes, instead of just getting 403's
        // until you manually log out.
        final scopes = credentials.scopes?.toSet() ?? <String>{};
        if (scopes.containsAll(Config.oauthScopes)) {
          // Create the API repository.
          final apiRepository = ConcrexitApiRepository(
            client: LoggingClient(
              credentials,
              identifier: apiConfig.identifier,
              secret: apiConfig.secret,
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
            config: apiConfig,
            onLogOut: logOut,
          );

          emit(LoggedInAuthState(apiRepository: apiRepository));
        } else {
          logOut();
        }
      } else {
        // Clear username for sentry.
        Sentry.configureScope((scope) => scope.setUser(null));
        emit(const LoggedOutAuthState());
      }
    } on PlatformException {
      try {
        storage.delete(
          key: _credentialsStorageKey,
          iOptions: const IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
          ),
        );
      } on PlatformException {
        // Ignore.
      }
      emit(const LoggedOutAuthState());
    }
  }

  /// Trigger an OAuth authentication flow to log in.
  ///
  /// This will try to let the user sign in. If successful, this emits a
  /// [LoggedInAuthState], which contains an [ApiRepository] that uses an
  /// authenticated client to make requests to the API. Furthermore, it will
  /// handle whatever need to happen upon loggin in, such as setting up push
  /// notifications.
  Future<void> logIn(Environment environment) async {
    emit(LoadingAuthState());

    final apiConfig = switch (environment) {
      Environment.staging => Config.staging,
      Environment.production => Config.production ?? Config.staging,
      Environment.local => Config.local ?? Config.staging,
    };

    // Prepare for the authentication flow.
    final grant = AuthorizationCodeGrant(
      apiConfig.identifier,
      apiConfig.authorizationEndpoint,
      apiConfig.tokenEndpoint,
      secret: apiConfig.secret,
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
      scopes: Config.oauthScopes,
    );

    try {
      // Present the authentication flow, and wait
      // for the redirect url with the credentials.
      final responseUrl = Uri.parse(
        await FlutterWebAuth2.authenticate(
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
        client: LoggingClient.fromClient(client),
        config: apiConfig,
        onLogOut: logOut,
      );

      emit(LoggedInAuthState(apiRepository: apiRepository));
    } on PlatformException catch (exception) {
      // Forward exceptions from the authentication flow.
      emit(FailureAuthState(message: exception.message));
      emit(LoggedOutAuthState(selectedEnvironment: environment));
    } on SocketException catch (_) {
      emit(const FailureAuthState(message: 'No internet.'));
      emit(LoggedOutAuthState(selectedEnvironment: environment));
    } on AuthorizationException catch (_) {
      emit(const FailureAuthState(message: 'Authorization failed.'));
      emit(LoggedOutAuthState(selectedEnvironment: environment));
    } catch (_) {
      emit(const FailureAuthState(message: 'An unknown error occurred.'));
      emit(LoggedOutAuthState(selectedEnvironment: environment));
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

    if (state is LoggedInAuthState) {
      emit(LoggedOutAuthState(apiRepository: state.apiRepository));
    }
  }

  /// Change the selected environment when on the login screen.
  void selectEnvironment(Environment environment) {
    final state = this.state;
    if (state is LoggedOutAuthState) {
      emit(LoggedOutAuthState(
        selectedEnvironment: environment,
        apiRepository: state.apiRepository,
      ));
    }
  }
}
