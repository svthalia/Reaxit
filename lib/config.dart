import 'package:flutter/widgets.dart';

/// This file specifies configuration options that can be passed
/// at compile time through `--dart-define`s, as is done by fastlane.
///
/// By default, you can sign in to staging. If THALIA_OAUTH_APP_SECRET and
/// THALIA_OAUTH_APP_ID are provided, you sign in to production by default.
/// You can make it possible to sign in to a custom server by providing
/// LOCAL_THALIA_OAUTH_APP_SECRET and LOCAL_THALIA_OAUTH_APP_ID, and optionally
/// LOCAL_THALIA_API_HOST, LOCAL_THALIA_API_SCHEME and LOCAL_THALIA_API_PORT.
///
/// If the `tostiXXX` variables are not defined, the T.O.S.T.I. API will not be
/// used, and the corresponding UI will not be shown. This is because there is
/// no staging T.O.S.T.I. server.
/// The `tostiApiScheme` and `tostiApiPort` can be used for testing locally.

const String sentryDSN = String.fromEnvironment('SENTRY_DSN');

const String tostiApiHost = String.fromEnvironment('TOSTI_API_HOST');
const String tostiApiIdentifier = String.fromEnvironment('TOSTI_OAUTH_APP_ID');
const String tostiApiSecret = String.fromEnvironment('TOSTI_OAUTH_APP_SECRET');

const bool tostiEnabled =
    tostiApiHost != '' && tostiApiIdentifier != '' && tostiApiSecret != '';
const String tostiApiScheme =
    String.fromEnvironment('TOSTI_API_SCHEME', defaultValue: 'https');
const int tostiApiPort =
    int.fromEnvironment('TOSTI_API_PORT', defaultValue: 443);

const List<String> tostiOauthScopes = [
  'read',
  'write',
  'orders:order',
  'orders:manage',
  'thaliedje:request',
  'thaliedje:manage',
];

class Config {
  final String host;
  final String secret;
  final String identifier;
  final String scheme;
  final int port;

  const Config({
    required this.host,
    required this.secret,
    required this.identifier,
    required this.scheme,
    required this.port,
  });

  /// The period after which objects are removed from the cache when not used.
  static const Duration cacheStalePeriod = Duration(days: 30);

  /// The maximum number of objects in the cache.
  ///
  /// Assuming most cached images are 'small' (300x300), the
  /// storage used will be +- 20KB * [cacheMaxObjects].
  static const int cacheMaxObjects = 2000;

  String get cdn => 'cdn.$host';
  Uri get authorizationEndpoint => Uri(
        scheme: scheme,
        host: host,
        port: port,
        path: 'user/oauth/authorize/',
      );

  Uri get tokenEndpoint => Uri(
        scheme: scheme,
        host: host,
        port: port,
        path: 'user/oauth/token/',
      );

  static Uri feedbackUri = Uri.parse(
    'https://github.com/svthalia/Reaxit/issues',
  );

  static Uri changelogUri = Uri.parse(
    'https://github.com/svthalia/Reaxit/releases',
  );

  Uri get termsAndConditionsUrl => Uri.parse(
        'https://$host/event-registration-terms/',
      );

  Uri get tpaySignDirectDebitMandateUrl => Uri.parse(
        'https://$host/user/finance/accounts/add/',
      );

  static const List<String> oauthScopes = [
    'read',
    'write',
    'activemembers:read',
    'announcements:read',
    'events:read',
    'events:register',
    'events:admin',
    'food:read',
    'food:order',
    'food:admin',
    'members:read',
    'photos:read',
    'profile:read',
    'profile:write',
    'pushnotifications:read',
    'pushnotifications:write',
    'payments:read',
    'payments:write',
    'payments:admin',
    'partners:read',
    'sales:read',
    'sales:order',
  ];

  static const Duration searchDebounceTime = Duration(milliseconds: 200);

  static const String versionNumber = 'v3.6.0';

  static const Config defaultConfig = Config.production ?? Config.staging;

  static const Config staging = Config(
    host: 'staging.thalia.nu',
    secret: 'Chwh1BE3MgfU1OZZmYRV3LU3e3GzpZJ6tiWrqzFY3dPhMlS7VYD3qMm1RC1pPBvg'
        '3WaWmJxfRq8bv5ElVOpjRZwabAGOZ0DbuHhW3chAMaNlOmwXixNfUJIKIBzlnr7I',
    identifier: '3zlt7pqGVMiUCGxOnKTZEpytDUN7haeFBP2kVkig',
    scheme: 'https',
    port: 443,
  );

  static const Config? production =
      (bool.hasEnvironment('THALIA_OAUTH_APP_SECRET') &&
              bool.hasEnvironment('THALIA_OAUTH_APP_ID'))
          ? Config(
              host: 'thalia.nu',
              secret: String.fromEnvironment('THALIA_OAUTH_APP_SECRET'),
              identifier: String.fromEnvironment('THALIA_OAUTH_APP_ID'),
              scheme: 'https',
              port: 443,
            )
          : null;

  static const Config? local =
      (bool.hasEnvironment('LOCAL_THALIA_OAUTH_APP_SECRET') &&
              bool.hasEnvironment('LOCAL_THALIA_OAUTH_APP_ID'))
          ? Config(
              host: String.fromEnvironment(
                'LOCAL_THALIA_API_HOST',
                defaultValue: '127.0.0.1',
              ),
              secret: String.fromEnvironment('LOCAL_THALIA_OAUTH_APP_SECRET'),
              identifier: String.fromEnvironment('LOCAL_THALIA_OAUTH_APP_ID'),
              scheme: String.fromEnvironment(
                'LOCAL_THALIA_API_SCHEME',
                defaultValue: 'http',
              ),
              port: int.fromEnvironment(
                'LOCAL_THALIA_API_PORT',
                defaultValue: 8000,
              ),
            )
          : null;

  static Config of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InheritedConfig>()!.config;
}

class InheritedConfig extends InheritedWidget {
  final Config config;

  const InheritedConfig({
    required this.config,
    required Widget child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(covariant InheritedConfig oldWidget) =>
      config != oldWidget.config;
}
