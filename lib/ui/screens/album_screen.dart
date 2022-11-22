import 'dart:io';
import 'dart:ui';

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

/// Screen that loads and shows a the Album of the member with `slug`.
class AlbumScreen extends StatefulWidget {
  final String slug;
  final ListAlbum? album;

  AlbumScreen({required this.slug, this.album}) : super(key: ValueKey(slug));

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen>
    with TickerProviderStateMixin {
  late final AlbumCubit _albumCubit;
  bool galleryShown = false;
  int initialGalleryIndex = 0;

  late AnimationController filledController;
  late Animation<double> filledAnimation;

  late AnimationController controller;
  late Animation<double> animation;

  /// The controller used in the image gallery.
  PageController mainPageController = PageController(initialPage: 0);
  /// Made to follow the `mainPageController`, and used
  /// to update the page count at the bottom of the page.
  PageController pageCountController = PageController(initialPage: 0);

  /// This should be called when scrolling on `mainPageController` to update
  /// the `pageCountController`.
  void _onGalleryScroll() {
    pageCountController.animateTo(mainPageController.offset,
        duration: const Duration(milliseconds: 0), curve: Curves.decelerate);
  }

  @override
  void initState() {
    _albumCubit = AlbumCubit(
      RepositoryProvider.of<ApiRepository>(context),
    )..load(widget.slug);
    mainPageController.addListener(_onGalleryScroll);
    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    filledController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

    animation = CurvedAnimation(parent: controller, curve: Curves.elasticOut)
      ..addListener(() {
        if (controller.value >= 0.8) {
          controller.reset();
        }
      });
    filledAnimation =
        CurvedAnimation(parent: filledController, curve: Curves.elasticOut)
          ..addListener(() {
            if (filledController.value >= 0.8) {
              filledController.reset();
            }
          });
    super.initState();
  }

  @override
  void dispose() {
    _albumCubit.close();
    super.dispose();
  }

  void openGallery(int index) {
    setState(() {
      galleryShown = true;
      initialGalleryIndex = index;
    });
  }

  void closeGallery() {
    setState(() {
      galleryShown = false;
    });
  }

  Future<void> likePhoto(
    BuildContext context,
    int likedIndex,
    List<AlbumPhoto> photos,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    if (photos[likedIndex].liked) {
      controller.forward();
    } else {
      filledController.forward();
    }
    try {
      await _albumCubit.updateLike(
        liked: !photos[likedIndex].liked,
        index: likedIndex,
      );
    } on ApiException {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Something went wrong while liking the photo.'),
        ),
      );
    }
  }

  Future<void> downloadImage(BuildContext context, Uri url) async {
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

  Future<void> _shareAlbum(BuildContext context, String slug) async {
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

  Widget _makeShareAlbumButton(BuildContext context, String slug) => IconButton(
        padding: const EdgeInsets.all(16),
        color: Theme.of(context).primaryIconTheme.color,
        icon: Icon(
          Theme.of(context).platform == TargetPlatform.iOS
              ? Icons.ios_share
              : Icons.share,
        ),
        onPressed: () => _shareAlbum(context, slug),
      );

  Widget _makePhotoCard(List<AlbumPhoto> photos, int index) => GestureDetector(
        onTap: () => openGallery(index),
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/img/photo_placeholder.png',
          image: photos[index].small,
          fit: BoxFit.cover,
        ),
      );

  Widget _gallery(List<AlbumPhoto> photos) => PhotoViewGallery.builder(
        onPageChanged: (index) {
          pageCountController.jumpToPage(index);
        },
        loadingBuilder: (_, __) => const Center(
          child: CircularProgressIndicator(),
        ),
        backgroundDecoration: const BoxDecoration(
          color: Colors.transparent,
        ),
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
        pageController: mainPageController,
      );

  Widget _downloadButton(List<AlbumPhoto> photos) => IconButton(
        padding: const EdgeInsets.all(16),
        color: Theme.of(context).primaryIconTheme.color,
        icon: const Icon(Icons.download),
        onPressed: () async => downloadImage(
            context, Uri.parse(photos[pageCountController.page!.round()].full)),
      );

  Widget _shareButton(List<AlbumPhoto> photos) => IconButton(
        padding: const EdgeInsets.all(16),
        color: Theme.of(context).primaryIconTheme.color,
        icon: Icon(
          Theme.of(context).platform == TargetPlatform.iOS
              ? Icons.ios_share
              : Icons.share,
        ),
        onPressed: () async => _shareImage(
            context, Uri.parse(photos[pageCountController.page!.floor()].full)),
      );

  List<Widget> _heartPopup() => [
        //TODO: add background/shadow around this to contrast white background
        ScaleTransition(
          scale: animation,
          child: const Center(
            child: Icon(Icons.favorite, size: 70),
          ),
        ),
        ScaleTransition(
          scale: filledAnimation,
          child: const Center(
            child: Icon(Icons.favorite, size: 70, color: magenta),
          ),
        ),
      ];

  Widget _smallGallery(List<AlbumPhoto> photos) => Scrollbar(
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
        itemBuilder: (context, index) => _makePhotoCard(
          photos,
          index,
        ),
      ));

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlbumCubit, AlbumState>(
      bloc: _albumCubit,
      //TODO: maybe make this a different function?
      builder: (context, state) {
        Widget mainScaffold = Scaffold(
            appBar: ThaliaAppBar(
              title: Text(state.result?.title.toUpperCase() ??
                  widget.album?.title.toUpperCase() ??
                  'ALBUM'),
              actions: [_makeShareAlbumButton(context, widget.slug)],
            ),
            body: state.hasException
                ? ErrorScrollView(state.message!)
                : state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _smallGallery(state.result!.photos));

        if (galleryShown && !state.hasException && !state.isLoading) {
          Album album = state.result!;
          List<bool> likedlist = album.photos.map((e) => e.liked).toList();
          List<int> likeslist = album.photos.map((e) => e.numLikes).toList();

          // We change the pagecontroler with a new initialPage because
          // it is impossible to change the initial page after it has been created.
          // We cannot jump to the page because it is not attached jet. When it opens
          // the gallery it will use the initialPage instead of last jumped-to page.
          mainPageController = PageController(initialPage: initialGalleryIndex);

          Widget overlayScaffold = Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.black.withOpacity(0.92),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              leading: CloseButton(
                color: Theme.of(context).primaryIconTheme.color,
                onPressed: closeGallery,
              ),
              actions: [
                _downloadButton(album.photos),
                _shareButton(album.photos),
              ],
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: _gallery(album.photos),
                ),
                PageCounter(
                  controler: pageCountController,
                  pagecount: album.photos.length,
                  isliked: likedlist,
                  likeToggle: (likedIndex) =>
                      likePhoto(context, likedIndex, album.photos),
                  likecount: likeslist,
                ),
              ],
            ),
          );

          return Stack(
            alignment: AlignmentDirectional.center,
            children: [
              mainScaffold,
              overlayScaffold,
              ..._heartPopup(),
            ],
          );
        } else if (galleryShown) {
          galleryShown = false;
        }
        return mainScaffold;
      },
    );
  }
}

