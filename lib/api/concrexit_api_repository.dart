import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/config.dart' as config;
import 'package:reaxit/models/album.dart';
import 'package:reaxit/models/group.dart';
import 'package:reaxit/models/push_notification_category.dart';
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
import 'package:reaxit/models/device.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

final Uri _baseUri = Uri(
  scheme: 'https',
  host: config.apiHost,
);

const String _basePath = 'api/v2';

const Map<String, String> _jsonHeader = {
  'Content-type': 'application/json',
};

/// Wrapper that utf-8 decodes the body of a response to json.
Map<String, dynamic> _jsonDecode(http.Response response) =>
    jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

/// Provides an interface to the api.
///
/// Its methods may throw an [ApiException] if there are unexpected results.
/// In case credentials cannot be refreshed, this calls `logOut`, which should
/// close the client and indicates that the user is no longer logged in.
class ConcrexitApiRepository implements ApiRepository {
  /// The [oauth2.Client] used to access the API.
  final oauth2.Client _client;
  final Function() _onLogOut;

  ConcrexitApiRepository({
    /// The [oauth2.Client] used to access the API.
    required oauth2.Client client,

    /// Called when the client can no longer authenticate.
    required Function() onLogOut,
  })  : _client = client,
        _onLogOut = onLogOut;

