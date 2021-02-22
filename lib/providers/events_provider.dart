import 'dart:convert';

import 'package:reaxit/models/event.dart';
import 'package:reaxit/models/user_registration.dart';
import 'package:reaxit/providers/api_service.dart';
import 'package:reaxit/providers/auth_provider.dart';

class EventsProvider extends ApiService {
  List<Event> _eventList = [];

  EventsProvider(AuthProvider authProvider) : super(authProvider);

  List<Event> get eventList => _eventList;

  @override
  Future<void> loadImplementation() async {
    _eventList = await _getEvents();
  }

  Future<List<Event>> _getEvents() async {
    String response = await this.get("/events/");
    List<dynamic> jsonEvents = jsonDecode(response);
    List<Event> events =
        jsonEvents.map((jsonEvent) => Event.fromJson(jsonEvent)).toList();
    events.sort(
        (event1, event2) => (event1.start.difference(event2.start)).inMinutes);
    return events;
  }

  Future<List<Event>> search(String query) async {
    String response = await this.get(
      "/events/?search=${Uri.encodeComponent(query)}",
    );
    List<dynamic> jsonEvents = jsonDecode(response);
    return jsonEvents.map((jsonEvent) => Event.fromJson(jsonEvent)).toList();
  }

  Future<List<UserRegistration>> getEventRegistrations(int pk) async {
    String response = await this.get(
      "/events/$pk/registrations/?status=registered",
    );
    List<dynamic> jsonRegistrations = jsonDecode(response);
    return jsonRegistrations
        .map(
          (jsonRegistration) => UserRegistration.fromJson(jsonRegistration),
        )
        .toList();
  }

  Future<Event> getEvent(int pk) async {
    String response = await this.get("/events/$pk");
    return Event.fromJson(jsonDecode(response));
  }

  Future<void> register(Event event) async {
    // TODO: Make this work, also do client side validation if there are required fields before actually registering.
    if (authProvider.status == AuthStatus.SIGNED_IN) {
      var response = await authProvider.helper
          .post('https://staging.thalia.nu/api/v1/events/${event.pk}');
      if (response.statusCode == 200) {
        print(response.body.toString());
      }
    }
    return null;
  }
}
