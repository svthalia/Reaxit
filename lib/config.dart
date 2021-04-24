/// This file specifies configuration options that can be passed
/// at compile time through environment variables.
///
/// The default values can be used on the staging server. If some variables are
/// specified, be sure to specify all.

const String apiHost = String.fromEnvironment(
  'API_HOST',
  defaultValue: 'staging.thalia.nu',
);

const String apiSecret = String.fromEnvironment(
  'API_SECRET',
  defaultValue:
      'Chwh1BE3MgfU1OZZmYRV3LU3e3GzpZJ6tiWrqzFY3dPhMlS7VYD3qMm1RC1pPBvg'
      '3WaWmJxfRq8bv5ElVOpjRZwabAGOZ0DbuHhW3chAMaNlOmwXixNfUJIKIBzlnr7I',
);

const String apiIdentifier = String.fromEnvironment(
  'API_IDENTIFIER',
  defaultValue: '3zlt7pqGVMiUCGxOnKTZEpytDUN7haeFBP2kVkig',
);

const String sentryDSN = String.fromEnvironment('SENTRY_DSN');
