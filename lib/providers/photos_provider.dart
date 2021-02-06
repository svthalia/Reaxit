import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:reaxit/models/album.dart';
import 'package:reaxit/providers/api_service.dart';
import 'package:reaxit/providers/auth_provider.dart';

class PhotosProvider extends ApiSearchService {
  List<Album> _albumList = [];

  List<Album> get albumList => _albumList;

  PhotosProvider(AuthProvider authProvider) : super(authProvider);

  Future<void> load() async {
    status = ApiStatus.LOADING;
    notifyListeners();
    try {
      String response = await this.get("/photos/albums/");
      List<dynamic> jsonAlbums = jsonDecode(response)['results'];
      _albumList =
          jsonAlbums.map((jsonAlbum) => Album.fromJson(jsonAlbum)).toList();
      status = ApiStatus.DONE;
      notifyListeners();
    } on ApiException catch (_) {
      notifyListeners();
    }
  }

  // TODO: proper error handling of getMember and search
  Future<Album> getAlbum(int pk) async {
    try {
      String response = await this.get("/photos/albums/$pk");
      return Album.fromJson(jsonDecode(response));
    } on ApiException catch (_) {
      // TODO: handle 404 separately
      notifyListeners();
    }
  }

  @override
  Future<List<Album>> search(String query) async {
    try {
      String response = await this.get(
        "/photos/albums/?search=${Uri.encodeComponent(query)}",
      );
      List<dynamic> jsonAlbums = jsonDecode(response)['results'];
      return jsonAlbums.map((jsonAlbum) => Album.fromJson(jsonAlbum)).toList();
    } on ApiException catch (_) {
      notifyListeners();
    }
  }
}
