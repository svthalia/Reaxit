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
    if (authProvider.status == Status.SIGNED_IN) {
      status = ApiStatus.LOADING;
      notifyListeners();

      try {
        Response response = await authProvider.helper
            .get('https://staging.thalia.nu/api/v1/photos/albums');
        if (response.statusCode == 200) {
          List<dynamic> jsonAlbumList = jsonDecode(response.body)['results'];
          _albumList = jsonAlbumList
              .map((jsonAlbum) => Album.fromJson(jsonAlbum))
              .toList();
          status = ApiStatus.DONE;
        } else if (response.statusCode == 403)
          status = ApiStatus.NOT_AUTHENTICATED;
        else
          status = ApiStatus.UNKNOWN_ERROR;
      } on SocketException catch (_) {
        status = ApiStatus.NO_INTERNET;
      } catch (_) {
        status = ApiStatus.UNKNOWN_ERROR;
      }

      notifyListeners();
    }
  }

  // TODO: proper error handling of getMember and search
  Future<Album> getAlbum(int pk) async {
    if (authProvider.status == Status.SIGNED_IN) {
      Response response = await authProvider.helper
          .get('https://staging.thalia.nu/api/v1/photos/albums/$pk');
      if (response.statusCode == 200) {
        return Album.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 204) {
        throw ("No result");
      } else {
        throw ("Something else");
      }
    } else {
      throw ("Not logged in");
    }
  }

  @override
  Future<List<Album>> search(String query) async {
    if (authProvider.status == Status.SIGNED_IN) {
      Response response = await authProvider.helper.get(
          'https://staging.thalia.nu/api/v1/photos/albums/?search=${Uri.encodeComponent(query)}');
      if (response.statusCode == 200) {
        List<dynamic> jsonAlbumList = jsonDecode(response.body)['results'];
        return jsonAlbumList
            .map((jsonAlbum) => Album.fromJson(jsonAlbum))
            .toList();
      } else if (response.statusCode == 204) {
        throw ("No result");
      } else {
        throw ("Something else");
      }
    } else {
      throw ("Not logged in");
    }
  }
}
