import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:reaxit/config.dart' as config;
import 'package:reaxit/models/album.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/models/event_registration.dart';
import 'package:reaxit/models/food_event.dart';
import 'package:reaxit/models/food_order.dart';
import 'package:reaxit/models/frontpage_article.dart';
import 'package:reaxit/models/list_response.dart';
import 'package:reaxit/models/member.dart';
import 'package:reaxit/models/payable.dart';
import 'package:reaxit/models/payment.dart';
import 'package:reaxit/models/payment_user.dart';
import 'package:reaxit/models/product.dart';
import 'package:reaxit/models/registration_field.dart';
import 'package:reaxit/models/slide.dart';

final Uri _baseUri = Uri(
  scheme: 'https',
  host: config.apiHost,
);

const String _basePath = 'api/v2';

const Map<String, String> _jsonHeader = {
  'Content-type': 'application/json',
};

enum ApiException {
  notFound,
  notAllowed,
  noInternet,
  notLoggedIn,
  unknownError,
}

/// Provides an interface to the api.
///
/// Its methods may throw an [ApiException] if there are unexpected results.
/// In case credentials cannot be refreshed, this calls `logOut`, which should
/// close the client and indicates that the user is no longer logged in.
class ApiRepository {
  /// The [oauth2.Client] used to access the API.
  final oauth2.Client client;

  /// The function to call when authentication fails.
  /// Should close `client` and have the user log in again.
  final Function() logOut;

  ApiRepository({required this.client, required this.logOut});

  /// A wrapper for requests that throws only [ApiException]s.
  ///
  /// Translates exceptions that can be thrown by [oauth2.Client.send()],
  /// and throws exceptions based on status codes.
  ///
  /// Can be called for example as
  /// ```dart
  /// final response = await _handleExceptions(() => client.get(uri));
  /// ```
  Future<http.Response> _handleExceptions(
      Future<http.Response> Function() request) async {
    try {
      final response = await request();
      switch (response.statusCode) {
        case 200:
        case 201:
        case 204:
          return response;
        case 401:
          logOut();
          throw ApiException.notLoggedIn;
        case 403:
          throw ApiException.notAllowed;
        case 404:
          throw ApiException.notFound;
        default:
          throw ApiException.unknownError;
      }
    } on oauth2.ExpirationException catch (_) {
      logOut();
      throw ApiException.notLoggedIn;
    } on oauth2.AuthorizationException catch (_) {
      logOut();
      throw ApiException.notLoggedIn;
    } on FormatException catch (_) {
      throw ApiException.unknownError;
    } on ApiException catch (_) {
      rethrow;
    } catch (_) {
      throw ApiException.unknownError;
    }
  }

  /// Get the [Event] with the `pk`.
  Future<Event> getEvent({required int pk}) async {
    final uri = _baseUri.replace(path: '$_basePath/events/$pk/');
    final response = await _handleExceptions(() => client.get(uri));
    return Event.fromJson(jsonDecode(response.body));
  }

