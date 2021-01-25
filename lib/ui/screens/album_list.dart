import 'package:flutter/material.dart';
import 'package:reaxit/providers/photos_provider.dart';
import 'package:reaxit/ui/components/album_card.dart';
import 'package:reaxit/ui/components/menu_drawer.dart';
import 'package:reaxit/ui/components/network_scrollable_wrapper.dart';
import 'package:reaxit/ui/components/network_search_delegate.dart';

class AlbumList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: "Search for albums",
            onPressed: () {
              showSearch(
                context: context,
                delegate: NetworkSearchDelegate<PhotosProvider>(
                  resultBuilder: (context, albumList, child) {
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        crossAxisCount: 2,
                      ),
                      itemCount: albumList.length,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      itemBuilder: (context, index) =>
                          AlbumCard(albumList[index]),
                    );
                  },
                ),
              );
            },
          )
        ],
      ),
      drawer: MenuDrawer(),
      body: NetworkScrollableWrapper<PhotosProvider>(
        builder: (context, photos, child) => GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
          ),
          itemCount: photos.albumList.length,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          itemBuilder: (context, index) => AlbumCard(photos.albumList[index]),
        ),
      ),
    );
  }
}
