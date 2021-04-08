import 'package:flutter/material.dart';
import 'package:reaxit/models/album.dart';
import 'package:reaxit/ui/router/router.dart';
import 'package:reaxit/ui/screens/album_screen.dart';

class AlbumTile extends StatelessWidget {
  final ListAlbum album;

  const AlbumTile({Key? key, required this.album}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ThaliaRouterDelegate.of(context).push(
          MaterialPage(
            child: AlbumScreen(
              pk: album.pk,
              album: album,
            ),
          ),
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'album_${album.pk}',
            child: FadeInImage.assetNetwork(
              placeholder: 'assets/img/default-avatar.jpg',
              image: album.cover.medium,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 200),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.bottomLeft,
            decoration: BoxDecoration(
              color: Colors.black,
              gradient: LinearGradient(
                begin: FractionalOffset.topCenter,
                end: FractionalOffset.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.0),
                  Colors.black.withOpacity(0.5),
                ],
                stops: [0.4, 1.0],
              ),
            ),
            child: Text(
              album.title,
              style: Theme.of(context).primaryTextTheme.bodyText2,
            ),
          )
        ],
      ),
    );
  }
}
