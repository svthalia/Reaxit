import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/ui/widgets/gallery.dart';

typedef AlbumState = DetailState<Album>;

/// The state manager for the [AlbumScreen] screen.
///
/// When [load]ed, fetches the relevant album from [api].
/// Also manages liked photo status locally and in [api].
class AlbumCubit extends Cubit<AlbumState> implements GalleryCubit<AlbumState> {
  final ApiRepository api;

  AlbumCubit(this.api) : super(const LoadingState());

  /// Updates the like status of photo [index] to [liked] both locally and in [api].
  ///
  /// Does not update [state] and rethrows on [ApiException].
  /// Does nothing if [state] is [LoadingState] or [ErrorState].
  /// Does nothing if [liked] is equal to the current liked status.
  @override
  Future<void> updateLike({required bool liked, required int index}) async {
    if (state is! ResultState) return;
    final oldState = state as ResultState<Album>;
    final oldPhoto = oldState.result.photos[index];
    if (oldPhoto.liked == liked) return;

    // Emit expected state after (un)liking.
    AlbumPhoto newphoto = oldPhoto.copyWith(
      liked: liked,
      numLikes: oldPhoto.numLikes + (liked ? 1 : -1),
    );
    List<AlbumPhoto> newphotos = [...oldState.result.photos];
    newphotos[index] = newphoto;
    emit(ResultState(
      oldState.result.copyWith(photos: newphotos),
    ));

    try {
      await api.updateLiked(newphoto.pk, liked);
    } on ApiException {
      // Revert to state before (un)liking.
      emit(oldState);
      rethrow;
    }
  }

  @override
  Future<void> more() async {}

  /// Initializes [state] to proper [ResultState] for [AlbumScreen] by fetching all photos and properties of the album with slug [slug] from [api].
  ///
  /// [state] defaults to [LoadingState] while waiting for a response from [api].
  /// On [ApiException], [state] is set to [ErrorState] instead.
  Future<void> load(String slug) async {
    emit(LoadingState.from(state));
    try {
      final album = await api.getAlbum(slug: slug);
      emit(ResultState(album));
    } on ApiException catch (exception) {
      emit(ErrorState(
        exception.getMessage(notFound: 'The album does not exist.'),
      ));
    }
  }
}
