import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:oauth2/oauth2.dart';
import 'package:reaxit/config.dart' as config;
import 'package:reaxit/tosti/tosti_api_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

final _redirectUrl = Uri.parse(
  'nu.thalia://tosti-callback',
);

final Uri _authorizationEndpoint = Uri(
  scheme: config.tostiApiScheme,
  host: config.tostiApiHost,
  port: config.tostiApiPort,
  path: 'oauth/authorize/',
);

final Uri _tokenEndpoint = Uri(
  scheme: config.tostiApiScheme,
  host: config.tostiApiHost,
  port: config.tostiApiPort,
  path: 'oauth/token/',
);

const _credentialsStorageKey = 'ThaliApp T.O.S.T.I. OAuth2 credentials';

abstract class TostiAuthState extends Equatable {
  const TostiAuthState();

  @override
  List<Object?> get props => [];
}

/// Authentication is loading.
class LoadingTostiAuthState extends TostiAuthState {}

/// Not logged in.
class LoggedOutTostiAuthState extends TostiAuthState {}

/// Logged in.
class LoggedInTostiAuthState extends TostiAuthState {
  final TostiApiRepository apiRepository;

  const LoggedInTostiAuthState({required this.apiRepository});

  @override
  List<Object?> get props => [apiRepository];
}

/// Something went wrong.
class FailureTostiAuthState extends TostiAuthState {
  final String? message;

  const FailureTostiAuthState({this.message});

  @override
  List<Object?> get props => [message];
}

/// The [Cubit] that handles authentication.
///
/// This also handles other functionality that
/// needs to be done upon logging in or out.
class TostiAuthCubit extends Cubit<TostiAuthState> {
  TostiAuthCubit() : super(LoadingTostiAuthState());

  /// Restore the authentication state from storage.
  ///
  /// Looks for existing credentials and, if available,
  /// uses them to create and emit a [LoggedInTostiAuthState].
  /// Otherwise, emits a [LoggedOutTostiAuthState].
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
      if (scopes.containsAll(config.tostiOauthScopes)) {
        // Create the API repository.
        final apiRepository = TostiApiRepository(
          client: Client(
            credentials,
            identifier: config.tostiApiIdentifier,
            secret: config.tostiApiSecret,
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

        emit(LoggedInTostiAuthState(apiRepository: apiRepository));
      } else {
        logOut();
      }
    } else {
      emit(LoggedOutTostiAuthState());
    }
  }

  /// Trigger an OAuth authentication flow to log in.
  ///
  /// This will try to let the user sign in. If successful, this emits
  /// a [LoggedInTostiAuthState], which contains a [TostiApiRepository]
  /// that uses an authenticated client to make requests to the API.
  Future<void> logIn() async {
    emit(LoadingTostiAuthState());

    // Prepare for the authentication flow.
    final grant = AuthorizationCodeGrant(
      config.tostiApiIdentifier,
      _authorizationEndpoint,
      _tokenEndpoint,
      secret: config.tostiApiSecret,
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
      scopes: config.tostiOauthScopes,
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

      final apiRepository = TostiApiRepository(
        client: client,
        onLogOut: logOut,
      );

      emit(LoggedInTostiAuthState(apiRepository: apiRepository));
    } on PlatformException catch (exception) {
      // Forward exceptions from the authentication flow.
      emit(FailureTostiAuthState(message: exception.message));
    } on SocketException catch (_) {
      emit(const FailureTostiAuthState(message: 'No internet.'));
    } on AuthorizationException catch (_) {
      emit(const FailureTostiAuthState(message: 'Authorization failed.'));
    } catch (_) {
      emit(const FailureTostiAuthState(message: 'An unknown error occurred.'));
    }
  }

  /// Log out, and perform the necessary cleaning up.
  ///
  /// Closes the authenticated client, and removes
  /// the credentials from secure storage.
  Future<void> logOut() async {
    final state = this.state;
    if (state is LoggedInTostiAuthState) {
      state.apiRepository.close();
    }

    // Remove the credentials from secure storage.
    const storage = FlutterSecureStorage();
    await storage.delete(
      key: _credentialsStorageKey,
      iOptions:
          const IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );

    emit(LoggedOutTostiAuthState());
  }
}
