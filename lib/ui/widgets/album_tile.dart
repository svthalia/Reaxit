import 'package:flutter/material.dart';
import 'package:reaxit/models.dart';

class AlbumTile extends StatelessWidget {
  final ListAlbum album;

  AlbumTile({Key? key, required this.album}) : super(key: ValueKey(album.slug));

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/img/photo_placeholder_0.png'),
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
      ],
    );
  }
}
