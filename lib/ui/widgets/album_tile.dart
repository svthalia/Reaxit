import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:reaxit/cache_manager.dart';
import 'package:reaxit/models/album.dart';
import 'package:reaxit/ui/router.dart';
import 'package:reaxit/ui/screens/album_screen.dart';

class AlbumTile extends StatelessWidget {
  final ListAlbum album;

  const AlbumTile({Key? key, required this.album}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          cacheManager: ThaliaCacheManager(),
          cacheKey: Uri.parse(album.cover.small).replace(query: '').toString(),
          imageUrl: album.cover.small,
          fit: BoxFit.cover,
          fadeOutDuration: const Duration(milliseconds: 200),
          fadeInDuration: const Duration(milliseconds: 200),
          placeholder: (_, __) => Image.asset(
            'assets/img/album_placeholder.png',
            fit: BoxFit.cover,
          ),
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
              onTap: () {
                ThaliaRouterDelegate.of(context).push(
                  TypedMaterialPage(
                    child: AlbumScreen(slug: album.slug, album: album),
                    name: 'Album(${album.slug})',
                  ),
                );
              },
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