  /// Get a list of [Event]s.
  ///
  /// Use `limit` and `offset` for pagination. [ListResponse.count] is the
  /// total number of [Events] that can be returned.
  /// Use `search` to filter on name, `ordering` to order with values in {'start',
  /// 'end', '-start', '-end'}, and `start` and/or `end` to filter on a time range.
  Future<ListResponse<Event>> getEvents({
    String? search,
    int? limit,
    int? offset,
    String? ordering,
    DateTime? start,
    DateTime? end,
  }) async {
    assert(
      ordering == null || ['start', 'end', '-start', '-end'].contains(ordering),
      'Invalid ordering parameter: $ordering',
    );
    final uri = _baseUri.replace(
      path: '$_basePath/events/',
      queryParameters: {
        if (search != null) 'search': search,
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
        if (ordering != null) 'ordering': ordering,
        if (start != null) 'start': start.toLocal().toIso8601String(),
        if (end != null) 'end': end.toLocal().toIso8601String(),
      },
    );

    final response = await _handleExceptions(() => client.get(uri));
    return ListResponse<Event>.fromJson(
      jsonDecode(response.body),
      (json) => Event.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get the [EventRegistration]s for the [Event] with the `pk`.
  ///
  /// Use `limit` and `offset` for pagination. [ListResponse.count] is the
  /// total number of [EventRegistration]s that can be returned.
  ///
  /// These [EventRegistration]s are not cancelled. It's the publicly visible
  /// list. The admin of an event can use [getAdminEventRegistrations()] to
  /// include cancelled or queued registrations.
  Future<ListResponse<EventRegistration>> getEventRegistrations({
    required int pk,
    int? limit,
    int? offset,
  }) async {
    final uri = _baseUri.replace(
      path: '$_basePath/events/$pk/registrations/',
      queryParameters: {
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
      },
    );

    final response = await _handleExceptions(() => client.get(uri));
    return ListResponse<EventRegistration>.fromJson(
      jsonDecode(response.body),
      (json) => EventRegistration.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Register for the [Event] with the `pk`.
  Future<EventRegistration> registerForEvent(int pk) async {
    final uri = _baseUri.replace(path: '$_basePath/events/$pk/registrations/');
    final response = await _handleExceptions(() => client.post(uri));
    return EventRegistration.fromJson(jsonDecode(response.body));
  }

  /// Cancel the [EventRegistration] with `registrationPk`
  /// for the [Event] with `eventPk`.
  Future<void> cancelRegistration({
    required int eventPk,
    required int registrationPk,
  }) async {
    final uri = _baseUri.replace(
      path: '$_basePath/events/$eventPk/registrations/$registrationPk/',
    );
    await _handleExceptions(() => client.delete(uri));
  }

  /// Get the [RegistrationField]s of [EventRegistration] `registrationPk`
  /// for [Event] `eventPk`.
  ///
  /// Returns a [Map] of identifiers and corresponding [RegistrationFields].
  Future<Map<String, RegistrationField>> getRegistrationFields({
    required int eventPk,
    required int registrationPk,
  }) async {
    final uri = _baseUri.replace(
      path: '$_basePath/events/$eventPk/registrations/$registrationPk/fields/',
    );
    final response = await _handleExceptions(() => client.get(uri));
    Map<String, dynamic> json = jsonDecode(response.body);
    return json.map(
      (key, jsonField) => MapEntry(key, RegistrationField.fromJson(jsonField)),
    );
  }

  /// Update the [RegistrationField]s of EventRegistration] `registrationPk`
  /// for [Event] `eventPk` to the values in `fields`.
  ///
  /// `fields` must contain every [RegistrationField] returned by
  /// [this.getRegistrationFields()], possibly with null values.
  Future<void> updateRegistrationFields({
    required int eventPk,
    required int registrationPk,
    required Map<String, RegistrationField> fields,
  }) async {
    final uri = _baseUri.replace(
      path: '$_basePath/events/$eventPk/registrations/$registrationPk/fields/',
    );
    final body = jsonEncode(
      fields.map((key, field) => MapEntry(key, field.value)),
    );
    await _handleExceptions(
      () => client.put(uri, body: body, headers: _jsonHeader),
    );
  }

  // TODO: event admin
  //  getAdminEventRegistrations()
  //  ...

  /// Get the [FoodEvent] with the `pk`.
  Future<FoodEvent> getFoodEvent(int pk) async {
    final uri = _baseUri.replace(path: '$_basePath/food/events/$pk/');
    final response = await _handleExceptions(() => client.get(uri));
    return FoodEvent.fromJson(jsonDecode(response.body));
  }

  /// Get a list of [FoodEvent]s.
  ///
  /// Use `limit` and `offset` for pagination. [ListResponse.count] is the
  /// total number of [FoodEvents] that can be returned.
  /// Use `search` to filter on name, `ordering` to order with values in
  /// {'start', 'end', '-start', '-end'}, and `start` and/or `end` to filter
  /// on a time range.
  Future<ListResponse<FoodEvent>> getFoodEvents({
    int? limit,
    int? offset,
    String? ordering,
    DateTime? start,
    DateTime? end,
  }) async {
    assert(
      ordering == null || ['start', 'end', '-start', '-end'].contains(ordering),
      'Invalid ordering parameter: $ordering',
    );
    final uri = _baseUri.replace(
      path: '$_basePath/events/',
      queryParameters: {
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
        if (ordering != null) 'ordering': ordering,
        if (start != null) 'start': start.toLocal().toIso8601String(),
        if (end != null) 'end': end.toLocal().toIso8601String(),
      },
    );

    final response = await _handleExceptions(() => client.get(uri));
    return ListResponse<FoodEvent>.fromJson(
      jsonDecode(response.body),
      (json) => FoodEvent.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get the [FoodOrder] for the [FoodEvent] with the `pk`.
  Future<FoodOrder> getFoodOrder(int pk) async {
    final uri = _baseUri.replace(path: '$_basePath/food/events/$pk/order/');
    final response = await _handleExceptions(() => client.get(uri));
    return FoodOrder.fromJson(jsonDecode(response.body));
  }

  /// Cancel your [FoodOrder] for the [FoodEvent] with the `pk`.
  Future<void> cancelFoodOrder(int pk) async {
    final uri = _baseUri.replace(path: '$_basePath/food/events/$pk/order/');
    await _handleExceptions(() => client.delete(uri));
  }

  /// Place an order [Product] `productPk` on [FoodEvent] `eventPk`.
  Future<FoodOrder> placeFoodOrder({
    required int eventPk,
    required int productPk,
  }) async {
    final uri = _baseUri.replace(
      path: '$_basePath/food/events/$eventPk/order/',
    );
    final body = jsonEncode({'product': productPk});
    final response = await _handleExceptions(
      () => client.post(uri, body: body, headers: _jsonHeader),
    );
    return FoodOrder.fromJson(jsonDecode(response.body));
  }

  /// Change your order to [Product] `productPk` on [FoodEvent] `eventPk`.
  Future<FoodOrder> changeFoodOrder({
    required int eventPk,
    required int productPk,
  }) async {
    final uri = _baseUri.replace(
      path: '$_basePath/food/events/$eventPk/order/',
    );
    final body = jsonEncode({'product': productPk});
    final response = await _handleExceptions(
      () => client.put(uri, body: body, headers: _jsonHeader),
    );
    return FoodOrder.fromJson(jsonDecode(response.body));
  }

  /// Get a list of [Product]s for the [FoodEvent] with the `pk`.
  ///
  /// Use `limit` and `offset` for pagination. [ListResponse.count] is the
  /// total number of [Product]s that can be returned.
  /// Use `search` to filter on name.
  Future<ListResponse<Product>> getFoodEventProducts(
    int pk, {
    int? limit,
    int? offset,
    String? search,
  }) async {
    final uri = _baseUri.replace(
      path: '$_basePath/food/events/$pk/products/',
      queryParameters: {
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
      },
    );

    final response = await _handleExceptions(() => client.get(uri));
    return ListResponse<Product>.fromJson(
      jsonDecode(response.body),
      (json) => Product.fromJson(json as Map<String, dynamic>),
    );
  }

  // TODO: pizza admin

  /// Get a [Payable].
  Future<Payable> _getPayable({
    required String appLabel,
    required String modelName,
    required String payablePk,
  }) async {
    final uri = _baseUri.replace(
      path: '$_basePath/payments/payables/$appLabel/$modelName/$payablePk/',
    );

    final response = await _handleExceptions(() => client.get(uri));
    return Payable.fromJson(jsonDecode(response.body));
  }

  /// Make a Thalia Pay [Payment].
  ///
  /// For example, to pay for a [FoodOrder] with `pk` 1:
  ///
  /// ```dart
  /// _makeThaliaPayPayment(
  ///   appLabel: 'pizzas',
  ///   modelName: 'foodorder',
  ///   payablePk: 1,
  /// );
  /// ```
  Future<Payable> _makeThaliaPayPayment({
    required String appLabel,
    required String modelName,
    required String payablePk,
  }) async {
    final uri = _baseUri.replace(
      path: '$_basePath/payments/payables/$appLabel/'
          '$modelName/${Uri.encodeComponent(payablePk)}/',
    );

    final response = await _handleExceptions(() => client.patch(uri));
    return Payable.fromJson(jsonDecode(response.body));
  }

  /// Get the [PaymentUser] of the currently logged in member.
  Future<PaymentUser> getPaymentUser() async {
    final uri = _baseUri.replace(path: '$_basePath/payments/users/me/');
    final response = await _handleExceptions(() => client.get(uri));
    return PaymentUser.fromJson(jsonDecode(response.body));
  }

  /// Get the [Payable] for the [FoodOrder] with the `foodOrderPk`.
  Future<Payable> getFoodOrderPayable({required int foodOrderPk}) =>
      _getPayable(
        appLabel: 'pizzas',
        modelName: 'foodorder',
        payablePk: foodOrderPk.toString(),
      );

  /// Pay for the [FoodOrder] with the `foodOrderPk` with Thalia Pay.
  Future<Payable> thaliaPayFoodOrder({required int foodOrderPk}) =>
      _makeThaliaPayPayment(
        appLabel: 'pizzas',
        modelName: 'foodorder',
        payablePk: foodOrderPk.toString(),
      );

  /// Get the [Payable] for the [EventRegistration] with the `registrationPk`.
  Future<Payable> getEventRegistrationPayable({required int registrationPk}) =>
      _getPayable(
        appLabel: 'events',
        modelName: 'eventregistration',
        payablePk: registrationPk.toString(),
      );

  /// Pay for the [EventRegistration] with the `registrationPk` with Thalia Pay.
  Future<Payable> thaliaPayRegistration({required int registrationPk}) =>
      _makeThaliaPayPayment(
        appLabel: 'events',
        modelName: 'eventregistration',
        payablePk: registrationPk.toString(),
      );

  /// get the [Payable] for the sales order with the `salesOrderPk`.
  Future<Payable> getSalesOrderPayable({required String salesOrderPk}) =>
      _getPayable(
        appLabel: 'sales',
        modelName: 'order',
        payablePk: salesOrderPk,
      );

  /// Pay for the sales order with the `salesOrderPk` with Thalia Pay.
  Future<Payable> thaliaPaySalesOrder({required String salesOrderPk}) =>
      _makeThaliaPayPayment(
        appLabel: 'sales',
        modelName: 'order',
        payablePk: salesOrderPk,
      );

  /// Get the [Member] with the `pk`.
  Future<Member> getMember({required int pk}) async {
    final uri = _baseUri.replace(path: '$_basePath/members/$pk/');
    final response = await _handleExceptions(() => client.get(uri));
    return Member.fromJson(jsonDecode(response.body));
  }

  /// Get a list of [ListMember]s.
  ///
  /// Use `limit` and `offset` for pagination. [ListResponse.count] is the
  /// total number of [ListMember]s that can be returned.
  /// Use `search` to filter on name, `ordering` to order with values in {'last_name',
  /// 'first_name', 'username', '-last_name', '-first_name', '-username'},
  Future<ListResponse<ListMember>> getMembers({
    String? search,
    int? limit,
    int? offset,
    String? ordering,
  }) async {
    assert(
      ordering == null ||
          [
            'last_name',
            'first_name',
            'username',
            '-last_name',
            '-first_name',
            '-username'
          ].contains(ordering),
      'Invalid ordering parameter: $ordering',
    );
    final uri = _baseUri.replace(
      path: '$_basePath/members/',
      queryParameters: {
        if (search != null) 'search': search,
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
        if (ordering != null) 'ordering': ordering,
      },
    );

    final response = await _handleExceptions(() => client.get(uri));
    return ListResponse<ListMember>.fromJson(
      jsonDecode(response.body),
      (json) => ListMember.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get the logged in [FullMember].
  Future<FullMember> getMe() async {
    final uri = _baseUri.replace(path: '$_basePath/members/me/');
    final response = await _handleExceptions(() => client.get(uri));
    return FullMember.fromJson(jsonDecode(response.body));
  }

  /// Update the avatar of the logged in member.
  ///
  /// `file` should be a jpg image.
  Future<void> updateAvatar(File file) async {
    final uri = _baseUri.replace(path: '$_basePath/members/me/');
    final request = http.MultipartRequest('PATCH', uri);
    request.files.add(
      await http.MultipartFile.fromPath(
        'profile.photo',
        file.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );
    await _handleExceptions(() async {
      final streamedResponse = await client.send(request);
      return http.Response.fromStream(streamedResponse);
    });
  }

  /// Update the description of the logged in member.
  Future<void> updateDescription(String description) async {
    final uri = _baseUri.replace(path: '$_basePath/members/me/');
    final body = jsonEncode({
      'profile': {'profile_description': description}
    });
    await _handleExceptions(
      () => client.patch(uri, body: body, headers: _jsonHeader),
    );
  }

  /// Get the [Album] with the `slug`.
  Future<Album> getAlbum({required String slug}) async {
    final uri = _baseUri.replace(path: '$_basePath/photos/albums/$slug/');
    final response = await _handleExceptions(() => client.get(uri));
    return Album.fromJson(jsonDecode(response.body));
  }

  /// Get a list of [ListAlbum]s.
  ///
  /// Use `limit` and `offset` for pagination. [ListResponse.count] is the
  /// total number of [ListAlbum]s that can be returned.
  /// Use `search` to filter on name or date.
  Future<ListResponse<ListAlbum>> getAlbums({
    String? search,
    int? limit,
    int? offset,
  }) async {
    final uri = _baseUri.replace(
      path: '$_basePath/photos/albums/',
      queryParameters: {
        if (search != null) 'search': search,
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
      },
    );

    final response = await _handleExceptions(() => client.get(uri));
    return ListResponse<ListAlbum>.fromJson(
      jsonDecode(response.body),
      (json) => ListAlbum.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get a list of [Slide]s.
  ///
  /// Use `limit` and `offset` for pagination. [ListResponse.count] is the
  /// total number of [Slide]s that can be returned.
  Future<ListResponse<Slide>> getSlides({
    int? limit,
    int? offset,
  }) async {
    final uri = _baseUri.replace(
      path: '$_basePath/announcements/slides/',
      queryParameters: {
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
      },
    );

    final response = await _handleExceptions(() => client.get(uri));
    return ListResponse<Slide>.fromJson(
      jsonDecode(response.body),
      (json) => Slide.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get a list of [FrontpageArticle]s.
  ///
  /// Use `limit` and `offset` for pagination. [ListResponse.count] is the
  /// total number of [FrontpageArticle]s that can be returned.
  Future<ListResponse<FrontpageArticle>> getFrontpageArticles({
    int? limit,
    int? offset,
  }) async {
    final uri = _baseUri.replace(
      path: '$_basePath/announcements/frontpage-articles/',
      queryParameters: {
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
      },
    );

    final response = await _handleExceptions(() => client.get(uri));
    return ListResponse<FrontpageArticle>.fromJson(
      jsonDecode(response.body),
      (json) => FrontpageArticle.fromJson(json as Map<String, dynamic>),
    );
  }

  // TODO: Move json parsing of lists into isolates?
  // TODO: Change ApiException to a class that can contain a string?
  //  We can then display more specific error messages to the user based on
  //  the message returned from the server, instead of only the status code.
  //  This may especially be useful for the sales order payments.
}
