import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs/album_cubit.dart';
import 'package:reaxit/config.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/ui/widgets.dart';
import 'package:reaxit/ui/widgets/gallery.dart';
import 'package:reaxit/ui/widgets/photo_tile.dart';
import 'package:share_plus/share_plus.dart';

const imagelink1 =
    'https://raw.githubusercontent.com/svthalia/Reaxit/3e3a74364f10cd8de14ac1f74de8a05aa6d00b28/assets/img/album_placeholder.png';

const imagelink2 =
    'https://raw.githubusercontent.com/svthalia/Reaxit/3e3a74364f10cd8de14ac1f74de8a05aa6d00b28/assets/img/default-avatar.jpg';

/// Screen that loads and shows the Album with `slug`.
class AlbumScreen extends StatefulWidget {
  final String slug;
  final ListAlbum? album;

  AlbumScreen({required this.slug, this.album}) : super(key: ValueKey(slug));

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  late final AlbumCubit _cubit;

  String get title => widget.album?.title ?? 'ALBUM';

  @override
  void initState() {
    super.initState();
    _cubit = AlbumCubit(RepositoryProvider.of<ApiRepository>(context))
      ..load(widget.slug);
  }

  Future<void> _shareAlbum(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final host = Config.of(context).host;
      await Share.share(
        'https://$host/members/photos/${widget.slug}/',
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Could not share the album.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Widget body = _PhotoGrid([
      AlbumPhoto(
        0,
        0,
        Photo(
          imagelink1,
          imagelink1,
          imagelink1,
          imagelink1,
        ),
        false,
        0,
      ),
      AlbumPhoto(
        0,
        0,
        Photo(
          imagelink2,
          imagelink2,
          imagelink2,
          imagelink2,
        ),
        false,
        0,
      )
    ]);

    return Scaffold(
      appBar: ThaliaAppBar(
        title: const Text('wheyyy'),
        collapsingActions: [
          IconAppbarAction(
            'SHARE',
            Icons.adaptive.share,
            () => _shareAlbum(context),
            tooltip: 'share album',
          )
        ],
      ),
      body: body,
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  final List<AlbumPhoto> photos;

  const _PhotoGrid(this.photos);

  void _openGallery(BuildContext context, int index) {
    final cubit = BlocProvider.of<AlbumCubit>(context);
    showDialog(
      context: context,
      useSafeArea: false,
      barrierColor: Colors.black.withOpacity(0.92),
      builder: (context) {
        return BlocProvider.value(
          value: cubit,
          child: BlocBuilder<AlbumCubit, AlbumState>(
            buildWhen: (previous, current) => current is ResultState,
            builder: (context, state) {
              return Gallery<AlbumCubit>(
                // TODO: buildWhen actually does not guarantee not building without result.
                photos: state.result!.photos,
                initialPage: index,
                photoAmount: state.result!.photos.length,
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
        itemBuilder: (context, index) => PhotoTile(
          photo: photos[index],
          openGallery: () => _openGallery(context, index),
        ),
      ),
    );
  }
}
