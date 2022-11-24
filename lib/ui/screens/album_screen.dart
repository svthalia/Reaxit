import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/ui/theme.dart';
import 'package:reaxit/ui/widgets.dart';
import 'package:reaxit/config.dart' as config;
import 'package:share_plus/share_plus.dart';
import 'package:gallery_saver/gallery_saver.dart';

/// Screen that loads and shows the Album with `slug`.
class AlbumScreen extends StatefulWidget {
  final String slug;
  final ListAlbum? album;

  AlbumScreen({required this.slug, this.album}) : super(key: ValueKey(slug));

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AlbumCubit(
        RepositoryProvider.of<ApiRepository>(context),
      )..load(widget.slug),
      child: BlocBuilder<AlbumCubit, AlbumScreenState>(
        builder: (context, state) {
          late final Widget body;
          if (state.isLoading) {
            body = const Center(child: CircularProgressIndicator());
          } else if (state.hasException) {
            body = ErrorScrollView(state.message!);
          } else {
            body = _PhotoGrid(state.album!.photos);
          }

          Widget mainScaffold = Scaffold(
            appBar: ThaliaAppBar(
              title: Text(state.album?.title.toUpperCase() ??
                  widget.album?.title.toUpperCase() ??
                  'ALBUM'),
              actions: [_ShareAlbumButton(slug: widget.slug)],
            ),
            body: body,
          );

          return Stack(
            children: [
              mainScaffold,
              if (state.isOpen)
                _Gallery(
                    album: state.album!,
                    initialPage: state.initialGalleryIndex!),
            ],
          );
        },
      ),
    );
  }
}

class _Gallery extends StatefulWidget {
  final Album album;
  final int initialPage;

  const _Gallery({required this.album, required this.initialPage});

  @override
  State<_Gallery> createState() => __GalleryState();
}

class __GalleryState extends State<_Gallery> with TickerProviderStateMixin {
  late final PageController controller;

  late AnimationController likeController;
  late AnimationController unlikeController;
  late Animation<double> likeAnimation;
  late Animation<double> unlikeAnimation;

  @override
  void initState() {
    controller = PageController(initialPage: widget.initialPage);

    likeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    unlikeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    likeAnimation =
        CurvedAnimation(parent: likeController, curve: Curves.elasticOut)
          ..addListener(() {
            if (likeController.value >= 0.8) likeController.reset();
          });
    unlikeAnimation =
        CurvedAnimation(parent: unlikeController, curve: Curves.elasticOut)
          ..addListener(() {
            if (unlikeController.value >= 0.8) unlikeController.reset();
          });

    super.initState();
  }

  Future<void> _downloadImage(BuildContext context, Uri url) async {
    final messenger = ScaffoldMessenger.of(context);
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
  }

