import 'package:flutter/material.dart';
import 'package:reaxit/models/album.dart';

class AlbumScreen extends StatefulWidget {
  final int pk;
  final ListAlbum? album;

  AlbumScreen({required this.pk, this.album}) : super(key: ValueKey(pk));

  @override
  _AlbumScreenState createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('album ${widget.pk}'),
      ),
    );
  }
}
