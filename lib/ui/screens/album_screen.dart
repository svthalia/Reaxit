import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:reaxit/blocs/album_cubit.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models/album.dart';
import 'package:reaxit/ui/widgets/error_scroll_view.dart';
import 'package:reaxit/config.dart' as config;
import 'package:share/share.dart';

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
      barrierColor: Colors.black.withOpacity(0.92),
      builder: (context) {
        final pageController = PageController(initialPage: index);
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              PhotoViewGallery.builder(
                backgroundDecoration: BoxDecoration(color: Colors.transparent),
                itemCount: album.photos.length,
                builder: (context, i) => PhotoViewGalleryPageOptions(
                  heroAttributes: PhotoViewHeroAttributes(
                    tag: 'photo_${album.photos[i].pk}',
                  ),
                  imageProvider: NetworkImage(album.photos[i].full),
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 2,
                ),
                pageController: pageController,
              ),
              SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CloseButton(
                      color: Theme.of(context).primaryIconTheme.color,
                    ),
                    IconButton(
                      color: Theme.of(context).primaryIconTheme.color,
                      icon: Icon(
                        Platform.isIOS ? Icons.ios_share : Icons.share,
                      ),
                      onPressed: () async {
                        var i = pageController.page!.round();
                        if (i < 0 || i >= album.photos.length) i = index;
                        final url = Uri.parse(album.photos[i].full);
                        try {
                          final response = await http.get(url);
                          if (response.statusCode != 200) throw Exception();
                          final baseTempDir = await getTemporaryDirectory();
                          final tempDir = await baseTempDir.createTemp();
                          final tempFile = File(
                            '${tempDir.path}/${url.pathSegments.last}',
                          );
                          await tempFile.writeAsBytes(response.bodyBytes);
                          await Share.shareFiles([tempFile.path]);
                        } catch (_) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            duration: Duration(seconds: 1),
                            content: Text('Could not share the image.'),
                          ));
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _makeShareAlbumButton(int pk) {
    return IconButton(
      color: Theme.of(context).primaryIconTheme.color,
      icon: Icon(
        Platform.isIOS ? Icons.ios_share : Icons.share,
      ),
      onPressed: () async {
        try {
          // TODO: The api currently uses only the pk, and the website only a
          //  slug. Concrexit issue #1626 should be closed before adding this,
          //  and at that point the slug route should also be accepted as a
          //  deeplink. All album pk's should be replaced with slugs.
          await Share.share('https://${config.apiHost}/members/photos/$pk/');
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: Duration(seconds: 1),
            content: Text('Could not share the album.'),
          ));
        }
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
            appBar: AppBar(
              title: Text(widget.album?.title ?? 'Album'),
              actions: [_makeShareAlbumButton(widget.pk)],
            ),
            body: ErrorScrollView(state.message!),
          );
        } else if (state.isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.album?.title ?? 'Album'),
              actions: [_makeShareAlbumButton(widget.pk)],
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text(state.result!.title),
              actions: [_makeShareAlbumButton(widget.pk)],
            ),
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
