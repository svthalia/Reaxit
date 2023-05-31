import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reaxit/models.dart';

import 'cached_image.dart';

class AlbumTile extends StatelessWidget {
  final ListAlbum album;

  AlbumTile({Key? key, required this.album}) : super(key: ValueKey(album.slug));

  @override
  Widget build(BuildContext context) {
    final cover = album.cover;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (cover != null)
          RotatedBox(
            quarterTurns: cover.rotation ~/ 90,
            child: CachedImage(
              placeholder:
                  'assets/img/photo_placeholder_${(360 - cover.rotation) % 360}.png',
              imageUrl: cover.small,
            ),
          ),
        if (cover == null) Image.asset('assets/img/photo_placeholder_0.png'),
        const _BlackGradient(),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              album.title,
              style: Theme.of(context).primaryTextTheme.bodyMedium,
            ),
          ),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.pushNamed(
                'album',
                pathParameters: {'albumSlug': album.slug},
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
