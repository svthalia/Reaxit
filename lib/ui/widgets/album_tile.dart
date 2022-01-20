import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reaxit/models/album.dart';
import 'package:reaxit/ui/widgets/cached_image.dart';

class AlbumTile extends StatelessWidget {
  final ListAlbum album;

  AlbumTile({Key? key, required this.album}) : super(key: ValueKey(album.slug));

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedImage(
          imageUrl: album.cover.small,
          placeholder: 'assets/img/album_placeholder.png',
        ),
        const _BlackGradient(),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              album.title,
              style: Theme.of(context).primaryTextTheme.bodyText2,
            ),
          ),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.pushNamed(
                'album',
                params: {'albumSlug': album.slug},
                extra: album,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BlackGradient extends StatelessWidget {
  static const _black00 = Color(0x00000000);
  static const _black50 = Color(0x80000000);

  const _BlackGradient();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black,
        gradient: LinearGradient(
          begin: FractionalOffset.topCenter,
          end: FractionalOffset.bottomCenter,
          colors: [_black00, _black50],
          stops: [0.4, 1.0],
        ),
      ),
    );
  }
}
