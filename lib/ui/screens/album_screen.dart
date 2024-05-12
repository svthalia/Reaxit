import 'package:flutter/material.dart';
import 'package:reaxit/ui/widgets.dart';
import 'package:reaxit/ui/widgets/photo_tile.dart';

/// Screen that loads and shows the Album with `slug`.
class AlbumScreen extends StatefulWidget {
  const AlbumScreen();

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThaliaAppBar(
        title: const Text('wheyyy'),
      ),
      body: const _PhotoGrid(),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid();

  @override
  Widget build(BuildContext context) {
    return const Scrollbar(
      child: PhotoTile(),
    );
  }
}
