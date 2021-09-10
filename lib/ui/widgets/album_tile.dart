import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:reaxit/models/album.dart';
import 'package:reaxit/ui/screens/album_screen.dart';

class AlbumTile extends StatelessWidget {
  final ListAlbum album;

  const AlbumTile({Key? key, required this.album}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      routeSettings: RouteSettings(name: 'Album(${album.slug})'),
      transitionType: ContainerTransitionType.fadeThrough,
      closedShape: const RoundedRectangleBorder(),
      closedBuilder: (context, __) => Stack(
        fit: StackFit.expand,
        children: [
          FadeInImage.assetNetwork(
            placeholder: 'assets/img/album_placeholder.png',
            image: album.cover.medium,
            fit: BoxFit.cover,
            fadeInDuration: const Duration(milliseconds: 200),
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
                stops: const [0.4, 1.0],
              ),
            ),
            child: Text(
              album.title,
              style: Theme.of(context).primaryTextTheme.bodyText2,
            ),
          )
        ],
      ),
      openBuilder: (_, __) => AlbumScreen(slug: album.slug, album: album),
    );
  }
}
