import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/ui/widgets/gallery.dart';

typedef AlbumState = DetailState<Album>;

class AlbumCubit extends Cubit<AlbumState>
    implements LikeableCubit<AlbumState> {
  final ApiRepository api;

  AlbumCubit(this.api) : super(const LoadingState());

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
