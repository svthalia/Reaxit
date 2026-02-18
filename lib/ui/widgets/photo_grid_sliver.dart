import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/list_state.dart';
import 'package:reaxit/blocs/photos_cubit.dart';
import 'package:reaxit/models/photo.dart';
import 'package:reaxit/ui/widgets/gallery.dart';
import 'package:reaxit/ui/widgets/photo_tile.dart';

class PhotoGridSliver extends StatelessWidget {
  final ListState<AlbumPhoto> listState;
  final void Function(BuildContext context, int index)? customOpenGallery;

  const PhotoGridSliver({
    super.key,
    required this.listState,
    this.customOpenGallery,
  });

  void _openGallery(BuildContext context, int index) {
    final cubit = BlocProvider.of<PhotosCubit>(context);
    showDialog(
      context: context,
      useSafeArea: false,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (context) {
        return BlocProvider.value(
          value: cubit,
          child: BlocBuilder<PhotosCubit, ListState<AlbumPhoto>>(
            buildWhen:
                (previous, current) =>
                    !current.isLoading && !current.isLoadingMore,
            builder: (context, state) {
              return Gallery<PhotosCubit>(
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

  void _handleOpen(BuildContext context, int index) {
    if (customOpenGallery != null) {
      customOpenGallery!(context, index);
    } else {
      _openGallery(context, index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
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
            openGallery: () => _handleOpen(context, index),
          ),
          childCount: listState.results.length,
        ),
      ),
    );
  }
}
