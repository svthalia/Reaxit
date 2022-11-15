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

  PageController pageController = PageController(initialPage: 0);
  PageController pageController2 = PageController(initialPage: 0);

  void _onMainScroll() {
    pageController2.animateTo(pageController.offset,
        duration: const Duration(milliseconds: 0), curve: Curves.decelerate);
  }

  @override
  void initState() {
    _albumCubit = AlbumCubit(
      RepositoryProvider.of<ApiRepository>(context),
    )..load(widget.slug);
    pageController.addListener(_onMainScroll);
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

  void downloadImage(BuildContext context, Uri url) async {
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

  void _share(BuildContext context, Uri url) async {
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

  Widget _makeShareAlbumButton(String slug) => IconButton(
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
            await Share.share(
                'https://${config.apiHost}/members/photos/$slug/');
          } catch (_) {
            messenger.showSnackBar(const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Could not share the album.'),
            ));
          }
        },
      );

  Widget _makePhotoCard(List<AlbumPhoto> photos, int index) => GestureDetector(
        onTap: () => setState(() {
          galleryShown = true;
          initialGalleryIndex = index;
        }),
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/img/photo_placeholder.png',
          image: photos[index].small,
          fit: BoxFit.cover,
        ),
      );

  Widget _gallery(List<AlbumPhoto> photos) => PhotoViewGallery.builder(
        onPageChanged: (index) {
          pageController2.jumpToPage(index);
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
                child: Image.network(photos[i].full)),
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        pageController: pageController,
      );

  Widget _downloadButton(List<AlbumPhoto> photos) => IconButton(
        padding: const EdgeInsets.all(16),
        color: Theme.of(context).primaryIconTheme.color,
        icon: const Icon(Icons.download),
        onPressed: () async => downloadImage(
            context, Uri.parse(photos[pageController2.page!.round()].full)),
      );

  Widget _shareButton(List<AlbumPhoto> photos) => IconButton(
        padding: const EdgeInsets.all(16),
        color: Theme.of(context).primaryIconTheme.color,
        icon: Icon(
          Theme.of(context).platform == TargetPlatform.iOS
              ? Icons.ios_share
              : Icons.share,
        ),
        onPressed: () async => _share(
            context, Uri.parse(photos[pageController2.page!.floor()].full)),
      );

  List<Widget> _heartPopup() => [
        ScaleTransition(
          scale: animation,
          child: const Center(
            child: CustomPaint(
              size: Size(70, 80),
              painter: HeartPainter(),
            ),
          ),
        ),
        ScaleTransition(
          scale: filledAnimation,
          child: const Center(
            child: CustomPaint(
              size: Size(70, 80),
              painter: HeartPainter(
                filled: true,
                color: magenta,
              ),
            ),
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
      builder: (context, state) {
        Widget mainScaffold = Scaffold(
            appBar: ThaliaAppBar(
              title: Text(widget.album?.title.toUpperCase() ?? 'ALBUM'),
              actions: [_makeShareAlbumButton(widget.slug)],
            ),
            body: state.hasException
                ? ErrorScrollView(state.message!)
                : state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _smallGallery(state.result!.photos));

        if (galleryShown && !state.hasException && !state.isLoading) {
          Album album = state.result!;
          //TODO: This is double work, probably not an issue but might be slow if we have a lot f photos and we need to rebuild
          // Slow meaning a couple MS which is too long for a build. Maybe we should cache this in the album?
          List<bool> likedlist = album.photos.map((e) => e.liked).toList();
          List<int> likeslist = album.photos.map((e) => e.numLikes).toList();

          // We change the pagecontroler with a new initialPage because
          // it is impossible to change the initial page after it has been created.
          // We cannot jump to the page because it is not attached jet. When it opens
          // the gallery it will use the initialPage instead of last jumped-to page.
          pageController = PageController(initialPage: initialGalleryIndex);

          Widget overlayScaffold = Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.black.withOpacity(0.92),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              leading: CloseButton(
                color: Theme.of(context).primaryIconTheme.color,
                onPressed: () => setState(() {
                  galleryShown = false;
                }),
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
                  controler: pageController2,
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
          // TODO: Maybe a loading screen here? but I dont really see how this situation could ever happen
          galleryShown = false;
        }
        return mainScaffold;
      },
    );
  }
}

class HeartPainter extends CustomPainter {
  final bool filled;
  final double strokeWidth;
  final Color color;

  @override
  const HeartPainter(
      {this.filled = false, this.strokeWidth = 6, this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    double width = size.width;
    double height = size.height;
    Path path = Path();
    path.moveTo(0.5 * width, height * 0.25);
    path.cubicTo(0.2 * width, height * 0, -0.25 * width, height * 0.5,
        0.5 * width, height * 0.9);
    path.moveTo(0.5 * width, height * 0.25);
    path.cubicTo(0.8 * width, height * 0, 1.25 * width, height * 0.5,
        0.5 * width, height * 0.9);

    if (filled) {
      Paint paint1 = Paint();
      paint1
        ..color = color
        ..style = PaintingStyle.fill
        ..strokeWidth = 0;
      canvas.drawPath(path, paint1);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
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
  int count = 0;
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
          '$count / ${widget.pagecount}',
          style: textTheme.bodyText1?.copyWith(fontSize: 24),
        ),
        Tooltip(
          message: 'like photo',
          child: IconButton(
            iconSize: 24,
            icon: CustomPaint(
                size: const Size.square(24.0),
                painter: widget.isliked[count]
                    ? const HeartPainter(
                        filled: true, strokeWidth: 2, color: magenta)
                    : const HeartPainter(strokeWidth: 2)),
            onPressed: () => widget.likeToggle(count),
          ),
        ),
        Text(
          '${widget.likecount[count]}',
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
      count = offset.toInt();
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
