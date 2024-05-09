import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/config.dart';
import 'package:reaxit/models.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class LoggingClient extends oauth2.Client {
  LoggingClient(
    super.credentials, {
    super.identifier,
    super.secret,
    super.basicAuth,
    super.httpClient,
    super.onCredentialsRefreshed,
  });

  LoggingClient.fromClient(oauth2.Client client)
      : super(
          client.credentials,
          identifier: client.identifier,
          secret: client.secret,
        );

  static void logResponse(Uri url, int statusCode) {
    if (kDebugMode) {
      print('url: $url, response code: $statusCode');
    }
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final response = await super.send(request);
    if (kDebugMode) {
      print('url: ${request.url}, response code: ${response.statusCode}');
    }
    return response;
  }
}

/// Provides an interface to the api.
///
/// Its methods may throw an [ApiException] if there are unexpected results.
/// In case credentials cannot be refreshed, this calls `logOut`, which should
/// close the client and indicates that the user is no longer logged in.
class ConcrexitApiRepository implements ApiRepository {
  @override
  final Config config;

  /// The authenticated client used to access the API.
  LoggingClient? _innerClient;

  final Function() _onLogOut;

  ConcrexitApiRepository({
    /// The authenticated client used to access the API.
    required LoggingClient client,

    /// An [Config] describing the API.
    required this.config,

    /// Called when the client can no longer authenticate.
    required Function() onLogOut,
  })  : _innerClient = client,
        _onLogOut = onLogOut,
        _baseUri = Uri(
          scheme: config.scheme,
          host: config.host,
          port: config.port,
        );

  @override
  void close() {
    if (_innerClient != null) {
      _innerClient!.close();
      _innerClient = null;
    }
  }

  /// The authenticated client used to access the API.
  ///
  /// Throws [ApiException.notLoggedIn] if the ApiRepository is not closed.
  LoggingClient get _client {
    if (_innerClient == null) {
      throw ApiException.notLoggedIn;
    } else {
      return _innerClient!;
    }
  }

  final Uri _baseUri;

  static const String _basePath = 'api/v2';

  /// Headers that should be specified on requests with a JSON body.
  static const Map<String, String> _jsonHeader = {
    'Content-type': 'application/json',
  };

  /// Convenience method for building a URL to an API endpoint.
  Uri _uri({required String path, Map<String, dynamic>? query}) {
    return _baseUri.replace(
      path: path.startsWith('/') ? '$_basePath$path' : '$_basePath/$path',
      queryParameters: query,
    );
  }

  /// Wrapper that utf-8 decodes the body of a response to json.
  static Map<String, dynamic> _jsonDecode(Response response) =>
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

  /// A wrapper for requests that throws only [ApiException]s.
  ///
  /// Translates exceptions that can be thrown by [oauth2.Client.send()],
  /// and throws exceptions based on status codes. By default, all status codes
  /// other than 200, 201, 203, and 204 result in an [ApiException], but this can be
  /// overridden with `allowedStatusCodes`.
  ///
  /// Can be called for example as:
  /// ```dart
  /// final response = await _handleExceptions(() => client.get(uri));
  /// ```
  ///
  /// If you want to manually handle for example 403s, you can use:
  /// ```dart
  /// final response = await _handleExceptions(
  ///   () => client.get(uri),
  ///   allowedStatusCodes: [200, 403],
  /// );
  /// // Use `response.statusCode` here to handle 403.
  /// ```
  Future<Response> _handleExceptions(
    Future<Response> Function() request, {
    List<int> allowedStatusCodes = const [200, 201, 202, 204],
  }) async {
    try {
      final response = await request();
      if (allowedStatusCodes.contains(response.statusCode)) return response;
      switch (response.statusCode) {
        case 401:
          _onLogOut();
          throw ApiException.notLoggedIn;
        case 403:
          throw ApiException.notAllowed;
        case 404:
          throw ApiException.notFound;
        default:
          throw ApiException.unknownError;
      }
    } on oauth2.ExpirationException {
      _onLogOut();
      throw ApiException.notLoggedIn;
    } on oauth2.AuthorizationException {
      _onLogOut();
      throw ApiException.notLoggedIn;
    } on SocketException {
      throw ApiException.noInternet;
    } on FormatException {
      throw ApiException.unknownError;
    } on ClientException {
      throw ApiException.unknownError;
    } on HandshakeException {
      throw ApiException.unknownError;
    } on OSError {
      throw ApiException.unknownError;
    } on ApiException {
      rethrow;
    }
  }

  /// Handler to surround all public methods as follows:
  ///
  /// ```dart
  /// return sandbox(() async {
  ///  // Method content ...
  /// });
  /// ```
  ///
  /// This prevents the ApiRepository from throwing any exceptions other than
  /// ApiExceptions.
  static Future<T> sandbox<T>(Future<T> Function() f) async {
    try {
      return await f();
    } on ApiException {
      rethrow;
    } catch (e) {
      Sentry.captureException(e);
      throw ApiException.unknownError;
    }
  }

