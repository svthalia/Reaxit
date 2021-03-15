import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/models/album.dart';
import 'package:reaxit/providers/photos_provider.dart';

class AlbumDetail extends StatefulWidget {
  final int pk;
  final Album album;
  AlbumDetail(this.pk, [this.album]);

  @override
  _AlbumDetailState createState() => _AlbumDetailState();
}

class _AlbumDetailState extends State<AlbumDetail> {
  Future<Album> _album;

  @override
  didChangeDependencies() {
    _album =
        Provider.of<PhotosProvider>(context, listen: false).getAlbum(widget.pk);
    super.didChangeDependencies();
  }

  void _showPhotoGallery(BuildContext context, Album album, int index) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) {
        return Scaffold(
          body: Stack(
            children: [
              PhotoViewGallery.builder(
                itemCount: album.photos.length,
                builder: (context, i) => PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(album.photos[i].full),
                  tightMode: false,
                ),
                pageController: PageController(initialPage: index),
              ),
              // TODO: share button
              CloseButton(
                color: Theme.of(context).primaryIconTheme.color,
              ),
            ],
          ),
          backgroundColor: Colors.transparent,
        );
      },
    );
  }

  Widget _photoCard(BuildContext context, Album album, int index) {
    return GestureDetector(
      onTap: () => _showPhotoGallery(context, album, index),
      child: Hero(
        tag: "photo_${album.photos[index].pk}",
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/img/default-avatar.jpg',
          image: album.photos[index].medium,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Album"),
      ),
      body: FutureBuilder(
        future: _album,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Album album = snapshot.data;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                crossAxisCount: 3,
              ),
              itemCount: album.photos.length,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(5),
              itemBuilder: (context, index) =>
                  _photoCard(context, album, index),
            );
          } else if (snapshot.hasError) {
            // TODO: handle error
            return Center(
                child: Text("An error occurred while fetching album data."));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