  @override
  void close() {
    _client.close();
  }

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
          _onLogOut();
          throw ApiException.notLoggedIn;
        case 403:
          throw ApiException.notAllowed;
        case 404:
          throw ApiException.notFound;
        default:
          throw ApiException.unknownError;
      }
    } on oauth2.ExpirationException catch (_) {
      _onLogOut();
      throw ApiException.notLoggedIn;
    } on oauth2.AuthorizationException catch (_) {
      _onLogOut();
      throw ApiException.notLoggedIn;
    } on SocketException catch (_) {
      throw ApiException.noInternet;
    } on FormatException catch (_) {
      throw ApiException.unknownError;
    } on http.ClientException catch (_) {
      throw ApiException.unknownError;
    } on OSError catch (_) {
      throw ApiException.unknownError;
    } on ApiException catch (_) {
      rethrow;
    }
  }

  /// Handler to surround all public methods as follows:
  ///
  /// ```dart
  /// try {
  ///   // Method content ...
  /// } catch (e) {
  ///   _catch(e);
  /// }
  /// ```
  ///
  /// This prevents the ApiRepository from throwing any exceptions other than
  /// ApiExceptions.
  static Never _catch(Object exception) {
    if (exception is ApiException) {
      throw exception;
    } else {
      Sentry.captureException(exception);
      throw ApiException.unknownError;
    }
  }

  @override
  Future<Event> getEvent({required int pk}) async {
    try {
      final uri = _baseUri.replace(path: '$_basePath/events/$pk/');
      final response = await _handleExceptions(() => _client.get(uri));
      final event = Event.fromJson(_jsonDecode(response));
      if (event.isRegistered) {
        try {
          await getEventRegistrationPayable(
            registrationPk: event.registration!.pk,
          );
          event.registration!.tpayAllowed = true;
        } on ApiException catch (exception) {
          if (exception != ApiException.notAllowed) rethrow;
        }
      }
      return event;
    } catch (e) {
      _catch(e);
    }
  }

  @override
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
    try {
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

      final response = await _handleExceptions(() => _client.get(uri));
      return ListResponse<Event>.fromJson(
        _jsonDecode(response),
        (json) => Event.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<ListResponse<PartnerEvent>> getPartnerEvents({
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
    try {
      final uri = _baseUri.replace(
        path: '$_basePath/partners/events/',
        queryParameters: {
          if (search != null) 'search': search,
          if (limit != null) 'limit': limit.toString(),
          if (offset != null) 'offset': offset.toString(),
          if (ordering != null) 'ordering': ordering,
          if (start != null) 'start': start.toLocal().toIso8601String(),
          if (end != null) 'end': end.toLocal().toIso8601String(),
        },
      );

      final response = await _handleExceptions(() => _client.get(uri));
      return ListResponse<PartnerEvent>.fromJson(
        _jsonDecode(response),
        (json) => PartnerEvent.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<ListResponse<EventRegistration>> getEventRegistrations({
    required int pk,
    int? limit,
    int? offset,
  }) async {
    try {
      final uri = _baseUri.replace(
        path: '$_basePath/events/$pk/registrations/',
        queryParameters: {
          if (limit != null) 'limit': limit.toString(),
          if (offset != null) 'offset': offset.toString(),
        },
      );

      final response = await _handleExceptions(() => _client.get(uri));
      return ListResponse<EventRegistration>.fromJson(
        _jsonDecode(response),
        (json) => EventRegistration.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<EventRegistration> registerForEvent(int pk) async {
    try {
      final uri =
          _baseUri.replace(path: '$_basePath/events/$pk/registrations/');
      final response = await _handleExceptions(() => _client.post(uri));
      return EventRegistration.fromJson(_jsonDecode(response));
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<void> cancelRegistration({
    required int eventPk,
    required int registrationPk,
  }) async {
    try {
      final uri = _baseUri.replace(
        path: '$_basePath/events/$eventPk/registrations/$registrationPk/',
      );
      await _handleExceptions(() => _client.delete(uri));
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<Map<String, RegistrationField>> getRegistrationFields({
    required int eventPk,
    required int registrationPk,
  }) async {
    try {
      final uri = _baseUri.replace(
        path:
            '$_basePath/events/$eventPk/registrations/$registrationPk/fields/',
      );
      final response = await _handleExceptions(() => _client.get(uri));
      var json = _jsonDecode(response);
      return json.map(
        (key, jsonField) => MapEntry(
          key,
          RegistrationField.fromJson(jsonField as Map<String, dynamic>),
        ),
      );
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<void> updateRegistrationFields({
    required int eventPk,
    required int registrationPk,
    required Map<String, RegistrationField> fields,
  }) async {
    try {
      final uri = _baseUri.replace(
        path:
            '$_basePath/events/$eventPk/registrations/$registrationPk/fields/',
      );
      final body = jsonEncode(
        fields.map((key, field) => MapEntry(key, field.value)),
      );
      await _handleExceptions(
        () => _client.put(uri, body: body, headers: _jsonHeader),
      );
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<ListResponse<AdminEventRegistration>> getAdminEventRegistrations({
    required int pk,
    int? limit,
    int? offset,
    String? search,
    String? ordering,
    bool? cancelled,
  }) async {
    assert(
      ordering == null ||
          [
            'date',
            'date_cancelled',
            'queue_position',
            '-date',
            '-date_cancelled',
            '-queue_position',
          ].contains(ordering),
      'Invalid ordering parameter: $ordering',
    );
    try {
      final uri = _baseUri.replace(
        path: '$_basePath/admin/events/$pk/registrations/',
        queryParameters: {
          if (limit != null) 'limit': limit.toString(),
          if (offset != null) 'offset': offset.toString(),
          if (ordering != null) 'ordering': ordering,
          if (search != null) 'search': search,
          if (cancelled != null) 'cancelled': cancelled.toString(),
        },
      );
      final response = await _handleExceptions(() => _client.get(uri));
      return ListResponse<AdminEventRegistration>.fromJson(
        _jsonDecode(response),
        (json) => AdminEventRegistration.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<AdminEventRegistration> markPresentAdminEventRegistration({
    required int eventPk,
    required int registrationPk,
    required bool present,
  }) async {
    try {
      final uri = _baseUri.replace(
        path: '$_basePath/admin/events/$eventPk/registrations/$registrationPk/',
      );
      final body = jsonEncode({'present': present});
      final response = await _handleExceptions(
        () => _client.patch(uri, body: body, headers: _jsonHeader),
      );
      return AdminEventRegistration.fromJson(_jsonDecode(response));
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<Payable> markPaidAdminEventRegistration({
    required int registrationPk,
    required PaymentType paymentType,
  }) async {
    assert(paymentType != PaymentType.tpayPayment);
    final uri = _baseUri.replace(
      path: '$_basePath/admin/payments/payables/events'
          '/eventregistration/$registrationPk/',
    );
    try {
      late String typeString;
      switch (paymentType) {
        case PaymentType.cardPayment:
          typeString = 'card_payment';
          break;
        case PaymentType.cashPayment:
          typeString = 'cash_payment';
          break;
        case PaymentType.wirePayment:
          typeString = 'wire_payment';
          break;
        case PaymentType.tpayPayment:
          // This case should never occur.
          typeString = 'tpay_payment';
          break;
      }
      final body = jsonEncode({'payment_type': typeString});
      final response = await _handleExceptions(
        () => _client.patch(uri, body: body, headers: _jsonHeader),
      );
      return Payable.fromJson(_jsonDecode(response));
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<void> markNotPaidAdminEventRegistration({
    required int registrationPk,
  }) async {
    try {
      final uri = _baseUri.replace(
        path: '$_basePath/admin/payments/payables/events'
            '/eventregistration/$registrationPk/',
      );
      await _handleExceptions(() => _client.delete(uri));
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<ListResponse<FoodOrder>> getAdminFoodOrders({
    required int pk,
    int? limit,
    int? offset,
    String? search,
  }) async {
    try {
      final uri = _baseUri.replace(
        path: '$_basePath/admin/food/events/$pk/orders/',
        queryParameters: {
          if (limit != null) 'limit': limit.toString(),
          if (offset != null) 'offset': offset.toString(),
          if (search != null) 'search': search,
        },
      );
      final response = await _handleExceptions(() => _client.get(uri));
      return ListResponse<FoodOrder>.fromJson(
        _jsonDecode(response),
        (json) => FoodOrder.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<Payable> markPaidAdminFoodOrder({
    required int orderPk,
    required PaymentType paymentType,
  }) async {
    assert(paymentType != PaymentType.tpayPayment);
    try {
      final uri = _baseUri.replace(
        path: '$_basePath/admin/payments/payables/'
            'pizzas/foodorder/$orderPk/',
      );
      late String typeString;
      switch (paymentType) {
        case PaymentType.cardPayment:
          typeString = 'card_payment';
          break;
        case PaymentType.cashPayment:
          typeString = 'cash_payment';
          break;
        case PaymentType.wirePayment:
          typeString = 'wire_payment';
          break;
        case PaymentType.tpayPayment:
          // This case should never occur.
          typeString = 'tpay_payment';
          break;
      }
      final body = jsonEncode({'payment_type': typeString});
      final response = await _handleExceptions(
        () => _client.patch(uri, body: body, headers: _jsonHeader),
      );
      return Payable.fromJson(_jsonDecode(response));
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<void> markNotPaidAdminFoodOrder({
    required int orderPk,
  }) async {
    try {
      final uri = _baseUri.replace(
        path: '$_basePath/admin/payments/payables/'
            'pizzas/foodorder/$orderPk/',
      );
      await _handleExceptions(() => _client.delete(uri));
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<FoodEvent> getFoodEvent(int pk) async {
    try {
      final uri = _baseUri.replace(path: '$_basePath/food/events/$pk/');
      final response = await _handleExceptions(() => _client.get(uri));
      final foodEvent = FoodEvent.fromJson(_jsonDecode(response));
      if (foodEvent.hasOrder) {
        try {
          await getFoodOrderPayable(foodOrderPk: foodEvent.order!.pk);
          foodEvent.order!.tpayAllowed = true;
        } on ApiException catch (exception) {
          if (exception != ApiException.notAllowed) rethrow;
        }
      }
      return foodEvent;
    } catch (e) {
      _catch(e);
    }
  }

  @override
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
    try {
      final uri = _baseUri.replace(
        path: '$_basePath/food/events/',
        queryParameters: {
          if (limit != null) 'limit': limit.toString(),
          if (offset != null) 'offset': offset.toString(),
          if (ordering != null) 'ordering': ordering,
          if (start != null) 'start': start.toLocal().toIso8601String(),
          if (end != null) 'end': end.toLocal().toIso8601String(),
        },
      );

      final response = await _handleExceptions(() => _client.get(uri));
      return ListResponse<FoodEvent>.fromJson(
        _jsonDecode(response),
        (json) => FoodEvent.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<FoodEvent> getCurrentFoodEvent() async {
    try {
      final now = DateTime.now().toLocal();
      final uri = _baseUri.replace(
        path: '$_basePath/food/events/',
        queryParameters: {
          'ordering': 'start',
          'start': now.subtract(const Duration(hours: 8)).toIso8601String(),
          'end': now.add(const Duration(hours: 8)).toIso8601String(),
        },
      );
      final response = await _handleExceptions(() => _client.get(uri));
      final events = ListResponse<FoodEvent>.fromJson(
        _jsonDecode(response),
        (json) => FoodEvent.fromJson(json as Map<String, dynamic>),
      ).results;

      if (events.isEmpty) {
        throw ApiException.notFound;
      } else if (events.length == 1) {
        final foodEvent = events.first;
        if (foodEvent.hasOrder) {
          try {
            await getFoodOrderPayable(foodOrderPk: foodEvent.order!.pk);
            foodEvent.order!.tpayAllowed = true;
          } on ApiException catch (exception) {
            if (exception != ApiException.notAllowed) rethrow;
          }
        }
        return foodEvent;
      } else {
        final foodEvent = events.firstWhere(
          (event) => event.end.isAfter(now),
          orElse: () => events.first,
        );
        if (foodEvent.hasOrder) {
          try {
            await getFoodOrderPayable(foodOrderPk: foodEvent.order!.pk);
            foodEvent.order!.tpayAllowed = true;
          } on ApiException catch (exception) {
            if (exception != ApiException.notAllowed) rethrow;
          }
        }
        return foodEvent;
      }
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<FoodOrder> getFoodOrder(int pk) async {
    try {
      final uri = _baseUri.replace(path: '$_basePath/food/events/$pk/order/');
      final response = await _handleExceptions(() => _client.get(uri));
      final foodOrder = FoodOrder.fromJson(_jsonDecode(response));
      try {
        await getFoodOrderPayable(foodOrderPk: foodOrder.pk);
        foodOrder.tpayAllowed = true;
      } on ApiException catch (exception) {
        if (exception != ApiException.notAllowed) rethrow;
      }
      return foodOrder;
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<void> cancelFoodOrder(int pk) async {
    try {
      final uri = _baseUri.replace(path: '$_basePath/food/events/$pk/order/');
      await _handleExceptions(() => _client.delete(uri));
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<FoodOrder> placeFoodOrder({
    required int eventPk,
    required int productPk,
  }) async {
    try {
      final uri = _baseUri.replace(
        path: '$_basePath/food/events/$eventPk/order/',
      );
      final body = jsonEncode({'product': productPk});
      final response = await _handleExceptions(
        () => _client.post(uri, body: body, headers: _jsonHeader),
      );
      final foodOrder = FoodOrder.fromJson(_jsonDecode(response));
      try {
        await getFoodOrderPayable(foodOrderPk: foodOrder.pk);
        foodOrder.tpayAllowed = true;
      } on ApiException catch (exception) {
        if (exception != ApiException.notAllowed) rethrow;
      }
      return foodOrder;
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<FoodOrder> changeFoodOrder({
    required int eventPk,
    required int productPk,
  }) async {
    try {
      final uri = _baseUri.replace(
        path: '$_basePath/food/events/$eventPk/order/',
      );
      final body = jsonEncode({'product': productPk});
      final response = await _handleExceptions(
        () => _client.put(uri, body: body, headers: _jsonHeader),
      );
      final foodOrder = FoodOrder.fromJson(_jsonDecode(response));
      try {
        await getFoodOrderPayable(foodOrderPk: foodOrder.pk);
        foodOrder.tpayAllowed = true;
      } on ApiException catch (exception) {
        if (exception != ApiException.notAllowed) rethrow;
      }
      return foodOrder;
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<ListResponse<Product>> getFoodEventProducts(
    int pk, {
    int? limit,
    int? offset,
    String? search,
  }) async {
    try {
      final uri = _baseUri.replace(
        path: '$_basePath/food/events/$pk/products/',
        queryParameters: {
          if (limit != null) 'limit': limit.toString(),
          if (offset != null) 'offset': offset.toString(),
        },
      );

      final response = await _handleExceptions(() => _client.get(uri));
      return ListResponse<Product>.fromJson(
        _jsonDecode(response),
        (json) => Product.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      _catch(e);
    }
  }

  Future<Payable> _getPayable({
    required String appLabel,
    required String modelName,
    required String payablePk,
  }) async {
    try {
      final uri = _baseUri.replace(
        path: '$_basePath/payments/payables/$appLabel/$modelName/$payablePk/',
      );

      final response = await _handleExceptions(() => _client.get(uri));
      return Payable.fromJson(_jsonDecode(response));
    } catch (e) {
      _catch(e);
    }
  }

  Future<Payable> _makeThaliaPayPayment({
    required String appLabel,
    required String modelName,
    required String payablePk,
  }) async {
    try {
      final uri = _baseUri.replace(
        path: '$_basePath/payments/payables/$appLabel/'
            '$modelName/${Uri.encodeComponent(payablePk)}/',
      );

      final response = await _handleExceptions(() => _client.patch(uri));
      return Payable.fromJson(_jsonDecode(response));
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<PaymentUser> getPaymentUser() async {
    try {
      final uri = _baseUri.replace(path: '$_basePath/payments/users/me/');
      final response = await _handleExceptions(() => _client.get(uri));
      return PaymentUser.fromJson(_jsonDecode(response));
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<Payable> getFoodOrderPayable({required int foodOrderPk}) =>
      _getPayable(
        appLabel: 'pizzas',
        modelName: 'foodorder',
        payablePk: foodOrderPk.toString(),
      );

  @override
  Future<Payable> thaliaPayFoodOrder({required int foodOrderPk}) =>
      _makeThaliaPayPayment(
        appLabel: 'pizzas',
        modelName: 'foodorder',
        payablePk: foodOrderPk.toString(),
      );

  @override
  Future<Payable> getEventRegistrationPayable({required int registrationPk}) =>
      _getPayable(
        appLabel: 'events',
        modelName: 'eventregistration',
        payablePk: registrationPk.toString(),
      );

  @override
  Future<Payable> thaliaPayRegistration({required int registrationPk}) =>
      _makeThaliaPayPayment(
        appLabel: 'events',
        modelName: 'eventregistration',
        payablePk: registrationPk.toString(),
      );

  @override
  Future<Payable> getSalesOrderPayable({required String salesOrderPk}) =>
      _getPayable(
        appLabel: 'sales',
        modelName: 'order',
        payablePk: salesOrderPk,
      );

  @override
  Future<Payable> thaliaPaySalesOrder({required String salesOrderPk}) =>
      _makeThaliaPayPayment(
        appLabel: 'sales',
        modelName: 'order',
        payablePk: salesOrderPk,
      );

  @override
  Future<Member> getMember({required int pk}) async {
    try {
      final uri = _baseUri.replace(path: '$_basePath/members/$pk/');
      final response = await _handleExceptions(() => _client.get(uri));
      return Member.fromJson(_jsonDecode(response));
    } catch (e) {
      _catch(e);
    }
  }

  @override
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
    try {
      final uri = _baseUri.replace(
        path: '$_basePath/members/',
        queryParameters: {
          if (search != null) 'search': search,
          if (limit != null) 'limit': limit.toString(),
          if (offset != null) 'offset': offset.toString(),
          if (ordering != null) 'ordering': ordering,
        },
      );

      final response = await _handleExceptions(() => _client.get(uri));
      return ListResponse<ListMember>.fromJson(
        _jsonDecode(response),
        (json) => ListMember.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<FullMember> getMe() async {
    try {
      final uri = _baseUri.replace(path: '$_basePath/members/me/');
      final response = await _handleExceptions(() => _client.get(uri));
      return FullMember.fromJson(_jsonDecode(response));
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<void> updateAvatar(File file) async {
    try {
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
        final streamedResponse = await _client.send(request);
        return http.Response.fromStream(streamedResponse);
      });
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<void> updateDescription(String description) async {
    try {
      final uri = _baseUri.replace(path: '$_basePath/members/me/');
      final body = jsonEncode({
        'profile': {'profile_description': description}
      });
      await _handleExceptions(
        () => _client.patch(uri, body: body, headers: _jsonHeader),
      );
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<Album> getAlbum({required String slug}) async {
    try {
      final uri = _baseUri.replace(path: '$_basePath/photos/albums/$slug/');
      final response = await _handleExceptions(() => _client.get(uri));
      return Album.fromJson(_jsonDecode(response));
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<ListResponse<ListAlbum>> getAlbums({
    String? search,
    int? limit,
    int? offset,
  }) async {
    try {
      final uri = _baseUri.replace(
        path: '$_basePath/photos/albums/',
        queryParameters: {
          if (search != null) 'search': search,
          if (limit != null) 'limit': limit.toString(),
          if (offset != null) 'offset': offset.toString(),
        },
      );

      final response = await _handleExceptions(() => _client.get(uri));
      return ListResponse<ListAlbum>.fromJson(
        _jsonDecode(response),
        (json) => ListAlbum.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<ListResponse<Slide>> getSlides({
    int? limit,
    int? offset,
  }) async {
    try {
      final uri = _baseUri.replace(
        path: '$_basePath/announcements/slides/',
        queryParameters: {
          if (limit != null) 'limit': limit.toString(),
          if (offset != null) 'offset': offset.toString(),
        },
      );

      final response = await _handleExceptions(() => _client.get(uri));
      return ListResponse<Slide>.fromJson(
        _jsonDecode(response),
        (json) => Slide.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<ListResponse<FrontpageArticle>> getFrontpageArticles({
    int? limit,
    int? offset,
  }) async {
    try {
      final uri = _baseUri.replace(
        path: '$_basePath/announcements/frontpage-articles/',
        queryParameters: {
          if (limit != null) 'limit': limit.toString(),
          if (offset != null) 'offset': offset.toString(),
        },
      );

      final response = await _handleExceptions(() => _client.get(uri));
      return ListResponse<FrontpageArticle>.fromJson(
        _jsonDecode(response),
        (json) => FrontpageArticle.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<Device> registerDevice({
    required String token,
    required String type,
    bool active = true,
  }) async {
    try {
      final uri = _baseUri.replace(
        path: '$_basePath/pushnotifications/devices/',
      );
      final body = jsonEncode({
        'registration_id': token,
        'active': active,
        'type': type,
      });
      final response = await _handleExceptions(
        () => _client.post(uri, body: body, headers: _jsonHeader),
      );
      return Device.fromJson(_jsonDecode(response));
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<Device> getDevice({required int pk}) async {
    try {
      final uri = _baseUri.replace(
        path: '$_basePath/pushnotifications/devices/$pk/',
      );
      final response = await _handleExceptions(() => _client.get(uri));
      return Device.fromJson(_jsonDecode(response));
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<Device> disableDevice({required int pk}) async {
    try {
      final uri = _baseUri.replace(
        path: '$_basePath/pushnotifications/devices/$pk/',
      );
      final body = jsonEncode({'active': false});
      final response = await _handleExceptions(
        () => _client.patch(uri, body: body, headers: _jsonHeader),
      );
      return Device.fromJson(_jsonDecode(response));
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<Device> updateDeviceToken({
    required int pk,
    required String token,
  }) async {
    try {
      final uri = _baseUri.replace(
        path: '$_basePath/pushnotifications/devices/$pk/',
      );
      final body = jsonEncode({'registration_id': token});
      final response = await _handleExceptions(
        () => _client.patch(uri, body: body, headers: _jsonHeader),
      );
      return Device.fromJson(_jsonDecode(response));
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<Device> updateDeviceReceiveCategory({
    required int pk,
    required List<String> receiveCategory,
  }) async {
    try {
      final uri = _baseUri.replace(
        path: '$_basePath/pushnotifications/devices/$pk/',
      );
      final body = jsonEncode({'receive_category': receiveCategory});
      final response = await _handleExceptions(
        () => _client.patch(uri, body: body, headers: _jsonHeader),
      );
      return Device.fromJson(_jsonDecode(response));
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<ListResponse<PushNotificationCategory>> getCategories() async {
    try {
      final uri = _baseUri.replace(
        path: '$_basePath/pushnotifications/categories/',
      );
      final response = await _handleExceptions(() => _client.get(uri));
      return ListResponse<PushNotificationCategory>.fromJson(
        _jsonDecode(response),
        (json) => PushNotificationCategory.fromJson(
          json as Map<String, dynamic>,
        ),
      );
    } catch (e) {
      _catch(e);
    }
  }

  @override
  Future<ListResponse<ListGroup>> getGroups(
      {int? limit,
      int? offset,
      MemberGroupType? type,
      DateTime? start,
      DateTime? end,
      String? search}) async {
    const memberGroupTypeMap = {
      MemberGroupType.committee: 'committee',
      MemberGroupType.society: 'society',
      MemberGroupType.board: 'board',
    };

    final uri = _baseUri.replace(
      path: '$_basePath/activemembers/groups/',
      queryParameters: {
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
        if (type != null) 'type': memberGroupTypeMap[type],
        if (start != null) 'start': start.toIso8601String(),
        if (end != null) 'end': end.toIso8601String(),
        if (search != null) 'search': search
      },
    );

    final response = await _handleExceptions(() => _client.get(uri));
    return ListResponse<ListGroup>.fromJson(
      _jsonDecode(response),
      (json) => ListGroup.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Group> getGroup({required int pk}) async {
    final uri = _baseUri.replace(
      path: '$_basePath/activemembers/groups/' + pk.toString() + '/',
      queryParameters: {},
    );

    final response = await _handleExceptions(() => _client.get(uri));
    return Group.fromJson(_jsonDecode(response));
  }
// TODO: Someday: move json parsing of lists into isolates?
// TODO: Someday: change ApiException to a class that can contain a string?
//  We can then display more specific error messages to the user based on
//  the message returned from the server, instead of only the status code.
//  This may especially be useful for the sales order payments.
}
