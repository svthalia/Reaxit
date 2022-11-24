import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';

typedef AlbumState = DetailState<Album>;

class AlbumScreenState extends Equatable {
  /// This can only be null when [isLoading] or [hasException] is true.
  final Album? album;
  final bool isOpen;
  final int? initialGalleryIndex;

  final String? message;
  final bool isLoading;
  bool get hasException => message != null;

  @protected
  const AlbumScreenState({
    required this.album,
    required this.isLoading,
    required this.message,
    this.isOpen = false,
    this.initialGalleryIndex,
  })  : assert(
          album != null || isLoading || message != null,
          'album can only be null when isLoading or hasException is true.',
        ),
        assert(
          isOpen || initialGalleryIndex == null,
          'initialGalleryIndex can only be set when isOpen is true.',
        ),
        assert(
          initialGalleryIndex != null || !isOpen,
          'initialGalleryIndex must be set when isOpen is true.',
        ),
        assert(
          !isOpen || album != null,
          'album must be set when isOpen is true.',
        );

  @override
  List<Object?> get props => [
        album,
        message,
        isLoading,
        isOpen,
        initialGalleryIndex,
      ];

  AlbumScreenState copyWith({
    Album? album,
    List<AdminEventRegistration>? registrations,
    bool? isLoading,
    String? message,
    bool? isOpen,
    int? initialGalleryIndex,
  }) =>
      AlbumScreenState(
        album: album ?? this.album,
        isLoading: isLoading ?? this.isLoading,
        message: message ?? this.message,
        isOpen: isOpen ?? this.isOpen,
        initialGalleryIndex: (isOpen ?? this.isOpen)
            ? (initialGalleryIndex ?? this.initialGalleryIndex)
            : null,
      );

  const AlbumScreenState.result(
      {required this.album, required this.isOpen, this.initialGalleryIndex})
      : message = null,
        isLoading = false;

  const AlbumScreenState.loading()
      : message = null,
        album = null,
        isLoading = true,
        isOpen = false,
        initialGalleryIndex = null;

  const AlbumScreenState.failure({required String this.message})
      : album = null,
        isLoading = false,
        isOpen = false,
        initialGalleryIndex = null;
}

class AlbumCubit extends Cubit<AlbumScreenState> {
  final ApiRepository api;

  AlbumCubit(this.api) : super(const AlbumScreenState.loading());

  Future<void> updateLike({required bool liked, required int index}) async {
    if (state.album == null) {
      return;
    }

    // Emit expected state after (un)liking.
    final oldphoto = state.album!.photos[index];
    AlbumPhoto newphoto = oldphoto.copyWith(
      liked: liked,
      numLikes: oldphoto.numLikes + (liked ? 1 : -1),
    );
    List<AlbumPhoto> newphotos = [...state.album!.photos];
    newphotos[index] = newphoto;
    emit(AlbumScreenState.result(
      album: state.album!.copyWith(photos: newphotos),
      isOpen: state.isOpen,
      initialGalleryIndex: state.initialGalleryIndex,
    ));

    try {
      await api.updateLiked(newphoto.pk, liked);
    } on ApiException {
      // Revert to state before (un)liking.
      emit(state);
      rethrow;
    }
  }

  void openGallery(int index) {
    if (state.album == null) return;
    emit(state.copyWith(isOpen: true, initialGalleryIndex: index));
  }

  void closeGallery() {
    emit(state.copyWith(isOpen: false));
  }

  Future<void> load(String slug) async {
    emit(state.copyWith(isLoading: true));
    try {
      final album = await api.getAlbum(slug: slug);
      emit(AlbumScreenState.result(album: album, isOpen: false));
    } on ApiException catch (exception) {
      emit(AlbumScreenState.failure(
        message: exception.getMessage(notFound: 'The album does not exist.'),
      ));
    }
  }
}
