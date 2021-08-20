import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:oauth2/oauth2.dart';
import 'package:reaxit/api_repository.dart';
import 'package:reaxit/config.dart' as config;
import 'package:sentry_flutter/sentry_flutter.dart';

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

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Authentication is loading.
class LoadingAuthState extends AuthState {}

/// Not logged in.
class LoggedOutAuthState extends AuthState {}

/// Logging in.
///
/// The UI should present a webview with `authorizeUrl`, and after the user
/// signs in, fire an [CompleteLogInAuthEvent] with the right `responseUrl`.
class LoggingInAuthState extends AuthState {
  /// The url to be used for signing in.
  final Uri authorizeUrl;

  /// The start of the expected `responseUrl`.
  final Uri redirectUrl;

  /// The grant to which [authorizeUrl] belongs.
  /// Should be included in the [CompleteLogInAuthEvent].
  final AuthorizationCodeGrant grant;

  const LoggingInAuthState({
    required this.authorizeUrl,
    required this.redirectUrl,
    required this.grant,
  });

  @override
  List<Object?> get props => [authorizeUrl, grant];
}

/// Logged in.
class LoggedInAuthState extends AuthState {
  final ApiRepository apiRepository;

  LoggedInAuthState({required Client client, required void Function() logOut})
      : apiRepository = ApiRepository(
          client: client,
          logOut: logOut,
        );

  @override
  List<Object?> get props => [apiRepository];
}

/// Something went wrong.
class FailureAuthState extends AuthState {
  /// An [http.BaseClient] that adds an OAuth2 token to all requests.
  final String? message;

  const FailureAuthState({this.message});

  @override
  List<Object?> get props => [message];
}

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoadAuthEvent extends AuthEvent {}

class LogOutAuthEvent extends AuthEvent {}

class LogInAuthEvent extends AuthEvent {}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(LoadingAuthState());

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    if (event is LoadAuthEvent) {
      yield* _mapLoadAuthEventToState();
    } else if (event is LogInAuthEvent) {
      yield* _mapLogInAuthEventToState();
    } else if (event is LogOutAuthEvent) {
      yield* _mapLogOutAuthEventToState();
    }
  }

  Stream<AuthState> _mapLoadAuthEventToState() async* {
    const storage = FlutterSecureStorage();
    final stored = await storage.read(
      key: _credentialsStorageKey,
      iOptions: const IOSOptions(accessibility: IOSAccessibility.first_unlock),
    );

    if (stored != null) {
      final credentials = Credentials.fromJson(stored);
      yield LoggedInAuthState(
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
                accessibility: IOSAccessibility.first_unlock,
              ),
            );
          },
          httpClient: SentryHttpClient(),
        ),
        logOut: () => add(LogOutAuthEvent()),
      );
    } else {
      // Clear username for sentry.
      Sentry.configureScope((scope) => scope.user = null);
      yield LoggedOutAuthState();
    }
  }

  Stream<AuthState> _mapLogInAuthEventToState() async* {
    yield LoadingAuthState();

    final grant = AuthorizationCodeGrant(
      config.apiIdentifier,
      _authorizationEndpoint,
      _tokenEndpoint,
      secret: config.apiSecret,
      onCredentialsRefreshed: (credentials) async {
        const _storage = FlutterSecureStorage();
        await _storage.write(
          key: _credentialsStorageKey,
          value: credentials.toJson(),
          iOptions:
              const IOSOptions(accessibility: IOSAccessibility.first_unlock),
        );
      },
    );

    final authorizeUrl = grant.getAuthorizationUrl(
      _redirectUrl,
      scopes: config.oauthScopes,
    );

    try {
      final responseUrl = Uri.parse(
        await FlutterWebAuth.authenticate(
          url: authorizeUrl.toString(),
          callbackUrlScheme: _redirectUrl.scheme,
        ),
      );

      final client = await grant.handleAuthorizationResponse(
        responseUrl.queryParameters,
      );

      const storage = FlutterSecureStorage();
      await storage.write(
        key: _credentialsStorageKey,
        value: client.credentials.toJson(),
        iOptions:
            const IOSOptions(accessibility: IOSAccessibility.first_unlock),
      );
      yield LoggedInAuthState(
        client: client,
        logOut: () => add(LogOutAuthEvent()),
      );
    } on PlatformException catch (exception) {
      yield FailureAuthState(message: exception.message);
    } on SocketException catch (_) {
      yield const FailureAuthState(message: 'No internet.');
    } on AuthorizationException catch (_) {
      yield const FailureAuthState(message: 'Authorization failed.');
    } catch (_) {
      yield const FailureAuthState(message: 'An unknown error occurred.');
    }
  }

  Stream<AuthState> _mapLogOutAuthEventToState() async* {
    var state = this.state;
    if (state is LoggedInAuthState) {
      state.apiRepository.client.close();
    }
    const storage = FlutterSecureStorage();
    await storage.delete(
      key: _credentialsStorageKey,
      iOptions: const IOSOptions(accessibility: IOSAccessibility.first_unlock),
    );
    // Clear username for sentry.
    Sentry.configureScope((scope) => scope.user = null);
    yield LoggedOutAuthState();
  }

  // TODO: Someday: make AuthBloc a cubit?
}
