/// This file specifies configuration options that can be passed
/// at compile time through `--dart-define`s, as is done by fastlane.
///
/// The default values can be used on the staging server. If some variables are
/// specified, be sure to specify all.
///
/// If the `tostiXXX` variables are not defined, the T.O.S.T.I. API will not be
/// used, and the corresponding UI will not be shown. This is because there is
/// no staging T.O.S.T.I. server.
/// The `tostiApiScheme` and `tostiApiPort` can be used for testing locally.
const String apiHost = String.fromEnvironment(
  'THALIA_API_HOST',
  defaultValue: 'staging.thalia.nu',
);

const String apiSecret = String.fromEnvironment(
  'THALIA_OAUTH_APP_SECRET',
  defaultValue:
      'Chwh1BE3MgfU1OZZmYRV3LU3e3GzpZJ6tiWrqzFY3dPhMlS7VYD3qMm1RC1pPBvg'
      '3WaWmJxfRq8bv5ElVOpjRZwabAGOZ0DbuHhW3chAMaNlOmwXixNfUJIKIBzlnr7I',
);

const String apiIdentifier = String.fromEnvironment(
  'THALIA_OAUTH_APP_ID',
  defaultValue: '3zlt7pqGVMiUCGxOnKTZEpytDUN7haeFBP2kVkig',
);

const String apiScheme =
    String.fromEnvironment('THALIA_API_SCHEME', defaultValue: 'https');
const int apiPort = int.fromEnvironment('THALIA_API_PORT', defaultValue: 443);

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

const List<String> oauthScopes = [
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

const Duration searchDebounceTime = Duration(milliseconds: 200);

const String versionNumber = 'v3.3.2';

final Uri feedbackUri = Uri.parse(
  'https://github.com/svthalia/Reaxit/issues',
);

final Uri changelogUri = Uri.parse(
  'https://github.com/svthalia/Reaxit/releases',
);

final Uri termsAndConditionsUrl = Uri.parse(
  'https://$apiHost/event-registration-terms/',
);

final Uri tpaySignDirectDebitMandateUrl = Uri.parse(
  'https://$apiHost/user/finance/accounts/add/',
);

/// The period after which objects are removed from the cache when not used.
const Duration cacheStalePeriod = Duration(days: 30);

/// The maximum number of objects in the cache.
///
/// Assuming most cached images are 'small' (300x300), the
/// storage used will be +- 20KB * [cacheMaxObjects].
const int cacheMaxObjects = 2000;
