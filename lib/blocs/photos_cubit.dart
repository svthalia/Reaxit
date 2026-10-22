import 'package:image_cropper/image_cropper.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/blocs/list_cubit.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/ui/widgets/gallery.dart';

abstract class PhotosCubit extends SingleListCubit<AlbumPhoto>
    implements GalleryCubit<ListState<AlbumPhoto>> {
  static const int firstPageSize = 60;
  static const int pageSize = 30;

  PhotosCubit(super.api);

  int extraOffset = 0;

  Future<ListResponse<AlbumPhoto>> fetchPhotos({
    required int limit,
    required int offset,
  });

  @override
  Future<ListResponse<AlbumPhoto>> getDown(int offset) {
    assert(searchQuery == null); // We cannot search photos
    return fetchPhotos(
      limit: firstPageSize,
      offset: offset + extraOffset,
    );
  }

  @override
  List<AlbumPhoto> combineDown(
    List<AlbumPhoto> downResults,
    ListState<AlbumPhoto> oldstate,
  ) => getResults(oldstate) + downResults;

  @override
  ListState<AlbumPhoto> empty(String? query) =>
      const ErrorState('No liked photos found.');

  @override
  Future<void> updateLike({required bool liked, required int index}) async {
    switch (super.state) {
      case LoadingState():
      case ErrorState():
        return;
      case ResultState<InnerListState<AlbumPhoto>>(result: final state):
        assert(index < state.results.length);

        final oldState = super.state;
        final oldPhoto = state.results[index];

        if (oldPhoto.liked == liked) return;

        // Emit expected state after (un)liking.
        AlbumPhoto newphoto = oldPhoto.copyWith(
          liked: liked,
          numLikes: oldPhoto.numLikes + (liked ? 1 : -1),
        );

        List<AlbumPhoto> newphotos = state.results;
        newphotos[index] = newphoto;

        emit(
          ResultState(state.copyWith(results: newphotos, isDone: state.isDone)),
        );

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
}

typedef LikedPhotosState = ListState<AlbumPhoto>;

class LikedPhotosCubit extends PhotosCubit {
  LikedPhotosCubit(super.api);

  @override
  Future<ListResponse<AlbumPhoto>> fetchPhotos({
    required int limit,
    required int offset,
  }) {
    return api.getLikedPhotos(limit: limit, offset: offset);
  }
}

typedef FaceDetectionPhotosState = ListState<AlbumPhoto>;

class FaceDetectionPhotosCubit extends PhotosCubit {
  FaceDetectionPhotosCubit(super.api);

  @override
  Future<ListResponse<AlbumPhoto>> fetchPhotos({
    required int limit,
    required int offset,
  }) {
    return api.getFaceDetectionMatches(limit: limit, offset: offset);
  }
}

typedef ReferencePhotosState = ListState<AlbumPhoto>;

class ReferencePhotosCubit extends PhotosCubit {
  ReferencePhotosCubit(super.api);

  @override
  Future<ListResponse<AlbumPhoto>> fetchPhotos({
    required int limit,
    required int offset,
  }) {
    return api.getReferencePhotos(limit: limit, offset: offset);
  }

  Future<void> updateReferencePhoto(CroppedFile file) async {
    await api.updateReferencePhoto(file.path);
    await load();
  }

  Future<void> deleteReferencePhoto(int photoPk) async {
    await api.deleteReferencePhoto(photoPk:photoPk);
    await load();
  }
}