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
    status = ApiStatus.LOADING;
    notifyListeners();
    try {
      String response = await this.get("/events/");
      List<dynamic> jsonEvents = jsonDecode(response)['results'];
      _eventList =
          jsonEvents.map((jsonEvent) => Event.fromJson(jsonEvent)).toList();
      _eventList.sort((event1, event2) =>
          (event1.start.difference(event2.start)).inMinutes);
      status = ApiStatus.DONE;
      notifyListeners();
    } on ApiException catch (_) {
      notifyListeners();
    }
  }

  Future<List<UserRegistration>> getEventRegistrations(int pk) async {
    try {
      String response = await this.get(
        "/events/$pk/registrations/?status=registered",
      );
      List<dynamic> jsonRegistrations = jsonDecode(response);
      return jsonRegistrations
          .map(
            (jsonRegistration) => UserRegistration.fromJson(jsonRegistration),
          )
          .toList();
    } on ApiException catch (_) {
      notifyListeners();
    }
  }

  Future<Event> getEvent(int pk) async {
    try {
      String response = await this.get("/events/$pk");
      return Event.fromJson(jsonDecode(response));
    } on ApiException catch (_) {
      // TODO: handle 404 separately
      notifyListeners();
    }
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
    try {
      String response = await this.get(
        "/events/?search=${Uri.encodeComponent(query)}",
      );
      List<dynamic> jsonEvents = jsonDecode(response)['results'];
      return jsonEvents.map((jsonEvent) => Event.fromJson(jsonEvent)).toList();
    } on ApiException catch (_) {
      notifyListeners();
    }
  }
}
