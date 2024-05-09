import 'package:reaxit/config.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/api/exceptions.dart';

/// Provides an interface to the api.
///
/// Its methods may throw an [ApiException] if there are unexpected results.
/// In case credentials cannot be refreshed, this calls `logOut`, which should
/// close the client and indicates that the user is no longer logged in.
abstract class ApiRepository {
  final Config config;

  ApiRepository(this.config);

  /// Closes the connection to the api. This must be called when logging out.
  void close();

  /// Cancel the [EventRegistration] with `registrationPk`
  /// for the [Event] with `eventPk`.
  Future<void> cancelRegistration({
    required int eventPk,
    required int registrationPk,
  });

  /// Mark the user's registration for [Event] `pk` as present, using `token`.
  Future<String> markPresentEventRegistration({
    required int eventPk,
    required String token,
  });

  /// Delete the payment for registration `registrationPk`.
  Future<void> markNotPaidAdminEventRegistration({
    required int registrationPk,
  });

  /// Delete the payment for food order `orderPk`.
  Future<void> markNotPaidAdminFoodOrder({
    required int orderPk,
  });

  /// Cancel your [FoodOrder] for the [FoodEvent] with the `pk`.
  Future<void> cancelFoodOrder(int pk);

  /// Update the avatar of the logged in member.
  ///
  /// `filePath` should be the path of a jpg image.
  Future<void> updateAvatar(String file);

  /// Update the description of the logged in member.
  Future<void> updateDescription(String description);

  /// Get the [Album] with the `slug`.
  Future<Album> getAlbum({required String slug});

  /// Create or delete a like on the photo with the `id`.
  Future<void> updateLiked(int id, bool liked);

  /// Get a list of [ListAlbum]s.
  ///
  /// Use `limit` and `offset` for pagination. [ListResponse.count] is the
  /// total number of [ListAlbum]s that can be returned.
  /// Use `search` to filter on name or date.
  Future<ListResponse<ListAlbum>> getAlbums({
    String? search,
    int? limit,
    int? offset,
  });
}
