/// This file specifies configuration options that can be passed
/// at compile time through `--dart-define`s, as is done by fastlane.
///
/// The default values can be used on the staging server. If some variables are
/// specified, be sure to specify all.

/// The domain of the concrexit server.
const String apiHost = String.fromEnvironment(
  'THALIA_API_HOST',
  defaultValue: 'staging.thalia.nu',
);

/// The OAuth client secret used to connect to the API.
const String apiSecret = String.fromEnvironment(
  'THALIA_OAUTH_APP_SECRET',
  defaultValue:
      'Chwh1BE3MgfU1OZZmYRV3LU3e3GzpZJ6tiWrqzFY3dPhMlS7VYD3qMm1RC1pPBvg'
      '3WaWmJxfRq8bv5ElVOpjRZwabAGOZ0DbuHhW3chAMaNlOmwXixNfUJIKIBzlnr7I',
);

/// The OAuth client id used to connect to the API.
const String apiIdentifier = String.fromEnvironment(
  'THALIA_OAUTH_APP_ID',
  defaultValue: '3zlt7pqGVMiUCGxOnKTZEpytDUN7haeFBP2kVkig',
);

/// The Sentry DSN used to report errors to.
const String sentryDSN = String.fromEnvironment('SENTRY_DSN');

/// The scopes to request permission for when connecting to the API.
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
  // 'sales:read',
  // 'sales:write',
];

/// The time to wait before fetching results
/// from the API after typing in a search bar.
const Duration searchDebounceTime = Duration(milliseconds: 200);

const String versionNumber = 'v3.0.2';

final Uri feedbackUri = Uri.parse(
  'https://github.com/svthalia/Reaxit/issues',
);

final Uri changelogUri = Uri.parse(
  'https://github.com/svthalia/Reaxit/releases',
);

const String termsAndConditionsUrl =
    'https://thalia.nu/event-registration-terms/';

/// The period after which objects are removed from the cache when not used.
const Duration cacheStalePeriod = Duration(days: 30);

/// The maximum number of objects in the cache.
///
/// Assuming most cached images are 'small' (300x300), the
/// storage used will be +- 20KB * [cacheMaxObjects].
const int cacheMaxObjects = 2000;
