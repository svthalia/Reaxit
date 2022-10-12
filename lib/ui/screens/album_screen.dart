import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:reaxit/blocs/album_cubit.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/models/album.dart';
import 'package:reaxit/ui/widgets/app_bar.dart';
import 'package:reaxit/ui/widgets/error_scroll_view.dart';
import 'package:reaxit/config.dart' as config;
import 'package:share_plus/share_plus.dart';
import 'package:gallery_saver/gallery_saver.dart';

/// Screen that loads and shows a the Album of the member with `slug`.
class AlbumScreen extends StatefulWidget {
  final String slug;
  final ListAlbum? album;

  AlbumScreen({required this.slug, this.album}) : super(key: ValueKey(slug));

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  late final AlbumCubit _albumCubit;

  @override
  void initState() {
    _albumCubit = AlbumCubit(
      RepositoryProvider.of<ApiRepository>(context),
    )..load(widget.slug);
    super.initState();
  }

  @override
  void dispose() {
    _albumCubit.close();
    super.dispose();
  }

  Widget _makePhotoCard(Album album, int index) {
    return GestureDetector(
      onTap: () => _showPhotoGallery(album, index),
      child: FadeInImage.assetNetwork(
        placeholder: 'assets/img/photo_placeholder.png',
        image: album.photos[index].small,
        fit: BoxFit.cover,
      ),
    );
  }

  void _showPhotoGallery(Album album, int index) {
    showDialog(
      context: context,
      useSafeArea: false,
      barrierColor: Colors.black.withOpacity(0.92),
      builder: (context) {
        final pageController = PageController(initialPage: index);
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            leading: CloseButton(
              color: Theme.of(context).primaryIconTheme.color,
            ),
            actions: [
              IconButton(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).primaryIconTheme.color,
                icon: const Icon(Icons.download),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);

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
                    await GallerySaver.saveImage(tempFile.path);

                    messenger.showSnackBar(
                      const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text('Succesfully saved the image.'),
                      ),
                    );
                  } catch (_) {
                    messenger.showSnackBar(
                      const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text('Could not download the image.'),
                      ),
                    );
                  }
                },
              ),
              IconButton(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).primaryIconTheme.color,
                icon: Icon(
                  Theme.of(context).platform == TargetPlatform.iOS
                      ? Icons.ios_share
                      : Icons.share,
                ),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);

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
                    messenger.showSnackBar(
                      const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text('Could not share the image.'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          body: SafeArea(
            child: PhotoViewGallery.builder(
              loadingBuilder: (_, __) => const Center(
                child: CircularProgressIndicator(),
              ),
              backgroundDecoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              itemCount: album.photos.length,
              builder: (context, i) => PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(album.photos[i].full),
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 2,
              ),
              pageController: pageController,
            ),
          ),
        );
      },
    );
  }

  Widget _makeShareAlbumButton(String slug) {
    return IconButton(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryIconTheme.color,
      icon: Icon(
        Theme.of(context).platform == TargetPlatform.iOS
            ? Icons.ios_share
            : Icons.share,
      ),
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);
        try {
          await Share.share('https://${config.apiHost}/members/photos/$slug/');
        } catch (_) {
          messenger.showSnackBar(const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Could not share the album.'),
          ));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlbumCubit, AlbumState>(
      bloc: _albumCubit,
      builder: (context, state) {
        if (state.hasException) {
          return Scaffold(
            appBar: ThaliaAppBar(
              title: Text(widget.album?.title.toUpperCase() ?? 'ALBUM'),
              actions: [_makeShareAlbumButton(widget.slug)],
            ),
            body: ErrorScrollView(state.message!),
          );
        } else if (state.isLoading) {
          return Scaffold(
            appBar: ThaliaAppBar(
              title: Text(widget.album?.title.toUpperCase() ?? 'ALBUM'),
              actions: [_makeShareAlbumButton(widget.slug)],
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else {
          return Scaffold(
            appBar: ThaliaAppBar(
              title: Text(state.result!.title.toUpperCase()),
              actions: [_makeShareAlbumButton(widget.slug)],
            ),
            body: Scrollbar(
              child: GridView.builder(
                key: const PageStorageKey('album'),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  crossAxisCount: 3,
                ),
                itemCount: state.result!.photos.length,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) => _makePhotoCard(
                  state.result!,
                  index,
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
