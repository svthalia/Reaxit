import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/blocs/photos_cubit.dart';
import 'package:reaxit/models/photo.dart';
import 'package:reaxit/ui/widgets/gallery.dart';
import 'package:reaxit/ui/widgets/paginated_scroll_view.dart';
import 'package:reaxit/ui/widgets/photo_tile.dart';

typedef PhotosState = DetailState<InnerListState<AlbumPhoto>>;

class PhotoTiles<C extends PhotosCubit> extends StatelessWidget {
  final C Function(ApiRepository repository) createCubit;

  const PhotoTiles({
    super.key,
    required this.createCubit,
  });

  void _openGallery(BuildContext context, int index) {
    final cubit = context.read<C>();

    showDialog(
      context: context,
      useSafeArea: false,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (context) {
        return BlocProvider.value(
          value: cubit,
          child: BlocBuilder<C, PhotosState>(
            buildWhen: (previous, current) => switch (current) {
              LoadingState _ || LoadingResultState _ => false,
              _ => true,
            },
            builder: (context, state) {
              final (results, count) = switch (state) {
                ResultState(
                  result: InnerListState(
                    results: final List<AlbumPhoto> results,
                    count: final int count,
                  ),
                ) => (results, count),
                _ => (<AlbumPhoto>[], 0),
              };

              return Gallery<C>(
                photos: results,
                initialPage: index,
                photoAmount: count,
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<C>(
      create: (context) =>
          createCubit(RepositoryProvider.of<ApiRepository>(context))..load(),
      child: PaginatedScrollView<C, AlbumPhoto>(
          resultsBuilder: (context, photos) => [
            SliverPadding(
              padding: const EdgeInsets.all(8),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
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
            ),
          ],
      ),
    );
  }
}