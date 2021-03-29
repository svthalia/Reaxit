import 'package:flutter/material.dart';

class AlbumScreen extends StatefulWidget {
  final int albumPk;

  const AlbumScreen({Key? key, required this.albumPk}) : super(key: key);

  @override
  _AlbumScreenState createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('event ${widget.albumPk}'),
      ),
    );
  }
}
