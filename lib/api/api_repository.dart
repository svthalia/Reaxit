import 'package:reaxit/api/exceptions.dart';

/// Provides an interface to the api.
///
/// Its methods may throw an [ApiException] if there are unexpected results.
/// In case credentials cannot be refreshed, this calls `logOut`, which should
/// close the client and indicates that the user is no longer logged in.
abstract class ApiRepository {
  ApiRepository();

  /// Closes the connection to the api. This must be called when logging out.
  void close();
}
