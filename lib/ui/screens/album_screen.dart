import 'package:flutter/material.dart';
import 'package:reaxit/ui/widgets.dart';
import 'package:reaxit/ui/widgets/photo_tile.dart';

/// Screen that loads and shows the Album with `slug`.
class AlbumScreen extends StatelessWidget {
  const AlbumScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThaliaAppBar(
        title: const Text('wheyyy'),
      ),
      body: const PhotoTile(),
    );
  }
}
