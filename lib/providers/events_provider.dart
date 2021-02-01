import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/models/user_registration.dart';
import 'package:reaxit/providers/api_service.dart';
import 'package:reaxit/providers/auth_provider.dart';

class EventsProvider extends ApiSearchService {
  List<Event> _eventList = [];

  EventsProvider(AuthProvider authProvider) : super(authProvider);

  List<Event> get eventList => _eventList;

  Future<void> load() async {
    if (authProvider.status == Status.SIGNED_IN) {
      status = ApiStatus.LOADING;
      notifyListeners();

      try {
        Response response = await authProvider.helper
            .get('https://staging.thalia.nu/api/v1/events/');
        if (response.statusCode == 200) {
          List<dynamic> jsonEvents = jsonDecode(response.body)['results'];
          _eventList =
              jsonEvents.map((jsonEvent) => Event.fromJson(jsonEvent)).toList();
          _eventList.sort((event1, event2) =>
              (event1.start.difference(event2.start)).inMinutes);
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

  Future<List<UserRegistration>> getEventRegistrations(int pk) async {
    // TODO: Create this method
    if (authProvider.status == Status.SIGNED_IN) {
      var response = await authProvider.helper.get(
          'https://staging.thalia.nu/api/v1/events/$pk/registrations/?status=registered');
      if (response.statusCode == 200) {
        List jsonRegistrationList = jsonDecode(response.body);
        print(jsonRegistrationList);
        return null;
      }
    }
    return null;
  }

  Future<Event> getEvent(int pk) async {
    if (authProvider.status == Status.SIGNED_IN) {
      var response = await authProvider.helper
          .get('https://staging.thalia.nu/api/v1/events/$pk');
      if (response.statusCode == 200) {
        print(response.body.toString());
        return Event.fromJson(jsonDecode(response.body));
      }
    }
    return null;
  }

  void register(Event event) async {
    if (authProvider.status == Status.SIGNED_IN) {
      var response = await authProvider.helper.post('https://staging.thalia.nu/api/v1/events/${event.pk}');
      if (response.statusCode == 200) {
        print(response.body.toString());
      }
    }
    return null;
  }

  // TODO: proper error handling
  @override
  Future<List<Event>> search(String query) async {
    if (authProvider.status == Status.SIGNED_IN) {
      Response response = await authProvider.helper.get(
          'https://staging.thalia.nu/api/v1/events/?search=${Uri.encodeComponent(query)}');
      if (response.statusCode == 200) {
        List<dynamic> jsonEvents = jsonDecode(response.body)['results'];
        return jsonEvents
            .map((jsonEvent) => Event.fromJson(jsonEvent))
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
