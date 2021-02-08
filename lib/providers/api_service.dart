import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:reaxit/providers/auth_provider.dart';

// TODO: should list building really use ApiStatus.loading? this may be inflexible for providers that offer multiple types of lists or something
enum ApiStatus {
  LOADING,
  DONE,
  NO_INTERNET,
  NOT_AUTHENTICATED,
  UNKNOWN_ERROR,
}

class ApiException implements Exception {}

abstract class ApiService extends ChangeNotifier {
  AuthProvider authProvider;
  final String _apiUrl = 'https://staging.thalia.nu/api/v1';

  ApiStatus status;

  Future<String> get(String url) async {
    if (authProvider.status == AuthStatus.SIGNED_IN) {
      try {
        Response response = await authProvider.helper.get(_apiUrl + url);
        if (response.statusCode == 200) {
          return response.body;
        } else if (response.statusCode == 403) {
          status = ApiStatus.NOT_AUTHENTICATED;
        } else {
          status = ApiStatus.UNKNOWN_ERROR;
        }
      } on SocketException catch (_) {
        status = ApiStatus.NO_INTERNET;
      } catch (_) {
        status = ApiStatus.UNKNOWN_ERROR;
      }
    } else {
      status = ApiStatus.NOT_AUTHENTICATED;
    }
    throw ApiException();
  }

  ApiService(AuthProvider authProvider) {
    this.authProvider = authProvider;
    load();
  }

  Future<void> load();
}

abstract class ApiSearchService extends ApiService {
  ApiSearchService(AuthProvider authProvider) : super(authProvider);

  Future<List<dynamic>> search(String query);
}
