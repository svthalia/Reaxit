import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/config.dart' as config;
import 'package:reaxit/models/list_response.dart';
import 'package:reaxit/tosti/models.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class TostiApiRepository {
  // TODO: Replace shared utils from apis to a base class.

  /// The [oauth2.Client] used to access the API.
  final oauth2.Client _client;
  final Function() _onLogOut;

  TostiApiRepository({
    /// The [oauth2.Client] used to access the API.
    required oauth2.Client client,

    /// Called when the client can no longer authenticate.
    required Function() onLogOut,
  })  : _client = client,
        _onLogOut = onLogOut;

  void close() {
    _client.close();
  }

  static final Uri _baseUri = Uri(
    scheme: config.tostiApiScheme,
    host: config.tostiApiHost,
    port: config.tostiApiPort,
  );

  static const String _basePath = 'api/v1';

  /// Headers that should be specified on requests with a JSON body.
  static const Map<String, String> _jsonHeader = {
    'Content-type': 'application/json',
  };

  /// Convenience method for building a URL to an API endpoint.
  static Uri _uri({required String path, Map<String, dynamic>? query}) {
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
  /// other than 200, 201 and 204 result in an [ApiException], but this can be
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
    List<int> allowedStatusCodes = const [200, 201, 204],
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

  /// Get the logged in [TostiUser].
  Future<TostiUser> getMe() {
    return sandbox(() async {
      final uri = _uri(path: '/users/me/');
      final response = await _handleExceptions(() => _client.get(uri));
      return TostiUser.fromJson(_jsonDecode(response));
    });
  }

  /// Get a list of [TostiShift]s.
  ///
  /// Use `limit` and `offset` for pagination. The other
  /// parameters can be used to filter the results.
  Future<ListResponse<TostiShift>> getShifts({
    int? limit,
    int? offset,
    DateTime? startLTE,
    DateTime? startGTE,
    DateTime? endLTE,
    DateTime? endGTE,
    int? venue,
    bool? canOrder,
    bool? finalized,
    int? assignee,
  }) {
    return sandbox(() async {
      final uri = _uri(
        path: '/shifts/',
        query: {
          if (limit != null) 'limit': limit.toString(),
          if (offset != null) 'offset': offset.toString(),
          if (startLTE != null) 'start__lte': startLTE.toIso8601String(),
          if (startGTE != null) 'start__gte': startGTE.toIso8601String(),
          if (endLTE != null) 'end__lte': endLTE.toIso8601String(),
          if (endGTE != null) 'end__gte': endGTE.toIso8601String(),
          if (venue != null) 'venue': venue.toString(),
          if (canOrder != null) 'can_order': canOrder.toString(),
          if (finalized != null) 'finalized': finalized.toString(),
          if (assignee != null) 'assignees': assignee.toString(),
        },
      );
      final response = await _handleExceptions(() => _client.get(uri));
      return ListResponse<TostiShift>.fromJson(
        _jsonDecode(response),
        (json) => TostiShift.fromJson(json as Map<String, dynamic>),
      );
    });
  }

  /// Get the [TostiShift] with the `pk`.
  Future<TostiShift> getShift(int pk) {
    return sandbox(() async {
      final uri = _uri(path: '/shifts/$pk/');
      final response = await _handleExceptions(() => _client.get(uri));
      return TostiShift.fromJson(_jsonDecode(response));
    });
  }

  /// Get a list of [TostiProduct]s at a [TostiShift].
  ///
  /// Use `limit` and `offset` for pagination. You can also filter on
  /// `available`, `orderable`, `ignoreShiftRestrictions`, or search by name
  /// with `search`.
  Future<ListResponse<TostiProduct>> getShiftProducts(
    int shiftPk, {
    int? limit,
    int? offset,
    bool? available,
    bool? orderable,
    bool? ignoreShiftRestrictions,
    String? search,
  }) {
    return sandbox(() async {
      final uri = _uri(
        path: '/shifts/$shiftPk/products/',
        query: {
          if (limit != null) 'limit': limit.toString(),
          if (offset != null) 'offset': offset.toString(),
          if (available != null) 'available': available.toString(),
          if (orderable != null) 'orderable': orderable.toString(),
          if (ignoreShiftRestrictions != null)
            'ignore_shift_restrictions': ignoreShiftRestrictions.toString(),
          if (search != null) 'search': search,
        },
      );
      final response = await _handleExceptions(() => _client.get(uri));
      return ListResponse<TostiProduct>.fromJson(
        _jsonDecode(response),
        (json) => TostiProduct.fromJson(json as Map<String, dynamic>),
      );
    });
  }

  /// Get a list of [TostiOrder]s at a [TostiShift].
  ///
  /// Use `limit` and `offset` for pagination. You can also filter in many ways.
  Future<ListResponse<TostiOrder>> getShiftOrders(
    int shiftPk, {
    int? limit,
    int? offset,
    int? user,
    bool? userIsNull,
    bool? ready,
    bool? paid,
    int? product,
  }) {
    return sandbox(() async {
      final uri = _uri(
        path: '/shifts/$shiftPk/orders/',
        query: {
          if (limit != null) 'limit': limit.toString(),
          if (offset != null) 'offset': offset.toString(),
          if (user != null) 'user': user.toString(),
          if (userIsNull != null) 'user__isnull': userIsNull.toString(),
          if (ready != null) 'ready': ready.toString(),
          if (paid != null) 'paid': paid.toString(),
          if (product != null) 'product': product.toString(),
        },
      );
      final response = await _handleExceptions(() => _client.get(uri));
      return ListResponse<TostiOrder>.fromJson(
        _jsonDecode(response),
        (json) => TostiOrder.fromJson(json as Map<String, dynamic>),
      );
    });
  }

  /// Get the [TostiOrder] with `orderPk` for the [TostiShift] with `shiftPk`.
  Future<TostiOrder> getOrder(int shiftPk, int orderPk) {
    return sandbox(() async {
      final uri = _uri(path: '/shifts/$shiftPk/orders/$orderPk/');
      final response = await _handleExceptions(() => _client.get(uri));
      return TostiOrder.fromJson(_jsonDecode(response));
    });
  }

  /// Place a [TostiOrder] for the [TostiShift] with `shiftPk`.
  Future<TostiOrder> placeOrder(int shiftPk, TostiProduct product) {
    return sandbox(() async {
      final uri = _uri(path: '/shifts/$shiftPk/orders/');
      final body = {'product': product.id, 'type': 0};
      final response = await _handleExceptions(
        () => _client.post(uri, body: body, headers: _jsonHeader),
      );
      return TostiOrder.fromJson(_jsonDecode(response));
    });
  }

  /// Get a list of [TostiVenue]s.
  ///
  /// Use `limit` and `offset` for pagination. You can also filter on
  /// `canBeReserved` and search with `search`.
  Future<ListResponse<TostiVenue>> getVenues({
    int? limit,
    int? offset,
    bool? canBeReserved,
    String? search,
  }) {
    return sandbox(() async {
      final uri = _uri(
        path: '/venues/',
        query: {
          if (limit != null) 'limit': limit.toString(),
          if (offset != null) 'offset': offset.toString(),
          if (canBeReserved != null)
            'can_be_reserved': canBeReserved.toString(),
          if (search != null) 'search': search,
        },
      );
      final response = await _handleExceptions(() => _client.get(uri));
      return ListResponse<TostiVenue>.fromJson(
        _jsonDecode(response),
        (json) => TostiVenue.fromJson(json as Map<String, dynamic>),
      );
    });
  }

  /// Get the [TostiVenue] with the `pk`.
  Future<TostiVenue> getVenue(int pk) {
    return sandbox(() async {
      final uri = _uri(path: '/venues/$pk/');
      final response = await _handleExceptions(() => _client.get(uri));
      return TostiVenue.fromJson(_jsonDecode(response));
    });
  }

  /// Get a list of [ThaliedjePlayer]s.
  ///
  /// Use `limit` and `offset` for pagination. You can
  /// also filter on `venue` or `search` by name.
  Future<ListResponse<ThaliedjePlayer>> getPlayers({
    int? limit,
    int? offset,
    int? venue,
    String? search,
  }) {
    return sandbox(() async {
      final uri = _uri(
        path: '/thaliedje/players/',
        query: {
          if (limit != null) 'limit': limit.toString(),
          if (offset != null) 'offset': offset.toString(),
          if (venue != null) 'venue': venue.toString(),
          if (search != null) 'search': search,
        },
      );
      final response = await _handleExceptions(() => _client.get(uri));
      return ListResponse<ThaliedjePlayer>.fromJson(
        _jsonDecode(response),
        (json) => ThaliedjePlayer.fromJson(json as Map<String, dynamic>),
      );
    });
  }
}
