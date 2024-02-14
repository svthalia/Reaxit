import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs/liked_photos_cubit.dart';
import 'package:reaxit/ui/widgets.dart';
import 'package:reaxit/ui/widgets/gallery.dart';
import 'package:reaxit/ui/widgets/photo_tile.dart';

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
    _cubit.close();
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
        ),
      ),
    );
  }
}

class _PhotoGridScrollView extends StatelessWidget {
  final ScrollController controller;
  final LikedPhotosState listState;

  const _PhotoGridScrollView({
    required this.controller,
    required this.listState,
  });

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
              return Gallery<LikedPhotosCubit>(
                photos: state.results,
                initialPage: index,
                photoAmount: state.count!,
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
                delegate: SliverChildListDelegate.fixed(
                  [Center(child: CircularProgressIndicator())],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
