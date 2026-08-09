import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs/liked_photos_cubit.dart';
import 'package:reaxit/models/photo.dart';
import 'package:reaxit/ui/widgets/gallery.dart';
import 'package:reaxit/ui/widgets/paginated_scroll_view.dart';
import 'package:reaxit/ui/widgets/photo_tile.dart';

class LikedPhotosScreen extends StatelessWidget {
  void _openGallery(BuildContext context, int index) {
    final cubit = BlocProvider.of<LikedPhotosCubit>(context);
    showDialog(
      context: context,
      useSafeArea: false,
      barrierColor: Colors.black.withValues(alpha: 0.92),
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
    return BlocProvider(
      create: (context) =>
          LikedPhotosCubit(RepositoryProvider.of<ApiRepository>(context))
            ..load(),
      child: PaginatedScrollView<LikedPhotosCubit, AlbumPhoto>(
        resultsBuilder: (context, photos) => [
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => PhotoTile(
                photo: photos[index],
                openGallery: () => _openGallery(context, index),
              ),
              childCount: photos.length,
            ),
          ),
        ],
      ),
    );
  }
}
