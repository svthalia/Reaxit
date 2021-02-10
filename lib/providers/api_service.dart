import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:reaxit/providers/auth_provider.dart';

enum ApiException {
  noInternet,
  notAllowed,
  notFound,
  unknownError,
  notLoggedIn,
}

abstract class ApiService extends ChangeNotifier {
  AuthProvider authProvider;
  final String _apiUrl = 'https://staging.thalia.nu/api/v1';

  /// A helper method that performs a GET request. This
  /// throws an [ApiException] when something goes wrong.
  /// Returns the response body on status code 200.
  Future<String> get(String url) async {
    if (authProvider.status == AuthStatus.SIGNED_IN) {
      try {
        Response response = await authProvider.helper.get(_apiUrl + url);
        if (response.statusCode == 200) {
          return response.body;
        } else if (response.statusCode == 403) {
          throw ApiException.notAllowed;
        } else if (response.statusCode == 404) {
          throw ApiException.notFound;
        } else {
          throw ApiException.unknownError;
        }
      } on SocketException catch (_) {
        throw ApiException.noInternet;
      } catch (_) {
        throw ApiException.unknownError;
      }
    } else {
      throw ApiException.notLoggedIn;
    }
  }

  /// A helper method that performs a POST request. This
  /// throws an [ApiException] when something goes wrong.
  /// Returns the response body on status code 200 or 201.
  Future<String> post(String url, String body) async {
    if (authProvider.status == AuthStatus.SIGNED_IN) {
      try {
        Response response = await authProvider.helper.post(
          _apiUrl + url,
          body: body,
        );
        if (response.statusCode == 200) {
          return response.body;
        } else if (response.statusCode == 201) {
          return response.body;
        } else if (response.statusCode == 403) {
          throw ApiException.notAllowed;
        } else if (response.statusCode == 404) {
          throw ApiException.notFound;
        } else {
          throw ApiException.unknownError;
        }
      } on SocketException catch (_) {
        throw ApiException.noInternet;
      } catch (_) {
        throw ApiException.unknownError;
      }
    } else {
      throw ApiException.notLoggedIn;
    }
  }

  /// A helper method that performs a PUT request. This
  /// throws an [ApiException] when something goes wrong.
  Future<void> put(String url, String body) async {
    if (authProvider.status == AuthStatus.SIGNED_IN) {
      try {
        Response response = await authProvider.helper.put(
          _apiUrl + url,
          body: body,
        );
        if (response.statusCode == 200) {
          return;
        } else if (response.statusCode == 201) {
          return;
        } else if (response.statusCode == 403) {
          throw ApiException.notAllowed;
        } else if (response.statusCode == 404) {
          throw ApiException.notFound;
        } else {
          throw ApiException.unknownError;
        }
      } on SocketException catch (_) {
        throw ApiException.noInternet;
      } catch (_) {
        throw ApiException.unknownError;
      }
    } else {
      throw ApiException.notLoggedIn;
    }
  }

  /// A helper method that performs a PATCH request. This
  /// throws an [ApiException] when something goes wrong.
  /// Returns the response body on status code 200 or 201.
  Future<String> patch(String url, String body) async {
    if (authProvider.status == AuthStatus.SIGNED_IN) {
      try {
        Response response = await authProvider.helper.patch(
          _apiUrl + url,
          body: body,
        );
        if (response.statusCode == 200) {
          return response.body;
        } else if (response.statusCode == 201) {
          return response.body;
        } else if (response.statusCode == 403) {
          throw ApiException.notAllowed;
        } else if (response.statusCode == 404) {
          throw ApiException.notFound;
        } else {
          throw ApiException.unknownError;
        }
      } on SocketException catch (_) {
        throw ApiException.noInternet;
      } catch (_) {
        throw ApiException.unknownError;
      }
    } else {
      throw ApiException.notLoggedIn;
    }
  }

  ApiException _error;
  ApiException get error => _error;
  bool get hasError => _error != null;

  bool _isLoading;
  bool get isLoading => _isLoading;

  /// Wrapper around [loadImplementation()] that handles [error] and [isLoding].
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await loadImplementation();
    } on ApiException catch (e) {
      _error = e;
    }
    _isLoading = false;
    notifyListeners();
  }

  ApiService(this.authProvider) {
    load();
  }

  /// Loading function that is used in [load()]. Any [ApiExceptions] thrown by
  /// this are stored in [this.error]. Use this to prepare the service for use,
  /// e.g. to load a long list.
  Future<void> loadImplementation();
}

abstract class ApiSearchService extends ApiService {
  ApiSearchService(AuthProvider authProvider) : super(authProvider);

  Future<List<dynamic>> search(String query);
}
