import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs/liked_photos_cubit.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/ui/theme.dart';
import 'package:reaxit/ui/widgets.dart';
import 'package:reaxit/ui/widgets/photo_tile.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gallery_saver/gallery_saver.dart';

class LikedPhotosScreen extends StatefulWidget {
  const LikedPhotosScreen();

  @override
  State<LikedPhotosScreen> createState() => _LikedPhotosScreenState();
}

class _LikedPhotosScreenState extends State<LikedPhotosScreen> {
  late ScrollController _controller;
  late final LikedPhotosCubit _cubit;

  @override
  void initState() {
    _controller = ScrollController()..addListener(_scrollListener);
    _cubit = LikedPhotosCubit(RepositoryProvider.of<ApiRepository>(context))
      ..load();
    super.initState();
  }

  void _scrollListener() {
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 300) {
      _cubit.more();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
        value: _cubit,
        child: Scaffold(
            appBar: ThaliaAppBar(
              title: const Text('LIKED PHOTOS'),
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                await _cubit.load();
              },
              child: BlocBuilder<LikedPhotosCubit, LikedPhotosState>(
                builder: (context, state) {
                  if (state.hasException) {
                    return ErrorScrollView(state.message!);
                  } else {
                    return _PhotoGridScrollView(
                      controller: _controller,
                      listState: state,
                    );
                  }
                },
              ),
            )));
  }
}

class _PhotoGridScrollView extends StatelessWidget {
  final ScrollController controller;
  final LikedPhotosState listState;

  const _PhotoGridScrollView({
    Key? key,
    required this.controller,
    required this.listState,
  }) : super(key: key);

  void _openGallery(BuildContext context, int index) {
    final cubit = BlocProvider.of<LikedPhotosCubit>(context);
    showDialog(
      context: context,
      useSafeArea: false,
      barrierColor: Colors.black.withOpacity(0.92),
      builder: (context) {
        return BlocProvider.value(
          value: cubit,
          child: BlocBuilder<LikedPhotosCubit, LikedPhotosState>(
            buildWhen: (previous, current) =>
                !current.isLoading && !current.isLoadingMore,
            builder: (context, state) {
              return _Gallery(
                photos: state.results,
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
      controller: controller,
      child: CustomScrollView(
        controller: controller,
        physics: const RangeMaintainingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => PhotoTile(
                  photo: listState.results[index],
                  openGallery: () => _openGallery(context, index),
                ),
                childCount: listState.results.length,
              ),
            ),
          ),
          if (listState.isLoadingMore)
            const SliverPadding(
              padding: EdgeInsets.all(8),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  Center(
                    child: CircularProgressIndicator(),
                  )
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

class _Gallery extends StatefulWidget {
  final List<AlbumPhoto> photos;
  final int initialPage;

  const _Gallery({required this.photos, required this.initialPage});

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
      await BlocProvider.of<LikedPhotosCubit>(context).updateLike(
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
          _downloadButton(widget.photos),
          _shareButton(widget.photos),
        ],
      ),
      body: Stack(
        children: [
          _gallery(widget.photos),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: _PageCounter(
                controller,
                widget.initialPage,
                widget.photos,
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

class _PageCounter extends StatefulWidget {
  final PageController controller;
  final int initialPage;
  final List<AlbumPhoto> photos;
  final void Function(List<AlbumPhoto> photos, int index) likePhoto;

  const _PageCounter(
      this.controller, this.initialPage, this.photos, this.likePhoto);

  @override
  State<_PageCounter> createState() => __PageCounterState();
}

class __PageCounterState extends State<_PageCounter> {
  late int currentIndex;
  // bool refresh = false;

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
    final photo = widget.photos[currentIndex];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${currentIndex + 1} / ${widget.photos.length}',
          style:
              textTheme.bodyLarge?.copyWith(fontSize: 24, color: Colors.white),
        ),
        Tooltip(
          message: photo.liked ? 'unlike photo' : 'like photo',
          child: IconButton(
            iconSize: 24,
            icon: Icon(
              color: photo.liked ? magenta : Colors.white,
              photo.liked ? Icons.favorite : Icons.favorite_outline,
            ),
            onPressed: () {
              widget.likePhoto(
                widget.photos,
                currentIndex,
              );
              // Force an update to refresh the like count and icon
              setState(() {});
            },
          ),
        ),
        Text(
          '${photo.numLikes}',
          style: textTheme.bodyLarge?.copyWith(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
