import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/models/user_registration.dart';
import 'package:reaxit/providers/api_service.dart';
import 'package:reaxit/providers/auth_provider.dart';

/// Filters a list of registrations on a string.
///
/// [arguments] must be a map with `arguments['list']` a [List<Registration>] and
/// `arguments['query']` the [String] query.
List<Registration> _filterRegistrations(Map arguments) {
  return arguments['list'].where((Registration registration) {
    String query = arguments['query'].toLowerCase();
    return registration.name.toLowerCase().contains(query);
  }).toList();
}

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

  Future<List<Registration>> getEventRegistrations(int pk) async {
    String response = await this.get(
      "/events/$pk/registrations/?status=registered",
    );
    List<dynamic> jsonRegistrations = jsonDecode(response);
    return jsonRegistrations
        .map(
          (jsonRegistration) => Registration.fromJson(jsonRegistration),
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

  Future<void> payRegistration(
      Registration registration, String payment) async {
    String body = jsonEncode({"payment": payment});
    await this.patch("/registrations/${registration.pk}/", body);
  }

  Future<void> setPresent(Registration registration, bool present) async {
    String body = jsonEncode({"present": present});
    await this.patch("/registrations/${registration.pk}/", body);
  }

  Future<List<Registration>> searchRegistrations(
      var registrationList, String query) async {
    // List<Registration> registrationList = await getEventR /
    return compute(
      _filterRegistrations,
      {'list': registrationList, 'query': query},
    );
  }
}
