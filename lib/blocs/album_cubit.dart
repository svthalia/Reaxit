import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models/album.dart';

class AlbumCubit extends Cubit<DetailState<Album>> {
  final ApiRepository api;

  AlbumCubit(this.api) : super(DetailState<Album>.loading());

  Future<void> load(int pk) async {
    emit(state.copyWith(isLoading: true));
    try {
      final album = await api.getAlbum(pk: pk);
      emit(DetailState.result(result: album));
    } on ApiException catch (exception) {
      emit(DetailState.failure(message: _failureMessage(exception)));
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
