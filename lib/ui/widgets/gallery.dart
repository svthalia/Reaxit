import 'package:flutter/material.dart';
import 'package:reaxit/models/photo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/ui/theme.dart';

abstract class GalleryCubit<T> extends StateStreamableSource<T> {
  Future<void> updateLike({required bool liked, required int index});
  Future<void> more();
}

class Gallery<C extends GalleryCubit> extends StatefulWidget {
  final List<AlbumPhoto> photos;
  final int initialPage;
  final int photoAmount;

  const Gallery(
      {required this.photos,
      required this.initialPage,
      required this.photoAmount});

  @override
  State<Gallery> createState() => _GalleryState<C>();
}

class _GalleryState<C extends GalleryCubit> extends State<Gallery>
    with TickerProviderStateMixin {
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
    )..addStatusListener((status) =>
        status == AnimationStatus.completed ? likeController.reset() : null);

    unlikeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
      upperBound: 0.8,
    )..addStatusListener((status) =>
        status == AnimationStatus.completed ? unlikeController.reset() : null);

    unlikeAnimation = CurvedAnimation(
      parent: unlikeController,
      curve: Curves.elasticOut,
    );
    likeAnimation = CurvedAnimation(
      parent: likeController,
      curve: Curves.elasticOut,
    );
  }

  Future<void> _loadMorePhotos() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await BlocProvider.of<C>(context).more();
    } on ApiException {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Something went wrong while loading the photos.'),
        ),
      );
    }
  }

  Widget _gallery(List<AlbumPhoto> photos) {
    return PhotoViewGallery.builder(
      backgroundDecoration: const BoxDecoration(color: Colors.transparent),
      pageController: controller,
      itemCount: widget.photoAmount,
      loadingBuilder: (_, __) => const Center(
        child: CircularProgressIndicator(),
      ),
      builder: (context, i) {
        final Widget child;

        if (i < photos.length) {
          child = GestureDetector(
            child: RotatedBox(
              quarterTurns: photos[i].rotation ~/ 90,
              child: Image.network(photos[i].full),
            ),
          );
        } else {
          child = const Center(
            child: CircularProgressIndicator(),
          );
        }

        return PhotoViewGalleryPageOptions.customChild(
          child: child,
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: PhotoViewComputedScale.covered * 2,
        );
      },
    );
  }

  Widget _downloadButton(List<AlbumPhoto> photos) {
    return const Icon(Icons.download);
  }

  Widget _shareButton(List<AlbumPhoto> photos) {
    return Icon(Icons.adaptive.share);
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
                widget.photoAmount,
                _loadMorePhotos,
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
        HeartPopup(animation: unlikeAnimation, color: Colors.white),
        HeartPopup(animation: likeAnimation, color: magenta)
      ],
    );
  }
}

class HeartPopup extends StatelessWidget {
  const HeartPopup({
    super.key,
    required this.animation,
    required this.color,
  });

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
  final int photoAmount;
  final void Function() loadMorePhotos;

  const _PageCounter(
    this.controller,
    this.initialPage,
    this.photos,
    this.photoAmount,
    this.loadMorePhotos,
  );

  @override
  State<_PageCounter> createState() => __PageCounterState();
}

class __PageCounterState extends State<_PageCounter> {
  late int currentIndex;

  void onPageChange() {
    final newIndex = widget.controller.page!.round();

    if (newIndex == widget.photos.length - 1) {
      widget.loadMorePhotos();
    }

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

    List<Widget> children = [
      Text(
        '${currentIndex + 1} / ${widget.photoAmount}',
        style: textTheme.bodyLarge?.copyWith(fontSize: 24, color: Colors.white),
      ),
    ];

    if (currentIndex < widget.photos.length) {
      final photo = widget.photos[currentIndex];

      children.addAll([
        Tooltip(
          message: photo.liked ? 'unlike photo' : 'like photo',
          child: Icon(
            color: photo.liked ? magenta : Colors.white,
            photo.liked ? Icons.favorite : Icons.favorite_outline,
          ),
        ),
        Text(
          '${photo.numLikes}',
          style: textTheme.bodyLarge?.copyWith(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ]);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}
