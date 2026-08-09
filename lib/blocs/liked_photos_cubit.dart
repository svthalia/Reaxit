import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/blocs/list_cubit.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/ui/widgets/gallery.dart';

typedef LikedPhotosState = ListState<AlbumPhoto>;

class LikedPhotosCubit extends SingleListCubit<AlbumPhoto>
    implements GalleryCubit<LikedPhotosState> {
  static const int firstPageSize = 60;
  static const int pageSize = 30;

  LikedPhotosCubit(super.api);

  int extraOffset = 0;

  @override
  Future<ListResponse<AlbumPhoto>> getDown(int offset) {
    assert(searchQuery == null); // We cannot search photos
    return api.getLikedPhotos(
      limit: firstPageSize,
      offset: offset + extraOffset,
    );
  }

  @override
  List<AlbumPhoto> combineDown(
    List<AlbumPhoto> downResults,
    ListState<AlbumPhoto> oldstate,
  ) => oldstate.results + downResults;

  @override
  ListState<AlbumPhoto> empty(String? query) =>
      const ListState.failure(message: 'No liked photos found.');

  @override
  Future<void> updateLike({required bool liked, required int index}) async {
    assert(index < state.results.length);
    if (state.isLoading) return;

    final oldState = state;
    final oldPhoto = oldState.results[index];

    if (oldPhoto.liked == liked) return;

    // Emit expected state after (un)liking.
    AlbumPhoto newphoto = oldPhoto.copyWith(
      liked: liked,
      numLikes: oldPhoto.numLikes + (liked ? 1 : -1),
    );

    List<AlbumPhoto> newphotos = state.results;
    newphotos[index] = newphoto;

    emit(ListState.success(results: newphotos, isDone: state.isDone));

    try {
      await api.updateLiked(newphoto.pk, liked);

      // If a photo is succesfully unliked, the offset should decrease by 1
      // so the next page is loaded correctly.
      extraOffset += liked ? 1 : -1;
    } on ApiException {
      // Revert to state before (un)liking.
      emit(oldState);
      rethrow;
    }
  }
}
