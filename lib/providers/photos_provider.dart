import 'dart:convert';

import 'package:reaxit/models/album.dart';
import 'package:reaxit/providers/api_service.dart';
import 'package:reaxit/providers/auth_provider.dart';

class PhotosProvider extends ApiService {
  List<Album> _albumList = [];

  List<Album> get albumList => _albumList;

  PhotosProvider(AuthProvider authProvider) : super(authProvider);

  @override
  Future<void> loadImplementation() async {
    _albumList = await _getAlbums();
  }

  Future<List<Album>> _getAlbums() async {
    String response = await this.get("/photos/albums/");
    List<dynamic> jsonAlbums = jsonDecode(response)['results'];
    return jsonAlbums.map((jsonAlbum) => Album.fromJson(jsonAlbum)).toList();
  }

  Future<List<Album>> search(String query) async {
    String response = await this.get(
      "/photos/albums/?search=${Uri.encodeComponent(query)}",
    );
    List<dynamic> jsonAlbums = jsonDecode(response)['results'];
    return jsonAlbums.map((jsonAlbum) => Album.fromJson(jsonAlbum)).toList();
  }

  Future<Album> getAlbum(int pk) async {
    String response = await this.get("/photos/albums/$pk");
    return Album.fromJson(jsonDecode(response));
  }
}
