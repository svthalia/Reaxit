import 'package:flutter/material.dart';
import 'package:reaxit/ui/menu_drawer.dart';

class AlbumsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: MenuDrawer(),
      body: Center(
        child: Text('Albums'),
      ),
    );
  }
}
