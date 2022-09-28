import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';

typedef AlbumState = DetailState<Album>;

class AlbumCubit extends Cubit<AlbumState> {
  final ApiRepository api;

  AlbumCubit(this.api) : super(const AlbumState.loading());

  Future<void> load(String slug) async {
    emit(state.copyWith(isLoading: true));
    try {
      final album = await api.getAlbum(slug: slug);
      emit(AlbumState.result(result: album));
    } on ApiException catch (exception) {
      emit(AlbumState.failure(
        message: exception.getMessage(notFound: 'The album does not exist.'),
      ));
    }
  }
}
