import 'dart:convert';

import 'package:http/http.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:reaxit/models/album.dart';

import 'package:reaxit/models/event.dart';
import 'package:reaxit/models/event_registration.dart';
import 'package:reaxit/models/list_response.dart';
import 'package:reaxit/models/member.dart';

Uri _baseUri = Uri(scheme: 'https', host: 'staging.thalia.nu');
String _basePath = 'api/v2';

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
  /// var response = await _handleExceptions(() => client.get(uri));
  /// ```
  Future<Response> _handleExceptions(
      Future<Response> Function() request) async {
    try {
      var response = await request();
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
    var uri = _baseUri.replace(path: _basePath + '/events/$pk');
    var response = await _handleExceptions(() => client.get(uri));
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
    var uri = _baseUri.replace(
      path: _basePath + '/events/',
      queryParameters: {
        if (search != null) 'search': search,
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
        if (ordering != null) 'ordering': ordering,
        if (start != null) 'start': start.toLocal().toIso8601String(),
        if (end != null) 'end': end.toLocal().toIso8601String(),
      },
    );

    var response = await _handleExceptions(() => client.get(uri));
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
    var uri = _baseUri.replace(
      path: _basePath + '/events/$pk/registrations/',
      queryParameters: {
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
      },
    );

    var response = await _handleExceptions(() => client.get(uri));
    return ListResponse<EventRegistration>.fromJson(
      jsonDecode(response.body),
      (json) => EventRegistration.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Register for the [Event] with the `pk`.
  Future<EventRegistration> registerForEvent(int pk) async {
    var uri = _baseUri.replace(path: _basePath + '/events/$pk/registrations/');
    var response = await _handleExceptions(() => client.post(uri));
    return EventRegistration.fromJson(jsonDecode(response.body));
  }

  /// Deregister for the [Event] with the `pk`.
  Future<void> cancelRegistrationForEvent(int pk) async {
    var uri = _baseUri.replace(path: _basePath + '/events/$pk/registrations/');
    await _handleExceptions(() => client.delete(uri));
  }

  // TODO: fields

  // TODO: event admin
  // getAdminEventRegistrations()
  // ...

  // TODO: pizzas

  // TODO: pizza admin

  // TODO: Thalia Pay

  /// Get the [Member] with the `pk`.
  Future<Member> getMember({required int pk}) async {
    var uri = _baseUri.replace(path: _basePath + '/members/$pk');
    var response = await _handleExceptions(() => client.get(uri));
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
    var uri = _baseUri.replace(
      path: _basePath + '/members/',
      queryParameters: {
        if (search != null) 'search': search,
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
        if (ordering != null) 'ordering': ordering,
      },
    );

    var response = await _handleExceptions(() => client.get(uri));
    return ListResponse<ListMember>.fromJson(
      jsonDecode(response.body),
      (json) => ListMember.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get the logged in [FullMember].
  Future<FullMember> getMe() async {
    var uri = _baseUri.replace(path: _basePath + '/members/me');
    var response = await _handleExceptions(() => client.get(uri));
    return FullMember.fromJson(jsonDecode(response.body));
  }

  /// Get the [Album] with the `pk`.
  Future<Album> getAlbum({required int pk}) async {
    var uri = _baseUri.replace(path: _basePath + '/photos/albums/$pk');
    var response = await _handleExceptions(() => client.get(uri));
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
    var uri = _baseUri.replace(
      path: _basePath + '/photos/albums/',
      queryParameters: {
        if (search != null) 'search': search,
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
      },
    );

    var response = await _handleExceptions(() => client.get(uri));
    return ListResponse<ListAlbum>.fromJson(
      jsonDecode(response.body),
      (json) => ListAlbum.fromJson(json as Map<String, dynamic>),
    );
  }
}

// TODO: move json parsing of lists into isolates?
