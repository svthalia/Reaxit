import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:oauth2/oauth2.dart';

final _identifier = '3zlt7pqGVMiUCGxOnKTZEpytDUN7haeFBP2kVkig';
final _secret =
    'Chwh1BE3MgfU1OZZmYRV3LU3e3GzpZJ6tiWrqzFY3dPhMlS7VYD3qMm1RC1pPBvg'
    '3WaWmJxfRq8bv5ElVOpjRZwabAGOZ0DbuHhW3chAMaNlOmwXixNfUJIKIBzlnr7I';

final _authorizationEndpoint = Uri.parse(
  'https://staging.thalia.nu/user/oauth/authorize/',
);

final _tokenEndpoint = Uri.parse(
  'https://staging.thalia.nu/user/oauth/token/',
);

final _redirectUrl = Uri.parse(
  'nu.thalia://callback',
);

final _scopes = <String>[
  'read',
  'write',
  'members:read',
  'activemembers:read',
];

final _credentialsStorageKey = 'ThaliApp OAuth2 credentials';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
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

  LoggingInAuthState(
      {required this.authorizeUrl,
      required this.redirectUrl,
      required this.grant});

  @override
  List<Object> get props => [authorizeUrl, grant];
}

/// Logged in.
class LoggedInAuthState extends AuthState {
  /// An [http.BaseClient] that adds an OAuth2 token to all requests.
  final Client client;

  /// A callback that can be used to indicate to the [AuthBloc] that the client
  /// no longer works (e.g. its token is revoked);
  final Function() logOut;

  LoggedInAuthState({required this.client, required this.logOut});

  @override
  List<Object> get props => [client, logOut];
}

/// Something went wrong.
class FailureAuthState extends AuthState {
  /// An [http.BaseClient] that adds an OAuth2 token to all requests.
  final String? message;

  FailureAuthState({this.message});

  @override
  List<Object> get props => [message ?? ''];
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
    print(event);
    if (event is LoadAuthEvent) {
      yield* _mapLoadAuthEventToState();
    } else if (event is LogInAuthEvent) {
      yield* _mapLogInAuthEventToState();
    } else if (event is LogOutAuthEvent) {
      yield* _mapLogOutAuthEventToState();
    }
  }

  Stream<AuthState> _mapLoadAuthEventToState() async* {
    final _storage = FlutterSecureStorage();
    final stored = await _storage.read(
      key: _credentialsStorageKey,
      iOptions: IOSOptions(accessibility: IOSAccessibility.first_unlock),
    );

    if (stored != null) {
      final credentials = Credentials.fromJson(stored);
      yield LoggedInAuthState(
        client: Client(
          credentials,
          identifier: _identifier,
          secret: _secret,
        ),
        logOut: () => add(LogOutAuthEvent()),
      );
    } else {
      yield LoggedOutAuthState();
    }
  }

  Stream<AuthState> _mapLogInAuthEventToState() async* {
    yield LoadingAuthState();

    final grant = AuthorizationCodeGrant(
        _identifier, _authorizationEndpoint, _tokenEndpoint,
        secret: _secret);

    final authorizeUrl = grant.getAuthorizationUrl(
      _redirectUrl,
      scopes: _scopes,
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

      final _storage = FlutterSecureStorage();
      await _storage.write(
        key: _credentialsStorageKey,
        value: client.credentials.toJson(),
        iOptions: IOSOptions(accessibility: IOSAccessibility.first_unlock),
      );
      yield LoggedInAuthState(
        client: client,
        logOut: () => add(LogOutAuthEvent()),
      );
    } on PlatformException catch (exception) {
      yield FailureAuthState(message: exception.message);
    } on SocketException catch (_) {
      yield FailureAuthState(message: 'No internet.');
    } catch (_) {
      yield FailureAuthState(message: 'An unknown error occured.');
    }
  }

  Stream<AuthState> _mapLogOutAuthEventToState() async* {
    var state = this.state;
    if (state is LoggedInAuthState) {
      state.client.close();
    }
    final _storage = FlutterSecureStorage();
    await _storage.delete(
      key: _credentialsStorageKey,
      iOptions: IOSOptions(accessibility: IOSAccessibility.first_unlock),
    );
    yield LoggedOutAuthState();
  }
}