  @override
  Future<void> cancelRegistration({
    required int eventPk,
    required int registrationPk,
  }) async {
    return sandbox(() async {
      final uri = _uri(path: '/events/$eventPk/registrations/$registrationPk/');
      await _handleExceptions(() => _client.delete(uri));
    });
  }

  @override
  Future<String> markPresentEventRegistration({
    required int eventPk,
    required String token,
  }) async {
    return sandbox(() async {
      final uri = _uri(path: '/events/$eventPk/mark-present/$token/');
      final response = await _handleExceptions(
        () => _client.patch(uri),
        allowedStatusCodes: [200, 403],
      );
      final detail = _jsonDecode(response)['detail'] as String;
      if (response.statusCode == 403) throw ApiException.message(detail);
      return detail;
    });
  }

  @override
  Future<void> markNotPaidAdminEventRegistration({
    required int registrationPk,
  }) async {
    return sandbox(() async {
      final uri = _uri(
        path:
            '/admin/payments/payables/events/eventregistration/$registrationPk/',
      );
      await _handleExceptions(() => _client.delete(uri));
    });
  }

  @override
  Future<void> markNotPaidAdminFoodOrder({
    required int orderPk,
  }) async {
    return sandbox(() async {
      final uri = _uri(
        path: '/admin/payments/payables/pizzas/foodorder/$orderPk/',
      );
      await _handleExceptions(() => _client.delete(uri));
    });
  }

  @override
  Future<void> cancelFoodOrder(int pk) async {
    return sandbox(() async {
      final uri = _uri(path: '/food/events/$pk/order/');
      await _handleExceptions(() => _client.delete(uri));
    });
  }

  @override
  Future<void> updateAvatar(String filePath) async {
    return sandbox(() async {
      final uri = _uri(path: '/members/me/');
      final request = MultipartRequest('PATCH', uri);
      request.files.add(
        await MultipartFile.fromPath(
          'profile.photo',
          filePath,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      await _handleExceptions(() async {
        final streamedResponse = await _client.send(request);
        return Response.fromStream(streamedResponse);
      });
    });
  }

  @override
  Future<void> updateDescription(String description) async {
    return sandbox(() async {
      final uri = _uri(path: '/members/me/');
      final body = jsonEncode({
        'profile': {'profile_description': description}
      });
      await _handleExceptions(
        () => _client.patch(uri, body: body, headers: _jsonHeader),
      );
    });
  }

  @override
  Future<Album> getAlbum({required String slug}) async {
    return sandbox(() async {
      final uri = _uri(path: '/photos/albums/$slug/');
      final response = await _handleExceptions(() => _client.get(uri));
      return Album.fromJson(_jsonDecode(response));
    });
  }

  @override
  Future<void> updateLiked(int pk, bool liked) async {
    return sandbox(() async {
      final uri = _uri(path: '/photos/photos/$pk/like/');
      await _handleExceptions(
        () => liked
            ? _client.post(uri, headers: _jsonHeader)
            : _client.delete(uri, headers: _jsonHeader),
      );
    });
  }

  @override
  Future<ListResponse<ListAlbum>> getAlbums({
    String? search,
    int? limit,
    int? offset,
  }) async {
    return sandbox(() async {
      final uri = _uri(
        path: '/photos/albums/',
        query: {
          if (search != null) 'search': search,
          if (limit != null) 'limit': limit.toString(),
          if (offset != null) 'offset': offset.toString(),
        },
      );

      final response = await _handleExceptions(() => _client.get(uri));
      return await compute(_parseAlbums, response);
    });
  }

  static ListResponse<ListAlbum> _parseAlbums(Response response) {
    return ListResponse<ListAlbum>.fromJson(
      _jsonDecode(response),
      (json) => ListAlbum.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ListResponse<FrontpageArticle>> getFrontpageArticles({
    int? limit,
    int? offset,
  }) async {
    return sandbox(() async {
      final uri = _uri(
        path: '/announcements/frontpage-articles/',
        query: {
          if (limit != null) 'limit': limit.toString(),
          if (offset != null) 'offset': offset.toString(),
        },
      );

      final response = await _handleExceptions(() => _client.get(uri));
      return await compute(_parseFrontpageArticles, response);
    });
  }

  static ListResponse<FrontpageArticle> _parseFrontpageArticles(
    Response response,
  ) {
    return ListResponse<FrontpageArticle>.fromJson(
      _jsonDecode(response),
      (json) => FrontpageArticle.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ListResponse<AlbumPhoto>> getLikedPhotos({
    int? limit,
    int? offset,
  }) async {
    final uri = _baseUri.replace(
      path: '$_basePath/photos/photos/liked/',
      queryParameters: {
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
      },
    );

    final response = await _handleExceptions(() => _client.get(uri));
    return ListResponse<AlbumPhoto>.fromJson(
      _jsonDecode(response),
      (json) => AlbumPhoto.fromJson(json as Map<String, dynamic>),
    );
  }
}
