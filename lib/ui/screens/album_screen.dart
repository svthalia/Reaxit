import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
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
  late final AlbumCubit _cubit;

  String get title => widget.album?.title ?? 'ALBUM';

  @override
  void initState() {
    super.initState();
    _cubit = AlbumCubit(RepositoryProvider.of<ApiRepository>(context))
      ..load(widget.slug);
  }

  Future<void> _shareAlbum(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await Share.share(
        'https://${config.apiHost}/members/photos/${widget.slug}/',
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Could not share the album.'),
        ),
      );
    }
  }

  Widget _shareAlbumButton(BuildContext context) => IconButton(
        padding: const EdgeInsets.all(16),
        color: Theme.of(context).primaryIconTheme.color,
        icon: Icon(Icons.adaptive.share),
        onPressed: () => _shareAlbum(context),
      );

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<AlbumCubit, AlbumState>(
        builder: (context, state) {
          late final Widget body;
          if (state is ResultState) {
            body = _PhotoGrid(state.result!.photos);
          } else if (state is ErrorState) {
            body = ErrorScrollView(state.message!);
          } else {
            body = const Center(child: CircularProgressIndicator());
          }

          return Scaffold(
            appBar: ThaliaAppBar(
              title: Text(state.result?.title.toUpperCase() ?? title),
              actions: [_shareAlbumButton(context)],
            ),
            body: body,
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

  late final AnimationController likeController;
  late final AnimationController unlikeController;
  late final Animation<double> likeAnimation;
  late final Animation<double> unlikeAnimation;

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: widget.initialPage);

    likeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
      upperBound: 0.8,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) likeController.reset();
      });
    unlikeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
      upperBound: 0.8,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) unlikeController.reset();
      });

    unlikeAnimation = CurvedAnimation(
      parent: unlikeController,
      curve: Curves.elasticOut,
    );
    likeAnimation = CurvedAnimation(
      parent: likeController,
      curve: Curves.elasticOut,
    );
  }

  Future<void> _downloadImage(Uri url) async {
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

  Future<void> _shareImage(Uri url) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final response = await http.get(url);
      if (response.statusCode != 200) throw Exception();
      final file = XFile.fromData(
        response.bodyBytes,
        mimeType: lookupMimeType(url.path, headerBytes: response.bodyBytes),
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

  Future<void> _likePhoto(List<AlbumPhoto> photos, int index) async {
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
        pageController: controller,
        itemCount: photos.length,
        loadingBuilder: (_, __) => const Center(
          child: CircularProgressIndicator(),
        ),
        builder: (context, i) {
          return PhotoViewGalleryPageOptions.customChild(
            child: GestureDetector(
              onDoubleTap: () => _likePhoto(photos, i),
              child: Image.network(photos[i].full),
            ),
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
      );

  Widget _downloadButton(List<AlbumPhoto> photos) {
    return IconButton(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryIconTheme.color,
      icon: const Icon(Icons.download),
      onPressed: () => _downloadImage(
        Uri.parse(photos[controller.page!.round()].full),
      ),
    );
  }

  Widget _shareButton(List<AlbumPhoto> photos) {
    return IconButton(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryIconTheme.color,
      icon: Icon(Icons.adaptive.share),
      onPressed: () => _shareImage(
        Uri.parse(photos[controller.page!.floor()].full),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget overlayScaffold = Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: CloseButton(
          color: Theme.of(context).primaryIconTheme.color,
          onPressed: () => Navigator.of(context).pop(),
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
              child: _PageCounter(
                controller,
                widget.initialPage,
                widget.album,
                _likePhoto,
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
        _HeartPopup(animation: unlikeAnimation, color: Colors.white),
        _HeartPopup(animation: likeAnimation, color: magenta)
      ],
    );
  }
}

class _HeartPopup extends StatelessWidget {
  const _HeartPopup({
    Key? key,
    required this.animation,
    required this.color,
  }) : super(key: key);

  final Animation<double> animation;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: animation,
      child: Center(
        child: Icon(
          Icons.favorite,
          size: 70,
          color: color,
          shadows: const [
            BoxShadow(
              color: Colors.black54,
              spreadRadius: 20,
              blurRadius: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  final List<AlbumPhoto> photos;

  const _PhotoGrid(this.photos);

  void _openGallery(BuildContext context, int index) {
    final cubit = BlocProvider.of<AlbumCubit>(context);
    showDialog(
      context: context,
      useSafeArea: false,
      barrierColor: Colors.black.withOpacity(0.92),
      builder: (context) {
        return BlocProvider.value(
          value: cubit,
          child: BlocBuilder<AlbumCubit, AlbumState>(
            buildWhen: (previous, current) => current is ResultState,
            builder: (context, state) {
              return _Gallery(
                // TODO: buildWhen actually does not guarantee not building without result.
                album: state.result!,
                initialPage: index,
              );
            },
          ),
        );
      },
    );
  }

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
          openGallery: () => _openGallery(context, index),
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

class _PageCounter extends StatefulWidget {
  final PageController controller;
  final int initialPage;
  final Album album;
  final void Function(List<AlbumPhoto> photos, int index) likePhoto;

  const _PageCounter(
    this.controller,
    this.initialPage,
    this.album,
    this.likePhoto,
  );

  @override
  State<_PageCounter> createState() => __PageCounterState();
}

class __PageCounterState extends State<_PageCounter> {
  late int currentIndex;

  void onPageChange() {
    final newIndex = widget.controller.page!.round();
    if (newIndex != currentIndex) {
      setState(() => currentIndex = newIndex);
    }
  }

  @override
  void initState() {
    currentIndex = widget.initialPage;
    widget.controller.addListener(onPageChange);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(onPageChange);
    super.dispose();
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
            onPressed: () => widget.likePhoto(
              widget.album.photos,
              currentIndex,
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
