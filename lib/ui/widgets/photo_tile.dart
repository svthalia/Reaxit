import 'package:flutter/material.dart';
import 'package:reaxit/models/photo.dart';

class PhotoTile extends StatelessWidget {
  final AlbumPhoto photo;
  final void Function() openGallery;

  PhotoTile({
    required this.photo,
    required this.openGallery,
  }) : super(key: ValueKey(photo.pk));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: openGallery,
      child: FadeInImage.assetNetwork(
        placeholder: 'assets/img/photo_placeholder.png',
        image: photo.small,
        fit: BoxFit.cover,
      ),
    );
  }
}
