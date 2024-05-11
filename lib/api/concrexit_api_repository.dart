import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';

/// Provides an interface to the api.
///
/// Its methods may throw an [ApiException] if there are unexpected results.
/// In case credentials cannot be refreshed, this calls `logOut`, which should
/// close the client and indicates that the user is no longer logged in.
class ConcrexitApiRepository implements ApiRepository {
  ConcrexitApiRepository({
    /// Called when the client can no longer authenticate.
    required Function() onLogOut,
  });
}
