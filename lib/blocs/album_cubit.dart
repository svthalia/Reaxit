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
  final List<bool>? likedList;
  final List<int>? likesList;
  final bool isOpen;

  final String? message;
  final bool isLoading;
  bool get hasException => message != null;

  @protected
  AlbumScreenState(
      {required this.album,
      required this.isLoading,
      required this.message,
      this.isOpen = false})
      : assert(
          album != null || isLoading || message != null,
          'event can only be null when isLoading or hasException is true.',
        ),
        likedList = album?.photos.map((e) => e.liked).toList(),
        likesList = album?.photos.map((e) => e.numLikes).toList();

  @override
  List<Object?> get props => [album, message, isLoading];

  AlbumScreenState copyWith({
    Album? album,
    List<AdminEventRegistration>? registrations,
    bool? isLoading,
    String? message,
    bool? isOpen,
  }) =>
      AlbumScreenState(
        album: album ?? this.album,
        isLoading: isLoading ?? this.isLoading,
        message: message ?? this.message,
        isOpen: isOpen ?? this.isOpen,
      );

  const AlbumScreenState.result({required this.album, required this.isOpen})
      : message = null,
        isLoading = false,
        likedList = null,
        likesList = null;

  const AlbumScreenState.loading({this.album})
      : message = null,
        isLoading = true,
        likedList = null,
        likesList = null,
        isOpen = false;

  const AlbumScreenState.failure({required String this.message, this.album})
      : isLoading = false,
        likedList = null,
        likesList = null,
        isOpen = false;
}

class AlbumCubit extends Cubit<AlbumScreenState> {
  final ApiRepository api;

  AlbumCubit(this.api) : super(const AlbumScreenState.loading());

  Future<void> updateLike({required bool liked, required int index}) async {
    if (state.album == null) {
      return;
    }
    final oldphoto = state.album!.photos[index];
    AlbumPhoto newphoto = oldphoto.copyWith(
      liked: liked,
      numLikes: oldphoto.numLikes + (liked ? 1 : -1),
    );
    List<AlbumPhoto> newphotos = [...state.album!.photos];
    newphotos[index] = newphoto;
    emit(
      AlbumScreenState.result(
          album: state.album!.copyWith(photos: newphotos),
          isOpen: state.isOpen),
    );
    try {
      await api.updateLiked(newphoto.pk, liked);
    } on ApiException {
      emit(state);
      rethrow;
    }
  }

  void openScrollingGallery() {
    emit(state.copyWith(isOpen: true));
  }

  void closeScrollingGallery() {
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
