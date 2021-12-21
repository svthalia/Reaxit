import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models/album.dart';

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
      emit(AlbumState.failure(message: _failureMessage(exception)));
    }
  }

  String _failureMessage(ApiException exception) {
    switch (exception) {
      case ApiException.noInternet:
        return 'Not connected to the internet.';
      case ApiException.notFound:
        return 'The album does not exist.';
      default:
        return 'An unknown error occurred.';
    }
  }
}
