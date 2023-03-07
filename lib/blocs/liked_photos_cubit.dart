import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/ui/widgets/gallery.dart';

typedef LikedPhotosState = ListState<AlbumPhoto>;

class LikedPhotosCubit extends Cubit<LikedPhotosState>
    implements LikeableCubit<LikedPhotosState> {
  static const int firstPageSize = 60;
  static const int pageSize = 30;

  final ApiRepository api;

  int _nextOffset = 0;

  LikedPhotosCubit(this.api)
      : super(const LikedPhotosState.loading(results: []));

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final photos = await api.getLikedPhotos(
        limit: firstPageSize,
        offset: 0,
      );

      final isDone = photos.results.length == photos.count;

      _nextOffset = firstPageSize;

      emit(LikedPhotosState.success(results: photos.results, isDone: isDone));
    } on ApiException catch (exception) {
      emit(LikedPhotosState.failure(message: exception.message));
    }
  }

  Future<void> more() async {
    final oldState = state;

    // Ignore calls to `more()` if there is no data, or already more coming.
    if (oldState.isDone || oldState.isLoading || oldState.isLoadingMore) return;

    emit(oldState.copyWith(isLoadingMore: true));
    try {
      final photosResponse = await api.getLikedPhotos(
        limit: pageSize,
        offset: _nextOffset,
      );

      final photos = state.results + photosResponse.results;
      final isDone = photos.length >= photosResponse.count;

      _nextOffset += pageSize;

      emit(LikedPhotosState.success(
        results: photos,
        isDone: isDone,
      ));
    } on ApiException catch (exception) {
      emit(LikedPhotosState.failure(message: exception.message));
    }
  }

  @override
  Future<void> updateLike({required bool liked, required int index}) async {
    assert(index < state.results.length);
    if (state.isLoading) return;

    final oldNextOffset = _nextOffset;
    final oldState = state;
    final oldPhoto = oldState.results[index];

    if (oldPhoto.liked == liked) return;

    // If a photo is unliked, the offset should decrease by 1
    // so the next page is loaded correctly, and vice-versa.
    _nextOffset += liked ? 1 : -1;

    // Emit expected state after (un)liking.
    AlbumPhoto newphoto = oldPhoto.copyWith(
      liked: liked,
      numLikes: oldPhoto.numLikes + (liked ? 1 : -1),
    );

    List<AlbumPhoto> newphotos = state.results;
    newphotos[index] = newphoto;

    emit(state.copyWith(results: newphotos));

    try {
      await api.updateLiked(newphoto.pk, liked);
    } on ApiException {
      // Revert to state before (un)liking.
      _nextOffset = oldNextOffset;
      emit(oldState);
      rethrow;
    }
  }
}
