import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';

typedef LikedPhotosState = DetailState<List<AlbumPhoto>>;

class LikedPhotosCubit extends Cubit<LikedPhotosState> {
  final ApiRepository api;

  LikedPhotosCubit(this.api) : super(const LoadingState());

  Future<void> load() async {
    emit(LoadingState.from(state));
    try {
      final photos = await api.getLikedPhotos();
      emit(ResultState(photos.results));
    } on ApiException catch (exception) {
      emit(ErrorState(
        exception.message,
      ));
    }
  }

  Future<void> updateLike({required bool liked, required int index}) async {
    if (state is! ResultState) return;
    final oldState = state as ResultState<List<AlbumPhoto>>;
    final oldPhoto = oldState.result[index];
    if (oldPhoto.liked == liked) return;

    // Emit expected state after (un)liking.
    AlbumPhoto newphoto = oldPhoto.copyWith(
      liked: liked,
      numLikes: oldPhoto.numLikes + (liked ? 1 : -1),
    );
    List<AlbumPhoto> newphotos = oldState.result;
    newphotos[index] = newphoto;
    emit(ResultState(newphotos));
    try {
      await api.updateLiked(newphoto.pk, liked);
    } on ApiException {
      // Revert to state before (un)liking.
      emit(oldState);
      rethrow;
    }
  }
}