  Future<void> _shareImage(BuildContext context, Uri url) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final response = await http.get(url);
      if (response.statusCode != 200) throw Exception();
      final file = XFile.fromData(
        response.bodyBytes,
        name: url.pathSegments.last,
      );
      await Share.shareXFiles([file]);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Could not share the image.'),
        ),
      );
    }
  }

  Future<void> likePhoto(
    BuildContext context,
    int index,
    List<AlbumPhoto> photos,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    if (photos[index].liked) {
      unlikeController.forward();
    } else {
      likeController.forward();
    }
    try {
      await BlocProvider.of<AlbumCubit>(context).updateLike(
        liked: !photos[index].liked,
        index: index,
      );
    } on ApiException {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Something went wrong while liking the photo.'),
        ),
      );
    }
  }

  Widget _gallery(List<AlbumPhoto> photos) => PhotoViewGallery.builder(
        backgroundDecoration: const BoxDecoration(color: Colors.transparent),
        loadingBuilder: (_, __) => const Center(
          child: CircularProgressIndicator(),
        ),
        pageController: controller,
        itemCount: photos.length,
        builder: (context, i) {
          return PhotoViewGalleryPageOptions.customChild(
            child: GestureDetector(
              onDoubleTap: () => likePhoto(context, i, photos),
              child: Image.network(photos[i].full),
            ),
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
      );

  Widget _downloadButton(List<AlbumPhoto> photos) => IconButton(
        padding: const EdgeInsets.all(16),
        color: Theme.of(context).primaryIconTheme.color,
        icon: const Icon(Icons.download),
        onPressed: () => _downloadImage(
            context, Uri.parse(photos[controller.page!.round()].full)),
      );

  Widget _shareButton(List<AlbumPhoto> photos) => IconButton(
        padding: const EdgeInsets.all(16),
        color: Theme.of(context).primaryIconTheme.color,
        icon: Icon(Icons.adaptive.share),
        onPressed: () => _shareImage(
            context, Uri.parse(photos[controller.page!.floor()].full)),
      );

  List<Widget> _heartPopup() => [
        ScaleTransition(
          scale: unlikeAnimation,
          child: const Center(
            child: Icon(
              Icons.favorite,
              size: 70,
              color: Colors.white,
              shadows: [
                BoxShadow(
                  color: Colors.black54,
                  spreadRadius: 20,
                  blurRadius: 20,
                ),
              ],
            ),
          ),
        ),
        ScaleTransition(
          scale: likeAnimation,
          child: const Center(
            child: Icon(
              Icons.favorite,
              size: 70,
              color: magenta,
              shadows: [
                BoxShadow(
                  color: Colors.black54,
                  spreadRadius: 20,
                  blurRadius: 20,
                ),
              ],
            ),
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    Widget overlayScaffold = Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black.withOpacity(0.92),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: CloseButton(
          color: Theme.of(context).primaryIconTheme.color,
          onPressed: BlocProvider.of<AlbumCubit>(context).closeGallery,
        ),
        actions: [
          _downloadButton(widget.album.photos),
          _shareButton(widget.album.photos),
        ],
      ),
      body: Stack(
        children: [
          _gallery(widget.album.photos),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: PageCounter(
                controller,
                widget.initialPage,
                widget.album,
              ),
            ),
          ),
        ],
      ),
    );

    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        overlayScaffold,
        ..._heartPopup(),
      ],
    );
  }
}

class _ShareAlbumButton extends StatelessWidget {
  final String slug;

  const _ShareAlbumButton({required this.slug});

  Future<void> _shareAlbum(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await Share.share('https://${config.apiHost}/members/photos/$slug/');
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Could not share the album.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryIconTheme.color,
      icon: Icon(Icons.adaptive.share),
      onPressed: () => _shareAlbum(context),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  final List<AlbumPhoto> photos;

  const _PhotoGrid(this.photos);

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: GridView.builder(
        key: const PageStorageKey('album'),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          crossAxisCount: 3,
        ),
        itemCount: photos.length,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) => _PhotoTile(
          photo: photos[index],
          openGallery: () =>
              BlocProvider.of<AlbumCubit>(context).openGallery(index),
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final AlbumPhoto photo;
  final void Function() openGallery;

  _PhotoTile({
    required this.photo,
    required this.openGallery,
  }) : super(key: ValueKey(photo.pk));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: openGallery,
      child: FadeInImage.assetNetwork(
        placeholder: 'assets/img/photo_placeholder.png',
        image: photo.small,
        fit: BoxFit.cover,
      ),
    );
  }
}

class PageCounter extends StatefulWidget {
  final PageController controller;
  final int initialPage;
  final Album album;

  const PageCounter(this.controller, this.initialPage, this.album);

  @override
  State<PageCounter> createState() => _PageCounterState();
}

class _PageCounterState extends State<PageCounter> {
  late int currentIndex;

  @override
  void initState() {
    currentIndex = widget.initialPage;
    widget.controller.addListener(() {
      final newIndex = widget.controller.page!.round();
      if (newIndex != currentIndex) {
        setState(() => currentIndex = newIndex);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final photo = widget.album.photos[currentIndex];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${currentIndex + 1} / ${widget.album.photos.length}',
          style:
              textTheme.bodyText1?.copyWith(fontSize: 24, color: Colors.white),
        ),
        Tooltip(
          message: 'like photo',
          child: IconButton(
            iconSize: 24,
            icon: Icon(
              color: photo.liked ? magenta : Colors.white,
              photo.liked ? Icons.favorite : Icons.favorite_outline,
            ),
            onPressed: () => BlocProvider.of<AlbumCubit>(context).updateLike(
              liked: !photo.liked,
              index: currentIndex,
            ),
          ),
        ),
        Text(
          '${photo.numLikes}',
          style: textTheme.bodyText1?.copyWith(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
