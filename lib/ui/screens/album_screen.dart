import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
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
    with SingleTickerProviderStateMixin {
  late final AlbumCubit _albumCubit;
  bool clicked = false;
  int clickedI = 0;
  int current = 0;
  late AnimationController controller;
  late Animation<double> animation;
  PageController pageController = PageController(initialPage: 0);
  PageController pageController2 = PageController(initialPage: 0);

  void _onMainScroll() {
    print("onscroll${pageController.offset}");
    pageController2.animateTo(pageController.offset,
        duration: Duration(milliseconds: 0), curve: Curves.decelerate);
  }

  @override
  void initState() {
    _albumCubit = AlbumCubit(
      RepositoryProvider.of<ApiRepository>(context),
    )..load(widget.slug);
    pageController.addListener(_onMainScroll);
    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

    animation = CurvedAnimation(parent: controller, curve: Curves.elasticOut)
      ..addListener(() {
        if (controller.value >= 0.8) {
          controller.reset();
        }
      });
    super.initState();
  }

  @override
  void dispose() {
    _albumCubit.close();
    super.dispose();
  }

  Widget _makePhotoCard(Album album, int index) {
    return GestureDetector(
      onTap: () => setState(() {
        clicked = true;
        clickedI = index;
      }),
      child: FadeInImage.assetNetwork(
        placeholder: 'assets/img/photo_placeholder.png',
        image: album.photos[index].small,
        fit: BoxFit.cover,
      ),
    );
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
          List<Widget> widgets = [
            Scaffold(
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
            )
          ];
          if (clicked) {
            Album album = state.result!;
            int index = clickedI;
            pageController = PageController(initialPage: index);
            widgets.add(
              Scaffold(
                extendBodyBehindAppBar: true,
                backgroundColor: Colors.black.withOpacity(0.92),
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  leading: CloseButton(
                    color: Theme.of(context).primaryIconTheme.color,
                    onPressed: () => setState(() {
                      clicked = false;
                    }),
                  ),
                  actions: [
                    IconButton(
                      padding: const EdgeInsets.all(16),
                      color: Theme.of(context).primaryIconTheme.color,
                      icon: const Icon(Icons.download),
                      onPressed: () async => downloadImage(
                          context,
                          Uri.parse(album
                              .photos[max(
                                  0,
                                  min(pageController.page!.round(),
                                      album.photos.length))]
                              .full)),
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
                      },
                    ),
                  ],
                ),
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: PhotoViewGallery.builder(
                        onPageChanged: (index) {
                          pageController2.jumpToPage(index);
                        },
                        loadingBuilder: (_, __) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        backgroundDecoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        itemCount: album.photos.length,
                        builder: (context, i) {
                          return PhotoViewGalleryPageOptions.customChild(
                            onTapDown: (context, details, controllerValue) {
                              _albumCubit.updateLike(
                                  liked: !album.photos[i].liked, index: i);
                              controller.forward();
                            },
                            child: Image.network(album.photos[i].full),
                            minScale: PhotoViewComputedScale.contained * 0.8,
                            maxScale: PhotoViewComputedScale.covered * 2,
                          );
                        },
                        pageController: pageController,
                      ),
                    ),
                    PageCounter(pageController2),
                  ],
                ),
              ),
            );
            widgets.add(
              ScaleTransition(
                scale: animation,
                child: const Center(
                  child: CustomPaint(
                    size: Size(70, 80),
                    painter: HeartPainter(),
                  ),
                ),
              ),
            );
          }
          return Stack(
            alignment: AlignmentDirectional.center,
            children: widgets,
          );
        }
      },
    );
  }
}

class HeartPainter extends CustomPainter {
  @override
  const HeartPainter();

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint1 = Paint();
    paint1
      ..color = magenta
      ..style = PaintingStyle.fill;

    double width = size.width;
    double height = size.height;

    Path path = Path();
    path.moveTo(0.5 * width, height * 0.35);
    path.cubicTo(0.2 * width, height * 0.1, -0.25 * width, height * 0.6,
        0.5 * width, height);
    path.moveTo(0.5 * width, height * 0.35);
    path.cubicTo(0.8 * width, height * 0.1, 1.25 * width, height * 0.6,
        0.5 * width, height);

    canvas.drawPath(path, paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

// class GaleryImage extends StatefulWidget {
//   final String url;
//   const GaleryImage(this.url, {super.key});

//   @override
//   State<GaleryImage> createState() => _GaleryImageState();
// }

// class _GaleryImageState extends State<GaleryImage>
//     with SingleTickerProviderStateMixin {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       alignment: AlignmentDirectional.center,
//       children: [
//         Image.network(widget.url),
//         Opacity(
//           opacity: animation.value / 300,
//           child: const Center(
//             child: CustomPaint(
//               size: Size(70, 80),
//               painter: HeartPainter(),
//             ),
//           ),
//         )
//       ],
//     );
//   }

//   @override
//   void dispose() {
//     controller.dispose();

//     super.dispose();
//   }
// }

class PageCounter extends StatefulWidget {
  final PageController controler;
  const PageCounter(this.controler, {super.key});

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
    _position =
        widget.controler.createScrollPosition(ScrollPhysics(), this, null);
    _position?.applyViewportDimension(1.0);
    _position?.applyContentDimensions(0, 10);
    widget.controler.attach(_position!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text('hello $count!!');
  }

  @override
  void dispose() {
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
