import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs/list_state.dart';
import 'package:reaxit/blocs/photos_cubit.dart';
import 'package:reaxit/models/photo.dart';
import 'package:reaxit/ui/widgets.dart';
import 'package:reaxit/ui/widgets/photo_grid_sliver.dart';

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
        appBar: ThaliaAppBar(title: const Text('LIKED PHOTOS')),
        body: RefreshIndicator(
          onRefresh: () async {
            await _cubit.load();
          },
          child: BlocBuilder<LikedPhotosCubit, LikedPhotosState>(
            builder: (context, state) {
              if (state.hasException) {
                return ErrorScrollView(state.message!);
              } else {
                return LikedPhotosGridScrollView(
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

class LikedPhotosGridScrollView extends StatelessWidget {
  final ScrollController controller;
  final ListState<AlbumPhoto> listState;

  const LikedPhotosGridScrollView({
    required this.controller,
    required this.listState,
  });

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
          PhotoGridSliver(listState: listState),
          PhotoGridSliver(listState: listState),
          if (listState.isLoadingMore)
            const SliverPadding(
              padding: EdgeInsets.all(8),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  Center(child: CircularProgressIndicator()),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}
