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
}
