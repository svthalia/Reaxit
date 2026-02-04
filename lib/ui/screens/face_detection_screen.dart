import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs/list_state.dart';
import 'package:reaxit/blocs/photos_cubit.dart';
import 'package:reaxit/models/photo.dart';
import 'package:reaxit/ui/widgets.dart';
import 'package:reaxit/ui/widgets/photo_grid_sliver.dart';

class FaceDetectionScreen extends StatefulWidget {
  const FaceDetectionScreen();

  @override
  State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  late ScrollController _controller;
  late final FaceDetectionPhotosCubit _cubit;
  late final ReferencePhotosCubit _referenceCubit;

  @override
  void initState() {
    _controller = ScrollController()..addListener(_scrollListener);
    _cubit = FaceDetectionPhotosCubit(
      RepositoryProvider.of<ApiRepository>(context),
    )..load();
    _referenceCubit = ReferencePhotosCubit(
      RepositoryProvider.of<ApiRepository>(context),
    )..load();
    super.initState();
  }

  void _scrollListener() {
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 300) {
      _cubit.more();
      _referenceCubit.more();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _cubit.close();
    _referenceCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cubit),
        BlocProvider.value(value: _referenceCubit),
      ],
      child: Scaffold(
        appBar: ThaliaAppBar(title: const Text("PHOTOS YOU'RE ON")),
        body: RefreshIndicator(
          onRefresh: () async {
            await _cubit.load();
            await _referenceCubit.load();
          },
          child: BlocBuilder<
            FaceDetectionPhotosCubit,
            FaceDetectionPhotosState
          >(
            builder: (context, state) {
              return BlocBuilder<ReferencePhotosCubit, ReferencePhotosState>(
                builder: (referenceContext, referenceState) {
                  if (state.hasException) {
                    return ErrorScrollView(state.message!);
                  }

                  return FaceDetectionGridScrollView(
                    controller: _controller,
                    listState: state,
                    referenceState: referenceState,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class FaceDetectionGridScrollView extends StatelessWidget {
  final ScrollController controller;
  final ListState<AlbumPhoto> listState;
  final ListState<AlbumPhoto> referenceState;

  const FaceDetectionGridScrollView({
    required this.controller,
    required this.listState,
    required this.referenceState,
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
          if (referenceState.results.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'No reference photos found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Reference photos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          PhotoGridSliver(listState: referenceState),
          if (referenceState.isLoadingMore)
            const SliverPadding(
              padding: EdgeInsets.all(8),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  Center(child: CircularProgressIndicator()),
                ]),
              ),
            ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Photos you\'re on',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
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