class PageCounter extends StatefulWidget {
  final PageController controler;
  final int pagecount;
  final List<bool> isliked;
  final List<int> likecount;
  final void Function(int) likeToggle;

  const PageCounter(
      {required this.controler,
      required this.pagecount,
      required this.isliked,
      required this.likeToggle,
      required this.likecount,
      super.key});

  @override
  State<PageCounter> createState() => _PageCounterState();
}

class _PageCounterState extends State<PageCounter>
    with SingleTickerProviderStateMixin
    implements ScrollContext {
  int currentIndex = 0;
  ScrollPosition? _position;

  @override
  void initState() {
    _position = widget.controler
        .createScrollPosition(const ScrollPhysics(), this, null);
    _position?.applyViewportDimension(1.0);
    _position?.applyContentDimensions(0, widget.pagecount.toDouble());
    widget.controler.attach(_position!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$currentIndex / ${widget.pagecount}',
          style: textTheme.bodyText1?.copyWith(fontSize: 24),
        ),
        Tooltip(
          message: 'like photo',
          child: IconButton(
            iconSize: 24,
            icon: Icon(
              size: 24.0,
              color: widget.isliked[currentIndex] ? magenta : Colors.white,
              widget.isliked[currentIndex]
                  ? Icons.favorite
                  : Icons.favorite_outline,
            ),
            onPressed: () => widget.likeToggle(currentIndex),
          ),
        ),
        Text(
          '${widget.likecount[currentIndex]}',
          style: textTheme.bodyText1?.copyWith(fontSize: 24),
        ),
      ],
    );
  }

  @override
  void dispose() {
    widget.controler.detach(_position!);
    super.dispose();
  }

  @override
  AxisDirection get axisDirection => AxisDirection.right;

  @override
  BuildContext? get notificationContext => context;

  @override
  void saveOffset(double offset) {
    setState(() {
      currentIndex = offset.toInt();
    });
  }

  @override
  void setCanDrag(bool value) {}

  @override
  void setIgnorePointer(bool value) {}

  @override
  void setSemanticsActions(Set<SemanticsAction> actions) {}

  @override
  BuildContext get storageContext => context;

  @override
  TickerProvider get vsync => this;
}
