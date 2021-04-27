import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:reaxit/blocs/album_cubit.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models/album.dart';
import 'package:reaxit/ui/widgets/app_bar.dart';
import 'package:reaxit/ui/widgets/error_scroll_view.dart';

/// Screen that loads and shows a the Album of the member with `pk`.
class AlbumScreen extends StatefulWidget {
  final int pk;
  final ListAlbum? album;

  AlbumScreen({required this.pk, this.album}) : super(key: ValueKey(pk));

  @override
  _AlbumScreenState createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  late final AlbumCubit _albumCubit;

  @override
  void initState() {
    _albumCubit = AlbumCubit(
      RepositoryProvider.of<ApiRepository>(context),
    )..load(widget.pk);
    super.initState();
  }

  Widget _makePhotoCard(Album album, int index) {
    return GestureDetector(
      onTap: () => _showPhotoGallery(album, index),
      child: Hero(
        tag: 'photo_${album.photos[index].pk}',
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/img/default-avatar.jpg',
          image: album.photos[index].small,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void _showPhotoGallery(Album album, int index) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) {
        return Scaffold(
          body: Stack(
            children: [
              PhotoViewGallery.builder(
                itemCount: album.photos.length,
                builder: (context, i) => PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(album.photos[i].full),
                  tightMode: false,
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 2,
                ),
                pageController: PageController(initialPage: index),
              ),
              // TODO: share button
              CloseButton(
                color: Theme.of(context).primaryIconTheme.color,
              ),
            ],
          ),
          backgroundColor: Colors.transparent,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlbumCubit, DetailState<Album>>(
      bloc: _albumCubit,
      builder: (context, state) {
        if (state.hasException) {
          return Scaffold(
            appBar: ThaliaAppBar(
              title: Text(widget.album?.title ?? 'Album'),
            ),
            body: ErrorScrollView(state.message!),
          );
        } else if (state.isLoading) {
          return Scaffold(
            appBar: ThaliaAppBar(
              title: Text(widget.album?.title ?? 'Album'),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          return Scaffold(
            appBar: ThaliaAppBar(title: Text(state.result!.title)),
            body: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                crossAxisCount: 3,
              ),
              itemCount: state.result!.photos.length,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(5),
              itemBuilder: (context, index) => _makePhotoCard(
                state.result!,
                index,
              ),
            ),
          );
        }
      },
    );
  }
}
