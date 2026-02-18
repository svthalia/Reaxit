import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/ui/widgets/gallery.dart';

abstract class PhotosCubit extends Cubit<ListState<AlbumPhoto>>
    implements GalleryCubit<ListState<AlbumPhoto>> {
  static const int firstPageSize = 60;
  static const int pageSize = 30;

  final ApiRepository api;
  int _nextOffset = 0;

  PhotosCubit(this.api) : super(const ListState.loading(results: []));

  Future<ListResponse<AlbumPhoto>> fetchPhotos({
    required int limit,
    required int offset,
  });

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final photos = await fetchPhotos(limit: firstPageSize, offset: 0);

      final isDone = photos.results.length == photos.count;
      _nextOffset = firstPageSize;

      emit(
        ListState.success(
          results: photos.results,
          isDone: isDone,
          count: photos.count,
        ),
      );
    } on ApiException catch (exception) {
      emit(ListState.failure(message: exception.message));
    }
  }

  @override
  Future<void> more() async {
    final oldState = state;
    if (oldState.isDone || oldState.isLoading || oldState.isLoadingMore) return;

    emit(oldState.copyWith(isLoadingMore: true));
    try {
      final photosResponse = await fetchPhotos(
        limit: pageSize,
        offset: _nextOffset,
      );

      final photos = state.results + photosResponse.results;
      final isDone = photos.length >= photosResponse.count;

      _nextOffset += pageSize;

      emit(
        ListState.success(
          results: photos,
          isDone: isDone,
          count: photosResponse.count,
        ),
      );
    } on ApiException catch (exception) {
      emit(ListState.failure(message: exception.message));
    }
  }

  @override
  Future<void> updateLike({required bool liked, required int index}) async {
    assert(index < state.results.length);
    if (state.isLoading) return;

    final oldState = state;
    final oldPhoto = oldState.results[index];
    if (oldPhoto.liked == liked) return;

    final newPhoto = oldPhoto.copyWith(
      liked: liked,
      numLikes: oldPhoto.numLikes + (liked ? 1 : -1),
    );

    final newPhotos = List<AlbumPhoto>.from(state.results);
    newPhotos[index] = newPhoto;

    emit(state.copyWith(results: newPhotos));

    try {
      await api.updateLiked(newPhoto.pk, liked);
      _nextOffset += liked ? 1 : -1;
    } catch (_) {
      emit(oldState);
      rethrow;
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
