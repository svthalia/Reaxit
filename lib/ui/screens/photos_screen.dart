import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs/face_detection_cubit.dart';
import 'package:reaxit/ui/screens/albums_screen.dart';
import 'package:reaxit/ui/screens/face_detection_screen.dart';
import 'package:reaxit/ui/screens/liked_photos_screen.dart';
import 'package:reaxit/ui/widgets.dart';

class PhotosScreen extends StatefulWidget {
  final String? currentScreen;

  const PhotosScreen({super.key, this.currentScreen});

  @override
  State<StatefulWidget> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _controller;
  late AlbumListCubit _cubit;
  late final FaceDetectionCubit _faceDetectionCubit;

  @override
  void initState() {
    _tabController = TabController(
      length: 3,
      initialIndex: _groupTypeToIndex(widget.currentScreen),
      vsync: this,
    );

    _controller = ScrollController()..addListener(_scrollListener);
    _faceDetectionCubit = FaceDetectionCubit(
      RepositoryProvider.of<ApiRepository>(context),
    )..load();
    super.initState();
  }

  void _scrollListener() {
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 300) {
      // Only request loading more if that's not already happening.
      if (!_cubit.state.isLoadingMore) {
        _cubit.more();
      }
    }
  }

  int _groupTypeToIndex(String? currentScreen) {
    if (currentScreen == 'albums') {
      return 0;
    } else if (currentScreen == 'faceDetection') {
      return 1;
    } else if (currentScreen == 'likedFotos') {
      return 2;
    } else {
      return 0;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _faceDetectionCubit.close();
    super.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PhotosScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _tabController.index = _groupTypeToIndex(widget.currentScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThaliaAppBar(
        title: const Text('PHOTOS'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Albums'),
            Tab(text: 'Face Detection'),
            Tab(text: 'Liked Photos'),
          ],
          indicatorColor: Theme.of(context).colorScheme.primary,
        ),
        collapsingActions: [
          IconAppbarAction('SEARCH', Icons.search, () async {
            final searchCubit = AlbumListCubit(
              RepositoryProvider.of<ApiRepository>(context),
            );

            await showSearch(
              context: context,
              delegate: AlbumsSearchDelegate(searchCubit),
            );
            searchCubit.close();
          }),
        ],
      ),
      drawer: MenuDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [AlbumsScreen(), FaceDetectionScreen(), LikedPhotosScreen()],
      ),
    );
  }
}
